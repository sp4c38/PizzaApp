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

    def as_json(self):
        return {"access_token": self.token, "expiration_time": self.expiration_time}


def generate_access_token_info() -> AccessTokenInfo:
    access_token = secrets.token_hex(32)
    issue_time = arrow.now()
    expiration_time = issue_time.shift(seconds=ACCESS_TOKEN_VALID_TIME)
    expiration_timestamp = expiration_time.timestamp
    access_token_info = AccessTokenInfo(access_token, expiration_timestamp)
    return access_token_info


def store_refresh_token(session: Session, refresh_token: str, delivery_user: DeliveryUser):
    """Store a refresh token to the database."""
    table_entry = RefreshToken(user_id=delivery_user.user_id, refresh_token=refresh_token)
    session.add(table_entry)
    session.commit()
    print(f"Issued new refresh token.")


def store_access_token(
    session: Session, access_token_info: AccessTokenInfo, refresh_token: RefreshToken
):
    """Store a access token to the database.

    :param access_token_info: A AccessTokenInfo object describing the access token.
    :param refresh_token: The refresh token provided to get the access token.
    """
    table_entry = AccessToken(
        refresh_token_id=refresh_token.refresh_token_id,
        access_token=access_token_info.token,
        expiration_time=access_token.expiration_time,
    )
    session.add(table_entry)
    session.commit()
    print("Issued a new access token.")
