from typing import Optional

from box import Box
from loguru import logger
from sqlalchemy import select
from sqlalchemy.orm import Session

from src.pizzaapp import catalog as catalog_helper
from src.pizzaapp.catalog import Catalog
from src.pizzaapp.tables import Item, Order, OrderItem
from src.pizzaapp.utils import check_fields, Field


def check_order_body(body: Box) -> bool:
    """Check if all sections and fields exist, have the valid format and have the valid type."""
    sections = [Field("odetails", dict), Field("oitems", list)]
    if not check_fields(body, sections):
        logger.debug(f"Wrong order sections in request.")
        return False

    items_ordered = len(body.oitems)
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
    if not check_fields(body.odetails, detail_fields):
        logger.debug(f"Wrong order detail section in request.")
        return False
    if not body.odetails["postal_code"].isdecimal():
        logger.debug("Postal code field of order details contains characters other than numbers.")
        return False

    item_fields = [Field("item_id", int), Field("quantity", int)]
    for item in body.oitems:
        if not isinstance(item, dict):
            return False
        if not check_fields(item, item_fields):
            logger.debug(f"Wrong fields for an item in items section.")
            return False
    return True


def get_new_order(catalog: Catalog, body: Box) -> Optional[Order]:
    """Get a new order from a request body."""
    if body is None:
        logger.debug("No order in request body.")
        return None

    order_body_valid = check_order_body(body)
    if not order_body_valid:
        return None

    order = Order(
        first_name=body.odetails.first_name,
        last_name=body.odetails.last_name,
        street=body.odetails.street,
        city=body.odetails.city,
        postal_code=body.odetails.postal_code,
    )
    for item in body.oitems:
        order_item = OrderItem(item_id=item.item_id, unit_price=0, quantity=item.quantity)
        order.items.append(order_item)

    if not catalog_helper.items_valid(catalog, order.items):
        return None

    return order
