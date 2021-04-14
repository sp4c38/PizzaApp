from binascii import Error as BasciiError
from base64 import b64decode
from typing import Optional

from box import Box
from flask import make_response, Request
from werkzeug.exceptions import default_exceptions


def successful_response(raw_response=None):
    """Wrap a response if the request is successful.

    If the response is a dictionary this function will set the
    key "status" to "successful" (beaware, this function overwrites
    any existing value).
    Only run this function if a Flask request context exists.

    :param raw_response: Object to return. This object may be of any type.
        If response is None a JSON response with the status key will be returned.
    """
    if raw_response is None:
        raw_response = Box()
    if isinstance(raw_response, dict):
        raw_response["status"] = "successful"
    response = make_response(raw_response)
    return response


def error_response(error_code: int) -> dict:
    """Generates an JSON error response a certain error code.

    Only run this function if a Flask request context exists.
    """
    error = default_exceptions[error_code]()
    raw_response = {
        "status": "unsuccessful",
        "error": {"name": error.name, "description": error.description},
    }
    response = make_response(raw_response)
    return response


def get_json_request_body_box(request: Request) -> Box:
    body_json = request.get_json(silent=True, cache=False)
    body_box = None
    if body_json is not None:
        body_box = Box(body_json)
    return body_box


def decode_base64(b64_encoded_string: str) -> Optional[str]:
    """Decode a base64 string and catch multiple possible exceptions."""
    try:
        # Base64 string should always be encodable using ASCII characters.
        b64_encoded_bytes = b64_encoded_string.encode("ascii")
    except UnicodeEncodeError:
        return None

    try:
        b64_decoded_bytes = b64decode(b64_encoded_bytes, validate=True)
    except BasciiError:
        return None

    try:
        b64_decoded_string = b64_decoded_bytes.decode("utf-8")
    except UnicodeDecodeError:
        return None

    return b64_decoded_string
