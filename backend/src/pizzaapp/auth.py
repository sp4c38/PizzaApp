import secrets

from collections import namedtuple
from dataclasses import dataclass
from typing import Optional

import arrow

from passlib.hash import bcrypt
from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session
from werkzeug.datastructures import Authorization as AuthorizationHeader

from src.pizzaapp.defaults import ACCESS_TOKEN_VALID_TIME, MAX_REFRESH_TOKENS
from src.pizzaapp.tables import AccessToken, DeliveryUser, RefreshToken
from src.pizzaapp.utils import decode_base64

AuthentificationInfo = namedtuple("AuthentificationInfo", ["username", "pw_hash"])


def generate_token() -> str:
    """Generate a new refresh or access token."""
    token = secrets.token_hex(32)
    return token


def get_auth_info(authorization: AuthorizationHeader) -> Optional[AuthentificationInfo]:
    """Get authentication information from a request.

    :param authorization: The authorization header from the request.
    """
    if authorization is None:
        return None

    if not authorization.type == "basic":
        return None

    username = authorization.username
    pw_hash = authorization.password
    auth_info = AuthentificationInfo(username, pw_hash)

    return auth_info


def get_delivery_user_auth_info(
    session: Session, auth_info: AuthentificationInfo
) -> Optional[DeliveryUser]:
    """Check if there is a user for which the authentication information is valid.

    :returns: The DeliveryUser if the auth info is valid, None if
        the auth info is invalid (i.e. wrong username or password).
    """
    stmt = select(DeliveryUser).where(DeliveryUser.username == auth_info.username)
    delivery_user = session.execute(stmt).scalar_one_or_none()
    if delivery_user is None:
        return None

    pw_correct = bcrypt.verify(auth_info.pw_hash, delivery_user.pw_hash)
    if not pw_correct:
        return None

    return delivery_user


def get_delivery_user_user_id(session: Session, user_id: int) -> Optional[DeliveryUser]:
    """Get the delivery user by its user id."""
    stmt = select(DeliveryUser).where(DeliveryUser.user_id == user_id)
    delivery_user = session.execute(stmt).scalar_one_or_none()
    if delivery_user is None:
        return None
    return delivery_user


def check_refresh_token(session: Session, delivery_user: DeliveryUser) -> bool:
    """Check if a refresh token can be issued for a delivery user.

    :returns: True if a new refresh token for the given delivery user can be issued, false if not.
    """
    # fmt: off
    stmt = (
        select(func.count(RefreshToken.refresh_token_id))
        .where(and_(RefreshToken.user_id == delivery_user.user_id))
    )
    # fmt: on
    amount_refresh_tokens = session.execute(stmt).scalar_one()
    if amount_refresh_tokens <= MAX_REFRESH_TOKENS:
        return True
    else:
        print(
            f"Max amount of refresh tokens ({MAX_REFRESH_TOKENS}) "
            "reached for {delivery_user.username}."
        )
        return False


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


@dataclass
class TokenInfo:
    refresh_token: RefreshToken
    access_token: AccessToken

    def response_json(self):
        """Generate a json to send back when responding to a client."""
        return {
            "refresh_token": self.refresh_token.response_json(),
            "access_token": self.access_token.response_json(),
        }


def generate_refresh_token(user_id: int) -> RefreshToken:
    """Generate a new refresh token object.

    :param user_id: The user id for which the refresh token is issued.
    """
    token = generate_token()
    token_valid = True
    device_description = None
    issue_time = arrow.now().int_timestamp

    refresh_token = RefreshToken(
        user_id=user_id,
        refresh_token=token,
        valid=token_valid,
        device_description=device_description,
        issuing_time=issue_time,
    )
    return refresh_token


def generate_access_token() -> AccessToken:
    token = generate_token()
    expiration_time = arrow.now().shift(seconds=ACCESS_TOKEN_VALID_TIME).int_timestamp

    access_token = AccessToken(
        # Refresh token id can't be known at this point because no refresh token was inserted yet.
        refresh_token_id=None,
        access_token=token,
        expiration_time=expiration_time,
    )
    return access_token


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


def store_token_info(session: Session, token_info: TokenInfo, delivery_user: DeliveryUser):
    add_new_tokens(session, token_info, delivery_user)
    session.commit()
    print(f"Stored new refresh and access tokens for delivery user {delivery_user.username}.")


def store_updated_token_info(
    session: Session, token_info: TokenInfo, old_refresh_token: RefreshToken
):
    """Store updated refresh and access tokens to the database.

    In addition to storing the tokens this will also mark the old refresh token as invalid.

    :param old_refresh_token: The refresh token with which the client authenticated
         to create new refresh and access tokens.
    """

    # Due to multithreading we can't be completely go sure that the valid flag on the old
    # refresh token is really still set to true. Thats why retrieve it again.
    real_refresh_token = get_refresh_token(session, old_refresh_token.refresh_token)
    if real_refresh_token is None:
        return
    if real_refresh_token.valid is False:
        # Since responding to the request and executing those lines of code the valid flag was
        # toggled. Return to not create two refresh tokens when only one should be created.
        return

    delivery_user = get_delivery_user_user_id(session, token_info.refresh_token.user_id)
    if delivery_user is None:
        return

    real_refresh_token.valid = False
    for access_token in real_refresh_token.access_tokens:
        session.delete(access_token)
    add_new_tokens(session, token_info)

    session.commit()
    print(
        "Invalidated old refresh token and stored new refresh and access tokens "
        f"for delivery user {delivery_user.username}."
    )
