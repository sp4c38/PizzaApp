from __future__ import annotations

import hashlib
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


@dataclass
class AuthentificationInfo:
    username: str
    pw_hash: str


@dataclass
class BasicToken:
    token_hex: str
    token_hash: str

    @classmethod
    def _hash_token(cls, token_bytes: bytes) -> str:
        """Hash the token hex with sha256."""

        previouse_token_bytes = None
        for _ in range(5000):
            sha = hashlib.sha256()
            if previouse_token_bytes is None:
                sha.update(token_bytes)
            else:
                sha.update(previouse_token_bytes)

        token_hash = previouse_token_bytes.hex()

        return token_hash

    @classmethod
    def from_hex(cls, token_hex: str) -> BasicToken:
        """Create a BasicToken instance by providing only the token hex.

        The token hash will be automatically generated.
        """
        token = bytes.fromhex(token_hex)
        token_hash = cls._hash_token(token)
        return cls(token_hex, token_hash)

    @classmethod
    def generate(cls) -> BasicToken:
        token = secrets.token_bytes()
        token_hex = token.hex()
        token_hash = cls._hash_token(token)
        return cls(token_hex, token_hash)


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

    if not auth_type.lower() == "bearer":
        return None

    if auth_token == "":
        return None

    return auth_token


def get_refresh_token(session: Session, token_hex: str) -> Optional[RefreshToken]:
    """Get the refresh token record associated with the token hex.

    :param token_hex: The token as hex. The function will compute this hex to find the
        associated refresh token record.
    :returns: Refresh token ORM object if an entry was found, none if no entry was found.
    """
    basic_token = BasicToken.from_hex(token_hex)
    stmt = select(RefreshToken).where(RefreshToken.refresh_token_hash == basic_token.token_hash)
    refresh_token = session.execute(stmt).scalar_one_or_none()
    return refresh_token


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


def gen_refresh_token(
    originated_from: Optional[int] = None,
    refers_description: Optional[int] = None,
    user_id: Optional[int] = None,
    device_description: Optional[str] = None,
) -> RefreshToken:
    """Generate a new refresh token object.

    :param originated_from: If set this will identify the new refresh token as a successor
        of the originator id provided.
    :param refers_description: If set doesn't generate a new refresh token description
        but instead uses the parsed description id.
    :param user_id: The user id for which the refresh token is issued. If refers_description
        is set this argument will be ignored.
    :param device_description: A device description added to the refresh token description. If
        refers_description is set this argument will be ignored.
    """
    optional_args = {}
    if refers_description is None:
        description = RefreshTokenDescription(
            user_id=user_id,
            device_description=device_description,
        )
        optional_args["description"] = description
    else:
        optional_args["description_id"] = refers_description

    token = BasicToken.generate()
    refresh_token = RefreshToken(
        originated_from=originated_from,
        refresh_token_hash=token.token_hash,
        refresh_token=token.token_hex,
        valid=True,
        issuing_time=arrow.now().int_timestamp,
        **optional_args,
    )
    return refresh_token


def gen_access_token() -> AccessToken:
    """Generate a new access token object."""
    now = arrow.now()
    expiration_time = now.shift(seconds=defaults.ACCESS_TOKEN_VALID_TIME).int_timestamp
    token = BasicToken.generate()
    access_token = AccessToken(
        # Refresh token id can't be known at this point because no refresh token was inserted yet.
        refresh_token_id=None,
        access_token_hash=token.token_hash,
        access_token=token.token_hex,
        expiration_time=expiration_time,
    )
    return access_token


def refresh_token_limit_not_reached(session: Session, user_id: int) -> bool:
    """Check if the refresh token limit for a certain user was not reached."""
    # fmt: off
    stmt = (
        select(func.count(RefreshToken.refresh_token_id))
        .select_from(RefreshTokenDescription)
        .join(RefreshToken)
        .where(
            and_(
                RefreshTokenDescription.user_id == user_id,
                RefreshToken.valid == True 
            )
        )
    )
    # fmt: on

    # Add one to count new refresh token.
    amount_refresh_tokens = session.execute(stmt).scalar_one() + 1
    if amount_refresh_tokens > defaults.MAX_REFRESH_TOKENS:
        return False

    return True


def check_expiration_times_valid(access_tokens: list[AccessToken]) -> bool:
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
    session: Session,
    lock: Lock,
    token_info: TokenInfo,
    origi_refresh_token: RefreshTokenDescription,
):
    """Store refreshed token info (tokens retrieved with a refresh token).

    In addition to storing the tokens this will also mark the old refresh token as invalid.

    :param origi_refresh_token: The original refresh token with which was used to authenticate.
    """

    session.add(origi_refresh_token)
    origi_refresh_token.valid = False

    add_new_tokens(session, token_info)

    session.commit()
    lock.release()
