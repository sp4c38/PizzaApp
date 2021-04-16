import secrets

from collections import namedtuple
from dataclasses import dataclass
from threading import Lock
from typing import Optional

import arrow

from passlib.hash import bcrypt
from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session
from werkzeug.datastructures import Authorization as AuthorizationHeader

from src.pizzaapp import defaults
from src.pizzaapp.tables import AccessToken, DeliveryUser, RefreshToken, RefreshTokenDescription


AuthentificationInfo = namedtuple("AuthentificationInfo", ["username", "pw_hash"])


def get_auth_info(authorization: AuthorizationHeader) -> Optional[AuthentificationInfo]:
    """Get authentication information from a request.

    :param authorization: The authorization header from the request.
    """
    if authorization is None:
        return None

    if not authorization.type.lower() == "basic":
        return None

    username = authorization.username
    pw_hash = authorization.password
    auth_info = AuthentificationInfo(username, pw_hash)

    return auth_info


def get_delivery_user(session: Session, auth_info: AuthentificationInfo) -> Optional[DeliveryUser]:
    """Check if there is a delivery user for which the authentication information is valid.

    :returns: The DeliveryUser if the auth info is valid, none if
        the auth info is invalid (i.e. wrong username or password hash).
    """
    stmt = select(DeliveryUser).where(DeliveryUser.username == auth_info.username)
    delivery_user = session.execute(stmt).scalar_one_or_none()
    if delivery_user is None:
        return None

    pw_correct = bcrypt.verify(auth_info.pw_hash, delivery_user.pw_hash)
    if not pw_correct:
        return None

    return delivery_user


def parse_bearer_token(authorization: str) -> Optional[str]:
    auth_parts = authorization.split(" ")  # Note: .split(" ") is different than .split().
    if len(auth_parts) != 2:
        return None

    auth_type = auth_parts[0]
    auth_token = auth_parts[1]

    if not auth_type == "Bearer":
        return None

    if auth_token == "":
        return None

    return auth_token


def get_refresh_token(session: Session, token: str) -> Optional[RefreshToken]:
    """Get a refresh token ORM object with specified token.

    :param token: The refresh token for which to get the ORM object.
    :returns: refresh token ORM object if an entry was found, none if no entry was found.
    """
    stmt = select(RefreshToken).where(RefreshToken.refresh_token == token)
    refresh_token = session.execute(stmt).scalar_one_or_none()
    if refresh_token is None:
        return None
    return refresh_token


def gen_token() -> str:
    """Generate a new refresh or access token."""
    token = secrets.token_hex(32)
    return token


@dataclass
class TokenInfo:
    """Hold information about one refresh token and one access token.

    As refresh tokens and access tokens are always issued together this class groups them.
    """

    refresh_token: Optional[RefreshToken]
    access_token: Optional[AccessToken]

    def response_json(self):
        """Generate a json to send back when responding to a client."""
        jsoned = {}
        if self.refresh_token is not None:
            jsoned["refresh_token"] = self.refresh_token.response_json()
        if self.access_token is not None:
            jsoned["access_token"] = self.access_token.response_json()
        return jsoned


def gen_refresh_token(user_id: int, device_description=None) -> RefreshToken:
    """Generate a new refresh token object.

    :param user_id: The user id for which the refresh token is issued.
    """
    token_description = None
    if device_description is not None:
        token_description = RefreshTokenDescription(device_description=device_description)

    token = gen_token()
    now = arrow.now()
    refresh_token = RefreshToken(
        user_id=user_id,
        refresh_token=token,
        valid=True,
        issuing_time=now.int_timestamp,
        description=token_description,
    )
    return refresh_token


def gen_access_token() -> AccessToken:
    """Generate a new access token object."""
    token = gen_token()
    now = arrow.now()
    expiration_time = now.shift(seconds=defaults.ACCESS_TOKEN_VALID_TIME).int_timestamp

    access_token = AccessToken(
        # Refresh token id can't be known at this point because no refresh token was inserted yet.
        refresh_token_id=None,
        access_token=token,
        expiration_time=expiration_time,
    )
    return access_token


def check_reached_refresh_token_limit(session: Session, user_id: int) -> bool:
    """Check if the refresh token limit was reached for a certain user."""
    # fmt: off
    refresh_token_amount_stmt = (
        select(func.count(RefreshToken.refresh_token_id))
        .where(RefreshToken.user_id == token_info.refresh_token.user_id)
    )
    # fmt: on

    # Add one to count new refresh token.
    amount_refresh_tokens = session.execute(refresh_token_amount_stmt).scalar_one() + 1
    if amount_refresh_tokens > defaults.MAX_REFRESH_TOKENS:
        return True

    return False


def check_expiration_times_valid(session: Session, access_tokens: list[AccessToken]) -> bool:
    """Check if expiration times of the access tokens are valid to issue a new access token.

    First gets the access token with the latest expiration time, then checks if this
    access token expired or is in transition time.

    See ACCESS_TOKEN_TRANSITION_TIME in defaults for an explanation of the transition time.

    :param access_tokens: A list of access tokens to check.
    :returns: True if a new access token can be issued, false if not.
    """
    max_access_token_expiration = None
    for token in access_tokens:
        if max_access_token_expiration is not None:
            if token.expiration_time <= max_access_token_expiration:
                continue
        max_access_token_expiration = token.expiration_time

    now = arrow.get()
    # Difference in time to the max access token expiration time relative from now.
    now_difference_expiration = max_access_token_expiration - now.int_timestamp
    if now_difference_expiration > defaults.ACCESS_TOKEN_TRANSITION_TIME:
        print("Client is requesting access token update too early.")
        return False

    return True


def add_new_tokens(session: Session, token_info: TokenInfo):
    """Add new refresh and access tokens to the session.

    :param session: Session object to which to add the new ORM token objects.
    :param token_info: TokenInfo object including information about both token types.
    """
    session.add(token_info.refresh_token)
    session.flush()
    refresh_token_id = token_info.refresh_token.refresh_token_id
    token_info.access_token.refresh_token_id = refresh_token_id
    session.add(token_info.access_token)


def store_token_info(session: Session, lock: Lock, token_info: TokenInfo):
    """Store new refresh and access token to the database."""
    add_new_tokens(session, token_info)

    session.commit()
    lock.release()


def store_refreshed_token_info(
    session: Session, lock: Lock, token_info: TokenInfo, origi_refresh_token: RefreshToken
):
    """Store refreshed token info (tokens retrieved with a refresh token).

    In addition to storing the tokens this will also mark the old refresh token as invalid.

    :param origi_refresh_token: The original refresh token with which was used to authenticate.
    """

    session.add(origi_refresh_token)
    origi_refresh_token.valid = False

    refresh_token_description = origi_refresh_token.description
    refresh_token_description.user_id = None
    token_info.refresh_token.description = refresh_token_description
    add_new_tokens(session, token_info)

    session.commit()
    lock.release()
