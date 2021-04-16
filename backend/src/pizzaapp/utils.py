from binascii import Error as BasciiError
from base64 import b64decode
from typing import Generic, Optional, TypeVar

from box import Box
from flask import make_response, Request
from werkzeug.exceptions import default_exceptions


def successful_response(response_body=None):
    """Wrap a response if the request is successful.

    If the response body is a dictionary this function will set the
    key "status" to "successful" (beaware, this function overwrites
    any existing value).

    Only run this function if a Flask request context exists.

    :param response_body: The body of the response.
    """
    if response_body is None:
        response_body = Box()
    if isinstance(response_body, dict):
        response_body.status = "successful"

    response = make_response(response_body)
    return response, 200


def error_response(error_code: int, description: Optional[str] = None) -> dict:
    """Generates an JSON error response a certain error code.

    Only run this function if a Flask request context exists.
    """
    error = default_exceptions[error_code]()

    response_body = Box()
    response_body.status = "unsuccessful"
    response_body.error = Box()
    response_body.error.name = error.name
    if description is not None:
        response_body.error.description = description
    else:
        response_body.error.description = error.description

    response = make_response(response_body)
    return response, error_code


def get_body_box(request: Request) -> Optional[Box]:
    """Get the request body as a Box object if the body is valid JSON,

    :returns: Box object containing the request body if the body is valid JSON,
        none if it's not.
    """
    body_json = request.get_json(silent=True, cache=False)
    if body_json is None:
        return None
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
