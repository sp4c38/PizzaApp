import signal
import sys
import threading

from queue import Queue

from flask import Flask, request
from sqlalchemy.orm import Session

from src.pizzaapp import engine
from src.pizzaapp.auth import (
    TokenInfo,
    check_refresh_token,
    generate_refresh_token,
    generate_access_token,
    get_auth_info,
    get_delivery_user_auth_info,
    get_refresh_token,
    parse_bearer_token,
    store_token_info,
    store_updated_token_info,
)
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.order import store_order, verify_make_order
from src.pizzaapp.store import add_to_store_queue, run_store_to_database, StoreOperation
from src.pizzaapp.tables import confirm_required_tables_exist
from src.pizzaapp.utils import successful_response, error_response, get_json_request_body_box

catalog = Catalog(engine)
kill_event = threading.Event()  # Kill event for threads to listen on.
store_queue = Queue()

app = Flask("PizzaApp")


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
    body = get_json_request_body_box(request)
    request_valid = verify_make_order(body)
    if not request_valid:
        return error_response(400)

    if not add_to_store_queue(StoreOperation(store_order, (body,))):
        return error_response(500)

    return successful_response()


@app.route("/auth/login/", methods=["POST"])
def auth_login():
    """Get a refresh and session token if the user credentials are valid."""
    authorization_header = request.authorization
    auth_info = get_auth_info(authorization_header)
    if auth_info is None:
        return error_response(400)

    with Session(engine) as session:
        delivery_user = get_delivery_user_auth_info(session, auth_info)
        if delivery_user is None:
            return error_response(401)

        make_new_refresh_token = check_refresh_token(session, delivery_user)
        if not make_new_refresh_token:
            return error_response(409)

        # Contains new access and refresh token.
        new_refresh_token = generate_refresh_token(delivery_user.user_id)
        new_access_token = generate_access_token()
        token_info = TokenInfo(new_refresh_token, new_access_token)

        # fmt: off
        store_operation = StoreOperation(store_token_info, (token_info, delivery_user,))
        # fmt: on
        if not add_to_store_queue(store_queue, store_operation):
            return error_response(500)

    print(f"Issued new refresh and access token for delivery user {delivery_user.username}.1")
    return successful_response(token_info.response_json())


@app.route("/auth/get/access_token/", methods=["POST"])
def auth_get_access_token():
    """Get a new access and refresh token.

    Get a new access token by providing a valid refresh token.
    Following RFC-6819 5.2.2.3 this will also issue and return a new refresh token.
    """
    bearer_token = parse_bearer_token(request.headers.get("Authorization"))
    with Session(engine) as session:
        refresh_token = get_refresh_token(session, bearer_token)
        if refresh_token is None:
            return error_response(401)

        if refresh_token.valid == False:
            # If the refresh token is invalid this is an indicator therfor that this refresh token
            # was stolen and the attacker tried to use it. If this happens all refresh and access
            # tokens of the delivery user need to be invalidated to prevent further harm.
            return error_response(401)

        new_refresh_token = generate_refresh_token(refresh_token.user_id)
        new_access_token = generate_access_token()
        token_info = TokenInfo(new_refresh_token, new_access_token)

        # fmt: off
        store_operation = StoreOperation(store_updated_token_info, (token_info, refresh_token,))
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
