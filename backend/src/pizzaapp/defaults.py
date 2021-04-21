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
    "refresh_token_description_table": "refresh_token_description",
    "access_token_table": "access_token",
}

# Length of both refresh and access token in characters when the token is represented as hex.
# Should only be even numbers. Uneven numbers will be rounded to down to the next even number.
# For example: 63 -> 62, 24 -> 24 or 49 -> 48.
# Will select a random length out of the range for better security.
TOKEN_LENGTH = range(64, 72 + 1, 2)

# The maximal amount of valid refresh tokens a user can have at the same time.
MAX_REFRESH_TOKENS = 10

# Time access tokens should be marked as valid when they are created.
ACCESS_TOKEN_VALID_TIME = 600  # Value in seconds.

# The transition time is the time a new access token can be already issued when
# the previouse access token is still valid for equal or less the time specified.
# This allows for a smoother and faster access token transition.
ACCESS_TOKEN_TRANSITION_TIME = 20  # Value in seconds.

# A code parsed in the body which allow the app to exactly identify the error.
# For example a code of 701 could signal that the authentication details are invalid.
# This is better and more exact then interpreting a general error code like 401.
# HTTP error codes should be used when responding, but not for error identification.
APP_ERROR_CODES = {
    # App error codes are intentionally completely unsorted.

    # Used if the error wasn't mapped to a specific app error code.
    "error_not_mapped": 0,
    # Username or password is invalid.
    "credentials_invalid": 701,
    # The server is still processing a previouse request. This needs to finish before
    # allowing new requests for the user.
    "requesting_too_fast": 702,
    "reached_refresh_token_limit": 703,
    "invalid_refresh_token": 704,
    # Returned if the access token for the refresh token, which was used for
    # authentication, did not yet expire and isn't in transition time.
    "access_token_not_expired": 705,
    "order_not_valid": 706,
    "invalid_access_token": 707,
}
