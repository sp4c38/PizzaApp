import signal
import sys
import threading
import uuid

from queue import Full as QueueFullError, Queue

from box import Box
from flask import abort, Flask, request

from src.pizzaapp import engine
from src.pizzaapp.auth import get_auth_info
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.order import run_store_orders, verify_make_order
from src.pizzaapp.tables import confirm_required_tables_exist
from src.pizzaapp.utils import successful_response, error_response, get_request_body_json

catalog = Catalog(engine)
kill_event = threading.Event()  # Kill event for threads to listen on.
store_orders_queue = Queue()

app = Flask("PizzaApp")


@app.route("/catalog/get/")
def get_catalog():
    """Get the product catalog as JSON."""
    catalog_json = catalog.to_json()
    return successful_response(catalog_json)


@app.route("/order/make/", methods=["POST"])
def make_order():
    """Verify the order request and save it to a order store queue.

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


@app.route("/token/access/", methods=["POST"])
def 

@app.route("/token/refresh/", methods=["POST"])
def acquire_refresh_token():
    """Aquire a token for a specific user."""
    headers = request.headers
    auth_info = get_auth_info(headers)
    check_


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
