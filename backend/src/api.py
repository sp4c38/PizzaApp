import signal
import threading
import uuid

from queue import Full as QueueFullError, Queue

from box import Box
from flask import abort, Flask, jsonify, make_response, request
from werkzeug.exceptions import default_exceptions

from src.pizzaapp import engine
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.order import store_orders, verify_order
from src.pizzaapp.tables import confirm_required_tables_exist

catalog = Catalog(engine)
kill_event = threading.Event() # Kill event for threads to listen on.
store_orders_queue = Queue()

app = Flask("PizzaApp")


def successful_response(raw_response=None):
    """Wrap a response if the response is successful.

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


@app.route("/catalog/get/")
def get_catalog():
    """Get the product catalog as JSON."""
    catalog_json = catalog.to_json()
    # import IPython;IPython.embed()
    return successful_response(catalog_json)


@app.route("/order/make/", methods=["POST"])
def make_order():
    """Verify the order request and save it to a order store queue.

    The order won't be stored here, but added to a queue which is
    observed by another thread, which then stores the order in the background.
    """
    order_json = request.get_json(silent=True, cache=False)
    order_box = Box(order_json) if order_json is not None else None
    order_valid = verify_order(order_box)
    if not order_valid:
        return error_response(400)

    try:
        store_orders_queue.put(order_box, block=True, timeout=3)
    except QueueFullError:
        return abort(500)

    return successful_response()


def _kill_event_handler(signum, frame):
    kill_event.set()


def main():
    """Main entry point to run the Flask backend.

    This will perform some necessary operations before starting the actual Flask backend.
    """
    confirm_required_tables_exist()

    signal.signal(signal.SIGINT, _kill_event_handler)
    store_orders_thread = threading.Thread(
        name="store_orders", target=store_orders, args=(store_orders_queue,)
    )
    store_orders_thread.start()

    app.run()


if __name__ == "__main__":
    main()
