from collections import namedtuple
from typing import Optional

from passlib.hash import bcrypt
from sqlalchemy import select
from sqlalchemy.orm import Session

from src.pizzaapp import engine
from src.pizzaapp.tables import DeliveryUser
from src.pizzaapp.utils import decode_base64

AuthInfo = namedtuple("AuthInfo", ["username", "pw_hash"])


def get_auth_info(headers) -> Optional[AuthInfo]:
    """Get authentication information from a request.

    :param headers: Headers of the request.
    """
    authorization = headers["Authorization"]
    auth_parts = authorization.split(" ")
    if len(auth_parts) != 2:
        return None

    auth_type = auth_parts[0]
    if not auth_type == "Basic":
        return None

    credentials = decode_base64(auth_parts[1])
    if credentials is None:
        return None
    credential_parts = credentials.split(":", 1)
    if len(credential_parts) != 2:
        return None
    username = credential_parts[0]
    pw_hash = credential_parts[1]
    auth_info = AuthInfo(username, pw_hash)

    return auth_info


def check_user_valid(auth_info) -> bool:
    """Check if the user exists."""
    stmt = (
        select(DeliveryUser.pw_hash)
        .where(DeliveryUser.username == auth_info.username)
    )
    with Session(engine) as session:
        db_delivery_user = session.execute(stmt).one_or_none()
        if db_delivery_user is None:
            return False

    pw_correct = bcrypt.verify(auth_info.pw_hash, db_delivery_user.pw_hash)
    return pw_correct