import signal
import sys
import threading

from queue import Queue

from flask import Flask, request
from sqlalchemy.orm import Session

from src.pizzaapp import auth
from src.pizzaapp import engine
from src.pizzaapp import utils
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.defaults import APP_ERROR_CODES
from src.pizzaapp.order import store_order, verify_make_order
from src.pizzaapp.store import add_to_store_queue, run_store_to_database, StoreOperation
from src.pizzaapp.tables import confirm_required_tables_exist
from src.pizzaapp.utils import error_response, successful_response

catalog = Catalog(engine)

store_queue = Queue()
delivery_user_locks = {}

app = Flask("PizzaApp")
kill_event = threading.Event()  # Kill event for threads to listen on.


@app.route("/get/catalog/")
def get_catalog():
    """Get the product catalog as JSON."""
    catalog_json = catalog.to_json()
    return successful_response(catalog_json)


@app.route("/order/make", methods=["POST"])
def order_make():
    """Hand in a new order.

    The order won't be stored here, but added to a queue which is
    observed by another thread, which then stores the order in the background.
    """
    body = utils.get_body_box(request)
    request_valid = verify_make_order(body)
    if not request_valid:
        return error_response(400)

    if not add_to_store_queue(StoreOperation(store_order, (body,))):
        return error_response(500)

    return successful_response()


@app.route("/auth/login/", methods=["POST"])
def auth_login():
    """Get a refresh and access token credentials are valid."""
    authorization_header = request.authorization
    auth_info = auth.get_auth_info(authorization_header)
    if auth_info is None:
        return error_response(400, "Authorization header not given or in wrong format.")

    body = utils.get_body_box(request)
    if body is None:
        return error_response(400)  # No valid JSON body found.
    if not "device_description" in body:
        return error_response(400)  # No "device_description" key set in the body.
    device_description = body.device_description

    with Session(engine) as session:
        delivery_user = auth.find_delivery_user(session, auth_info)
        if delivery_user is None:
            return error_response(401, APP_ERROR_CODES["credentials_invalid"])

        lock = utils.get_delivery_user_lock(delivery_user_locks, delivery_user.user_id)
        if lock is None:
            return error_response(429, APP_ERROR_CODES["requesting_too_fast"])
        session.refresh(delivery_user)

        if auth.refresh_token_limit_not_reached(session, delivery_user.user_id) is False:
            lock.release()
            return error_response(403, APP_ERROR_CODES["reached_refresh_token_limit"])

        new_refresh_token = auth.gen_refresh_token(
            user_id=delivery_user.user_id, device_description=device_description
        )
        new_access_token = auth.gen_access_token()
        token_info = auth.TokenInfo(new_refresh_token, new_access_token)
        store_operation = StoreOperation(
            auth.store_token_info,
            (lock, token_info),
        )
        if not add_to_store_queue(store_queue, store_operation):
            return error_response(500)

    print(f"Issued new refresh and access token for delivery user {delivery_user.username}.")
    return successful_response(token_info.response_json())


@app.route("/auth/refresh/", methods=["POST"])
def auth_refresh():
    """Get new access and refresh token.

    Get a new access token by providing a valid refresh token.
    Following RFC-6819 5.2.2.3 this will also issue and return a new refresh token.
    """
    bearer_token = auth.parse_bearer_token(request.headers.get("Authorization"))
    if not bearer_token:
        return error_response(400)
    with Session(engine) as session:
        # Get original refresh token which will be invalidated on successful request.
        origi_refresh_token = auth.get_refresh_token(session, bearer_token)
        if origi_refresh_token is None:
            return error_response(401, APP_ERROR_CODES["invalid_refresh_token"])
        origi_description = origi_refresh_token.description

        lock = utils.get_delivery_user_lock(delivery_user_locks, origi_description.user_id)
        if lock is None:
            return error_response(429, APP_ERROR_CODES["requesting_too_fast"])

        session.refresh(origi_refresh_token)
        session.refresh(origi_description)

        if origi_refresh_token.valid is False:
            # Following RFC-6819 the usage of an invalidated refresh token means that a
            # attacker probably stole refresh tokens. To prevent further harm all refresh
            # and access tokens for a user are deleted. This requires the user to log back in
            # on all devices.
            reset_operation = StoreOperation(auth.expire_user_access, (origi_description.user_id,))
            if not add_to_store_queue(store_queue, reset_operation):
                return error_response(500)
            lock.release()
            return error_response(403)

        origi_access_tokens = origi_refresh_token.access_tokens
        if len(origi_access_tokens) > 0:
            if auth.check_expiration_times_valid(origi_access_tokens) is False:
                # Access token didn't expire yet and isn't in transition time.
                lock.release()
                return error_response(409, APP_ERROR_CODES["access_token_not_expired"])

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
        if not add_to_store_queue(store_queue, store_operation):
            return error_response(500)

    return successful_response(token_info.response_json())


def _kill_event_handler(signum, frame):
    """Set the threading kill event flag to true."""
    kill_event.set()
    sys.exit(0)


def main():
    """Main entry point to run the Flask backend.

    This will perform some necessary operations before starting the actual Flask backend.
    """
    print("Starting PizzaApp backend.")
    confirm_required_tables_exist()

    # Threads should check the kill event periodically to check
    # if the program should exit.
    signal.signal(signal.SIGINT, _kill_event_handler)

    store_thread = threading.Thread(
        name="store_orders", target=run_store_to_database, args=(store_queue, kill_event)
    )
    store_thread.start()


main()

if __name__ == "__main__":
    app.run()
