"""Run the flask app and coordinate web application tasks."""

import signal
import sys
import threading

from queue import Queue

import arrow

from box import Box
from flask import Flask, request
from loguru import logger
from sqlalchemy.orm import Session

from pizzaapp.app import auth
from pizzaapp.app import engine
from pizzaapp.app import order
from pizzaapp.app import store
from pizzaapp.app import utils
from pizzaapp.app.catalog import Catalog
from pizzaapp.app.store import StoreOperation
from pizzaapp.app.tables import confirm_required_tables_exist
from pizzaapp.app.utils import error_response

catalog = Catalog(engine)

store_queue = Queue()
delivery_user_locks = {}

app = Flask("PizzaApp")
kill_event = threading.Event()  # Kill event for threads to listen on.


@app.route("/get/catalog/")
def get_catalog():
    """Get the product catalog as JSON."""
    catalog_json = catalog.to_json()
    return catalog_json


@app.route("/order/make/", methods=["POST"])
def order_make():
    """Hand in a new order."""
    body = utils.get_body_box(request)
    if body is None:
        return error_response(400)
    new_order = order.get_new_order(catalog, body)
    if new_order is None:
        logger.info("Order request json is invalid.")
        return error_response(400, "order_not_valid")

    store_operation = StoreOperation(store.simple_store, (new_order,))
    logger.debug("Added order store operation to background queue.")
    store_queue.put_nowait(store_operation)
    return "", 204


@app.route("/order/get_all/", methods=["POST"])
def order_get_all():
    bearer_token = auth.parse_bearer_token(request.headers.get("Authorization"))
    if bearer_token is None:
        return error_response(400)
    with Session(engine) as session:
        if not auth.check_access_token(session, bearer_token):
            error_response(401, "invalid_access_token")
        orders = order.get_all_uncompleted_orders(session)

    orders_json = Box()
    orders_json.orders = [order.to_json() for order in orders]
    orders_json.time = arrow.now().int_timestamp

    return orders_json


@app.route("/auth/login/", methods=["POST"])
def auth_login():
    """Get a refresh and access token credentials are valid."""
    auth_info = auth.get_auth_info(request.authorization)
    if auth_info is None:
        return error_response(400)
    body = utils.get_body_box(request)
    if body is None:
        return error_response(400)
    if "device_description" not in body:
        logger.debug('No "device_description" key is set in the auth login request body.')
        return error_response(400)
    with Session(engine) as session:
        delivery_user = auth.find_delivery_user(session, auth_info)
        if delivery_user is None:
            return error_response(401, "credentials_invalid")

        lock = utils.get_delivery_user_lock(delivery_user_locks, delivery_user.user_id)
        if lock is None:
            return error_response(429, "requesting_too_fast")
        session.refresh(delivery_user)

        if auth.refresh_token_limit_reached(session, delivery_user.user_id) is True:
            lock.release()
            return error_response(403, "reached_refresh_token_limit")

    new_refresh_token = auth.gen_refresh_token(
        user_id=delivery_user.user_id, device_description=body.device_description
    )
    new_access_token = auth.gen_access_token()
    token_info = auth.TokenInfo(new_refresh_token, new_access_token)
    store_operation = StoreOperation(
        auth.store_token_info,
        (lock, token_info),
    )
    store_queue.put_nowait(store_operation)

    logger.debug("Client logged in. Issued new refresh token and access token.")
    return token_info.response_json()


@app.route("/auth/refresh/", methods=["POST"])
def auth_refresh():
    """Get new access and refresh token by authenticating with a valid refresh token.

    This request flow follows RFC-6819 5.2.2.3 to detect malicious refreshes.
    """
    bearer_token = auth.parse_bearer_token(request.headers.get("Authorization"))
    if not bearer_token:
        return error_response(400)
    with Session(engine) as session:
        # Get original refresh token which will be invalidated on successful request.
        origi_refresh_token = auth.get_refresh_token(session, bearer_token)
        if origi_refresh_token is None:
            return error_response(401, "invalid_refresh_token")
        origi_description = origi_refresh_token.description

        lock = utils.get_delivery_user_lock(delivery_user_locks, origi_description.user_id)
        if lock is None:
            return error_response(429, "requesting_too_fast")

        session.refresh(origi_refresh_token)
        session.refresh(origi_description)

    if origi_refresh_token.valid is False:
        # RFC-6819 5.2.2.3 states refresh token rotation. Following this RFC if a invalid refresh token
        # is used all tokens of the user need to be deleted. Thus the user needs to relogin everywhere.
        logger.debug(
            f"Detected old refresh token of user {origi_description.user_id}."
            "Expiring all users current accesses."
        )
        reset_operation = StoreOperation(auth.expire_user_access, (origi_description.user_id,))
        store_queue.put_nowait(reset_operation)
        lock.release()
        return error_response(403, "invalid_refresh_token")

    origi_access_tokens = origi_refresh_token.access_tokens
    if len(origi_access_tokens) > 0:
        if auth.check_expiration_times_valid(origi_access_tokens) is False:
            lock.release()
            return error_response(409, "access_token_not_expired")

    new_refresh_token = auth.gen_refresh_token(
        originated_from=origi_refresh_token.refresh_token_id,
        refers_description=origi_description.description_id,
    )
    new_access_token = auth.gen_access_token()
    token_info = auth.TokenInfo(new_refresh_token, new_access_token)
    store_operation = StoreOperation(
        auth.store_refreshed_token_info,
        (lock, token_info, origi_refresh_token),
    )
    store_queue.put_nowait(store_operation)

    logger.debug("Client refreshed tokens. Issued new refresh token and access token.")
    return token_info.response_json()


def _kill_event_handler(signum, frame):
    """Set the threading kill event flag to true."""
    kill_event.set()
    sys.exit(0)


def main():
    """Main entry point to run the Flask backend.

    This will perform some necessary operations before starting the actual Flask backend.
    """
    logger.info("Starting PizzaApp backend.")

    confirm_required_tables_exist()

    # Threads should check the kill event periodically to check if the program should exit.
    signal.signal(signal.SIGINT, _kill_event_handler)

    store_thread = threading.Thread(
        name="store_orders", target=store.run_store_thread, args=(store_queue, kill_event)
    )
    store_thread.start()

    if __name__ == "__main__":
        app.run()

main()
