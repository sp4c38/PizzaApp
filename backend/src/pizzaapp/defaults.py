DEFAULT_CONFIG = """\
[pizzaapp]
debug = off

[db]
path = ~/.pizzaapp/db.sqlite3
"""

# Names for required database tables used by the backend.
# NOTE: At startup the backend will check if all tables exist. It'll exit if not so.
# Use the table insert and delete CLI tool program to make the database ready before
# starting the backend.
NAMES_OF_TABLES = {
    "category_table": "category",
    "item_table": "item",
    "item_price_table": "item_price",
    "item_speciality_table": "item_speciality",
    "order_table": "order_details",
    "order_item_table": "order_item",
    "delivery_user_table": "delivery_user",
    "refresh_token_table": "refresh_token",
    "access_token_table": "access_token",
}

# The maximal amount of refresh tokens a user can have.
MAX_REFRESH_TOKENS = 10
# Time in seconds access tokens should be marked as valid when new ones are created.
ACCESS_TOKEN_VALID_TIME = 600
