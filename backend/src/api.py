from flask import Flask, jsonify, request

from src.pizzaapp import engine
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.order import save_order, verify_order
from src.pizzaapp.tables import confirm_required_tables_exist

confirm_required_tables_exist()

catalog = Catalog(engine)

app = Flask("PizzaApp")


@app.route("/catalog/get/")
def get_catalog():
    """Get the product catalog as JSON."""
    catalog_json = catalog.to_json()
    return jsonify(catalog_json)

@app.route("/order/make/", methods=["POST"])
def make_order():
    """Verify and save a new order."""
    order_json = request.get_json(silent=True, cache=False)
    order_valid = verify_order(order_json)
    return ""

# if __name__ == "__main__":
#     app.run()
