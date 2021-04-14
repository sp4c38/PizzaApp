import secrets
import signal
import sys
import threading

from queue import Queue

from flask import Flask, request
from sqlalchemy.orm import Session

from src.pizzaapp import engine
from src.pizzaapp.auth import (
    check_refresh_token,
    get_auth_info,
    get_delivery_user,
    get_uacid,
    store_refresh_token,
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


@app.route("/make/order/", methods=["POST"])
def make_order():
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


@app.route("/get/auth/refresh_token/", methods=["POST"])
def acquire_refresh_token():
    """Request a refresh token.

    Username and password need to be sent to the server.
    If this information is correct a refresh token is generated and
    sent back, if not an appropriate response code will be returned.
    """
    authorization_header = request.authorization
    auth_info = get_auth_info(authorization_header)
    if auth_info is None:
        return error_response(400)

    uacid = get_uacid(request.headers)
    if uacid is None:
        return error_response(400)

    with Session(engine) as session:
        delivery_user = get_delivery_user(session, auth_info)
        if delivery_user is None:
            return error_response(401)

        make_new_refresh_token = check_refresh_token(session, delivery_user, uacid)
        if not make_new_refresh_token:
            return error_response(409)

        refresh_token = secrets.token_hex(32)

        store_operation = StoreOperation(store_refresh_token, (uacid, delivery_user,))
        if not add_to_store_queue(store_operation):
            return error_response(500)

    return refresh_token


@app.route("/get/auth/session_token/", methods=["POST"])
def acquire_session_token():
    """Request a session token by using a refresh token."""


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
