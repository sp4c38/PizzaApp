from threading import Lock
from typing import Optional

from box import Box
from flask import make_response, Request
from loguru import logger
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

    logger.debug("Sending successful response.")
    response = make_response(response_body)
    return response, 200


def error_response(error_code: int, app_error_key: Optional[int] = None) -> dict:
    """Generates an JSON error response a certain error code.

    Only run this function if a Flask request context exists.

    :param error_code: HTTP error code.
    :param app_error_code: An optional application specific error code. See defaults.py
        file for explanation.
    """
    error = default_exceptions[error_code]()
    body = Box() # Response body
    body.status = "unsuccessful"
    body.error = Box()
    body.error.name = error.name
    body.error.description = error.description
    if app_error_key is not None:
        body.error.app_error_key = app_error_key
    else:
        body.error.app_error_key = "error_not_mapped"
    body.error.app_error_code = APP_ERROR_CODES[body.error.app_error_key]

    logger.info(
        f"Sending error {error_code} response to client with application error code "
        f"{body.error.app_error_key} ({body.error.app_error_code})."
    )
    response = make_response(body)
    return response, error_code


def get_body_box(request: Request) -> Optional[Box]:
    """Get the request body as a Box object if the body is valid JSON,

    :returns: Box object containing the request body if the body is valid JSON,
        none if it's not.
    """
    body_json = request.get_json(silent=True, cache=False)
    if body_json is None:
        body_content = request.data.decode("utf-8")
        logger.debug(
            f'Can\'t get json because the request body is empty or has an invalid format: "{body_content}".'
        )
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
        logger.info(
            f"Couldn't acquire delivery user lock for user {user_id}. "
            "The client may be requesting too fast."
        )
        return None
    return lock
