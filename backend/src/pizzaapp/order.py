"""Handle orders made by clients.

For example includes functions to extract order data from a HTTP request.
"""

from typing import Optional

from box import Box
from loguru import logger
from sqlalchemy.orm import selectinload, Session

from src.pizzaapp import catalog as catalog_helper
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.tables import Order, OrderItem
from src.pizzaapp.utils import check_fields, Field


def check_order_body(body: Box) -> bool:
    """Check if all sections and fields exist, have the valid format and have the valid type."""
    sections = [Field("details", dict), Field("items", list)]
    if not check_fields(body, sections):
        logger.debug("Wrong order sections in request.")
        return False

    items_ordered = len(body["items"])
    if items_ordered < 1 or items_ordered > 50:
        logger.debug(f"Amount of items ({items_ordered}) is not in required range.")
        return False

    detail_fields = [
        Field("first_name", str),
        Field("last_name", str),
        Field("street", str),
        Field("city", str),
        Field("postal_code", str),
    ]
    if not check_fields(body.details, detail_fields):
        logger.debug("Wrong order detail section in request.")
        return False
    if not body.details.postal_code.isdecimal():
        logger.debug("Postal code field of order details contains characters other than numbers.")
        return False

    item_fields = [Field("item_id", int), Field("quantity", int)]
    for item in body["items"]:
        if not isinstance(item, dict):
            return False
        if not check_fields(item, item_fields):
            logger.debug("Wrong fields for an item in items section.")
            return False
    return True


def get_new_order(catalog: Catalog, body: Box) -> Optional[Order]:
    """Get a new order from a request body."""
    order_body_valid = check_order_body(body)
    if not order_body_valid:
        return None

    order = Order(
        first_name=body.details.first_name,
        last_name=body.details.last_name,
        street=body.details.street,
        city=body.details.city,
        postal_code=body.details.postal_code,
    )
    for item in body["items"]:
        order_item = OrderItem(item_id=item.item_id, unit_price=0, quantity=item.quantity)
        order.items.append(order_item)

    if not catalog_helper.items_valid(catalog, order.items):
        return None

    return order


def get_all_uncompleted_orders(session: Session) -> list[Order]:
    """Get all currently uncompleted orders."""
    orders = session.query(Order).options(selectinload(Order.items)).all()
    return orders
