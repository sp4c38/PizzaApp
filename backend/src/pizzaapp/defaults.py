from pathlib import Path

from box import Box

DEFAULT_CONFIG = """\
[db]
path = ~/.pizzaapp/db.sqlite3
"""

# Names for required database tables used by the backend.
# NOTE: At startup the backend will check if all tables exist. It'll exit if not so. Use the
# table insert and delete CLI tool program to make the database ready before
# starting the backend.
NAMES_OF_TABLES = {
    "category_table": "category",
    "item_table": "item",
    "price_table": "price",
    "item_speciality_table": "item_speciality",
    "order_table": "order",
    "order_item_table": "order_item",
    "delivery_user_table": "delivery_user",
}
