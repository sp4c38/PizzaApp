from flask import Flask, jsonify

from src.pizzaapp import engine
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.tables import confirm_required_tables_exist

confirm_required_tables_exist()

catalog = Catalog(engine)

app = Flask("PizzaApp")


@app.route("/get_catalog/")
def get_catalog():
    catalog_json = catalog.to_json()
    return jsonify(catalog_json)


# if __name__ == "__main__":
#     app.run()
