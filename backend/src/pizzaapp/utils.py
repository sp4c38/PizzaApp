from box import Box
from flask import make_response, request
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


def get_request_body_json() -> Box:
    body_json = request.get_json(silent=True, cache=False)
    body_box = None
    if body_json is not None:
        body_box = Box(body_json)
    return body_box