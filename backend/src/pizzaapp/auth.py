from collections import namedtuple
from typing import Optional

from passlib.hash import bcrypt
from sqlalchemy import and_, func, select
from sqlalchemy.orm import Session
from werkzeug.datastructures import Authorization as AuthorizationHeader

from src.pizzaapp.tables import DeliveryUser, RefreshToken
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


def get_uacid(headers) -> Optional[str]:
    """Retrieve and validate the Unique Application Context ID.

    The UACID is a id generated on-device each time the user logs in.
    It allows the backend to map refresh tokens to the user *and* the device.
    Thus a single user is able to login on multiple devices.

    :param headers: Headers of the request.
    """
    # Value in the UACID header should be a UUID1 in hex format.
    uacid = headers["UACID"]
    if len(uacid) != 32:
        return None
    return uacid


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


def check_refresh_token(session: Session, delivery_user: DeliveryUser, uacid: str) -> bool:
    """Check if a refresh token should be issued for a certain uacid and delivery user.

    :returns: True if a new refresh token with the given UACID for the given delivery user
        can be issued, false if not.
    """
    # fmt: off
    stmt = (
        select(func.count(RefreshToken.refresh_token_id))
        .where(
            and_(RefreshToken.user_id == DeliveryUser.user_id, RefreshToken.uacid == uacid)
        )
    )
    # fmt: on
    number_matching_refresh_token = session.execute(stmt).scalar_one()
    if number_matching_refresh_token == 0:
        return True
    elif number_matching_refresh_token >= 1:
        print("Won't issue new refresh token as one already exists for specified UACID.")
        return False


def store_refresh_token(session: Session, uacid: str, delivery_user: DeliveryUser):
    """Store a refresh token to the database."""
    print(f"Created new refresh token for user {delivery_user.username}.")

    table_entry = RefreshToken(
        user_id=delivery_user.user_id, refresh_token=refresh_token, uacid=uacid
    )
    session.add(table_entry)
    session.commit()
    print(f"Issued new refresh token for user {delivery_user.username}.")

    return refresh_token
