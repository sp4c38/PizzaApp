from flask import Flask

from src.pizzaapp.tables import confirm_required_tables_exist

confirm_required_tables_exist()

app = Flask("PizzaApp")

if __name__ == "__main__":
    app.run()
