import signal
import sys
import threading

from queue import Queue

from flask import Flask, request
from sqlalchemy.orm import Session

from src.pizzaapp import auth
from src.pizzaapp import engine
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.order import store_order, verify_make_order
from src.pizzaapp.store import add_to_store_queue, run_store_to_database, StoreOperation
from src.pizzaapp.tables import confirm_required_tables_exist
from src.pizzaapp.utils import error_response, get_body_box, successful_response

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
    body = get_body_box(request)
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

    body = get_body_box(request)
    if body is None:
        return error_response(400)  # No valid JSON body found.
    if not "device_description" in body:
        return error_response(400)  # No "device_description" key set in the body.

    device_description = body.device_description

    with Session(engine) as session:
        delivery_user = auth.get_delivery_user(session, auth_info)
        if delivery_user is None:
            return error_response(401)  # No valid credentials.
        lock = auth.get_delivery_user_lock(delivery_user_locks, delivery_user.user_id)
        if lock is None:
            return error_response(429)
        session.refresh(delivery_user)

        if auth.check_reached_refresh_token_limit(session, delivery_user.user_id):
            lock.release()
            return error_response(403)  # Refresh token limit reached.

        new_refresh_token = auth.gen_refresh_token(delivery_user.user_id, device_description)
        new_access_token = auth.gen_access_token()
        token_info = auth.TokenInfo(new_refresh_token, new_access_token)
        # fmt: off
        store_operation = StoreOperation(auth.store_token_info, (lock, token_info,))
        # fmt: on
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
    with Session(engine) as session:
        # Get original refresh token which will be invalidated on successful request.
        origi_refresh_token = auth.get_refresh_token(session, bearer_token)
        if origi_refresh_token is None:
            return error_response(401)  # Provided refresh token is invalid.
        lock = auth.get_delivery_user_lock(delivery_user_locks, origi_refresh_token.user_id)
        if lock is None:
            return error_response(429)
        session.refresh(origi_refresh_token)

        if origi_refresh_token.valid is False:
            lock.release()
            return error_response(403)

        origi_access_tokens = origi_refresh_token.access_tokens
        if len(origi_access_tokens) > 0:
            if auth.check_access_token_time(origi_refresh_token.access_tokens) is False:
                # Access token didn't expire yet and isn't in transition time.
                lock.release()
                return error_response(409)

        new_refresh_token = auth.gen_refresh_token(origi_refresh_token.user_id)
        new_access_token = auth.gen_access_token()
        token_info = auth.TokenInfo(new_refresh_token, new_access_token)
        # fmt: off
        store_operation = StoreOperation(auth.store_refreshed_token_info, (lock, token_info, origi_refresh_token,))
        # fmt: on
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
