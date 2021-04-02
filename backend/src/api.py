from flask import Flask

from src.pizzaapp import engine
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.tables import confirm_required_tables_exist

confirm_required_tables_exist()

catalog = Catalog(engine)

app = Flask("PizzaApp")

# if __name__ == "__main__":
#     app.run()
