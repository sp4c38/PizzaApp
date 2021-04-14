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


def get_delivery_user_auth_info(session: Session, auth_info: AuthentificationInfo) -> Optional[DeliveryUser]:
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
class AccessTokenInfo:
    token: str
    expiration_time: int

    def response_json(self):
        """Generate a json to send back when responding to a client.

        This does not have to include all attributes, as some may not be exposed.
        """
        jsoned = {"token": self.token, "expiration_time": self.expiration_time}
        return jsoned


@dataclass
class RefreshTokenInfo:
    token: str
    valid: bool
    issuing_time: int

    def response_json(self):
        """Generate a json to send back when responding to a client.

        This does not have to include all attributes, as some may not be exposed.
        """
        jsoned = {"token": self.token}
        return jsoned


@dataclass
class TokenInfo:
    refresh_token: RefreshTokenInfo
    access_token: AccessTokenInfo

    def response_json(self):
        """Generate a json to send back when responding to a client."""
        return {
            "refresh_token": self.refresh_token.response_json(),
            "access_token": self.access_token.response_json(),
        }


def generate_refresh_token() -> RefreshTokenInfo:
    refresh_token = generate_token()
    refresh_token_valid = True
    issue_time = arrow.now().int_timestamp

    refresh_token_info = RefreshTokenInfo(refresh_token, refresh_token_valid, issue_time)
    return refresh_token_info


def generate_access_token() -> AccessTokenInfo:
    access_token = generate_token()
    expiration_time = arrow.now().shift(seconds=ACCESS_TOKEN_VALID_TIME).int_timestamp

    access_token_info = AccessTokenInfo(access_token, expiration_time)
    return access_token_info


def add_new_tokens(session: Session, token_info: TokenInfo, delivery_user: DeliveryUser):
    """Add new refresh and access tokens to the session.

    :param session: Session object to which to add the new ORM token objects.
    :param token_info: TokenInfo object including information about both token types.
    :param delivery_user: The user for which the tokens were issued.
    """
    refresh_token = token_info.refresh_token
    access_token = token_info.access_token
    refresh_token_entry = RefreshToken(
        user_id=delivery_user.user_id,
        refresh_token=refresh_token.token,
        valid=refresh_token.valid,
        issuing_time=refresh_token.issuing_time
    )
    session.add(refresh_token_entry)
    session.flush()
    access_token_entry = AccessToken(
        refresh_token_id=refresh_token_entry.refresh_token_id,
        access_token=access_token.token,
        expiration_time=access_token.expiration_time,
    )
    session.add(access_token_entry)

    
def store_token_info(session: Session, token_info: TokenInfo, delivery_user: DeliveryUser):
    add_new_tokens(session, token_info, delivery_user)
    session.commit()
    print(f"Stored new refresh and access tokens for delivery user {delivery_user.username}.")


def store_updated_token_info(session: Session, token_info: TokenInfo, old_refresh_token: RefreshToken):
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

    delivery_user = get_delivery_user_user_id(session, real_refresh_token.user_id)
    if delivery_user is None:
        return

    real_refresh_token.valid = False
    for access_token in real_refresh_token.access_tokens:
        session.delete(access_token)
    add_new_tokens(session, token_info, delivery_user)

    session.commit()
    print(
        "Invalidated old refresh token and stored new refresh and access tokens "
        f"for delivery user {delivery_user.username}."
    )
