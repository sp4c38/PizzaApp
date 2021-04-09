import base64

from collections import namedtuple

AuthInfo = namedtuple("AuthInfo", ["username", "password"])


def get_auth_info(headers) -> AuthInfo:
    """Verify the content of the request has the correct format to be valid for acquiring.

    :param headers: Headers of the token acquiring request.
    """
    authorization = headers["Authorization"]
    auth_parts = authorization.split(" ")
    if len(auth_parts) != 2:
        return None

    auth_type = auth_parts[0]
    if not auth_type == "Basic":
        return None

    credentials_base64 = auth_parts[1]
    try:
        # Encode with ascii as credentials from "Authorization" header
        # must be a base64 encoded string.
        credentials_base64_bytes = credentials_base64.encode("ascii")
    except UnicodeEncodeError:
        return None
    credentials_bytes = base64.b64decode(credentials_base64_bytes)
    credentials = credentials_bytes.decode("utf-8")
    credential_parts = credentials.split(":")
    if len(credential_parts) != 2:
        return None

    username = credential_parts[0]
    password = credential_parts[1]
    auth_info = AuthInfo(username, password)

    return auth_info
