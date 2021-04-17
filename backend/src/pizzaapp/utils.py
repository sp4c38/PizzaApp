from threading import Lock
from typing import Optional

from box import Box
from flask import make_response, Request
from werkzeug.exceptions import default_exceptions

from src.pizzaapp.defaults import APP_ERROR_CODES


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
        response_body["status"] = "successful"

    response = make_response(response_body)
    return response, 200


def error_response(error_code: int, app_error_code: Optional[int] = None) -> dict:
    """Generates an JSON error response a certain error code.

    Only run this function if a Flask request context exists.

    :param error_code: HTTP error code.
    :param app_error_code: An optional application specific error code. See defaults.py
        file for explanation.
    """
    error = default_exceptions[error_code]()

    response_body = Box()
    response_body.status = "unsuccessful"
    response_body.error = Box()
    response_body.error.name = error.name
    response_body.error.description = error.description
    if app_error_code is not None:
        response_body.error.app_error_code = app_error_code
    else:
        default_app_error_code = APP_ERROR_CODES["no_error_mapping"]
        response_body.error.app_error_code = default_app_error_code

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


def get_delivery_user_lock(all_locks: dict, user_id: int) -> bool:
    """Try to acquire the lock for a certain delivery user id.

    If no lock was created yet for the user id this will create a new lock
    and add it to all_locks.

    :param all_locks: A dictionary containing created delivery user locks.
    :param user_id: The delivery user id for which to acquire the lock.
    :returns: Lock for the user if it could be acquired, None if it could not.
    """
    lock = all_locks.get(user_id)
    if lock is None:
        lock = Lock()
        all_locks[user_id] = lock

    lock_acquired = lock.acquire(blocking=False)

    if lock_acquired is False:
        return None
    return lock
