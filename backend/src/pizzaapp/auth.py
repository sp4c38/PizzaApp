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


def get_delivery_user(session: Session, auth_info: AuthentificationInfo) -> Optional[DeliveryUser]:
    """If the auth info is valid this returns the appropiete user.

    :returns: The DeliveryUser if the auth info is valid, None if
        the auth info is invalid (e.g. wrong password).
    """
    stmt = select(DeliveryUser).where(DeliveryUser.username == auth_info.username)
    delivery_user = session.execute(stmt).scalar_one_or_none()
    if delivery_user is None:
        return None

    pw_correct = bcrypt.verify(auth_info.pw_hash, delivery_user.pw_hash)
    if not pw_correct:
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
    auth_parts = authorization.split(" ")  # Note: .split(" ") different than .split()
    if len(auth_parts) != 2:
        return None

    auth_type = auth_parts[0]
    auth_token = auth_parts[1]

    if not auth_type == "Bearer":
        return None

    return auth_token


def get_refresh_token(session: Session, token: str) -> Optional[RefreshToken]:
    """Retrieves the refresh token ORM object.

    :param token: The refresh token for which to get the ORM object.
    :returns: ORM refresh token object if an entry was found, none if no entry was found.
    """
    stmt = select(RefreshToken).where(RefreshToken.refresh_token == token)
    refresh_token = session.execute(stmt).scalar_one_or_none()
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


def store_token_info(session: Session, token_info: TokenInfo, delivery_user: DeliveryUser):
    """Store new refresh and access token to the database.

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
    import IPython;IPython.embed()
    session.commit()
    print(f"Stored new refresh and access token for delivery user {delivery_user.username}.")

