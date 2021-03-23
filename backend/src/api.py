from flask import Flask

from src.pizzaapp.config import read_config
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.database import DatabaseManager

app = Flask("PizzaApp")

config = read_config()
db_manager = DatabaseManager(config.db.path)
catalog = Catalog()
catalog.construct(db_manager)


@app.route("/catalog/")
def get_catalog():
    from flask import jsonify

    # import IPython;IPython.embed()
    print("Got catalog request")
    return "Test"


if __name__ == "__main__":
    app.run()
