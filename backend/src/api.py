import signal
import sys
import threading

from queue import Full as QueueFullError, Queue

from flask import Flask, request

from src.pizzaapp import engine
from src.pizzaapp.auth import check_user_valid, get_auth_info
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.order import run_store_orders, verify_make_order
from src.pizzaapp.tables import confirm_required_tables_exist
from src.pizzaapp.utils import successful_response, error_response, get_request_body_json

catalog = Catalog(engine)
kill_event = threading.Event()  # Kill event for threads to listen on.
store_orders_queue = Queue()

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
    body = get_request_body_json()
    request_valid = verify_make_order(body)
    if not request_valid:
        return error_response(400)

    try:
        store_orders_queue.put(body, block=True, timeout=2)
    except QueueFullError:
        return error_response(500)

    return successful_response()


@app.route("/get/auth/refresh_token/", methods=["POST"])
def acquire_refresh_token():
    """Request a refresh token.

    Username and password need to be sent to the server.
    If this information is correct a refresh token is generated and
    sent back, if not an appropriate response code will be returned.
    """
    headers = request.headers
    auth_info = get_auth_info(headers)
    if auth_info is None:
        return error_response(400)
    user_valid = check_user_valid(auth_info)
    if user_valid is False:
        return error_response(401)
    else:
        return "Valid!"

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

    store_orders_thread = threading.Thread(
        name="store_orders", target=run_store_orders, args=(store_orders_queue, kill_event)
    )
    store_orders_thread.start()


main()

if __name__ == "__main__":
    app.run()
