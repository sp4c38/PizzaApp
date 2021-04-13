from collections import namedtuple

from box import Box
from sqlalchemy import select
from sqlalchemy.orm import Session

from src.pizzaapp.tables import Item, Order, OrderItem

# Named tuple used when verifying that a field has a certain type.
Field = namedtuple("Field", ["name", "type_"])


def _check_fields(dict_: Box, fields: list[Field]) -> bool:
    """Check if fields are in the parsed dictionary and have correct type.

    Function only checks keys of the dictionary which are in the root depth.
    """

    for field in fields:
        if field[0] not in dict_:
            print(f"Field {field[0]} not contained in {dict_}.")
            return False
        field_value = dict_[field.name]
        if not isinstance(field_value, field.type_):
            print(f"Type of field {field[0]} in {dict_} is not required type {field[1]}.")
            return False
    return True


def verify_make_order(order: Box) -> bool:
    """Verify the content of the request has the correct format to make an order.

    :param order: The request body.
    """
    SUCCESSFUL = True
    UNSUCCESSFUL = False

    if order is None:
        print("No valid order was sent when requesting to store a new order.")
        return False

    # Prefix o stands for order and is used to avoid name collisions
    # because .items is a Box method.
    sections = [
        Field("odetails", dict),
        Field("oitems", list),
    ]
    if not _check_fields(order, sections):
        print("Request has wrong order sections.")
        return UNSUCCESSFUL

    items_ordered = len(order.oitems)
    if items_ordered < 1 or items_ordered > 100:
        return UNSUCCESSFUL

    detail_fields = [
        Field("first_name", str),
        Field("last_name", str),
        Field("street", str),
        Field("city", str),
        Field("postal_code", str),
    ]
    if not _check_fields(order.odetails, detail_fields):
        print("Request has wrong order detail fields.")
        return UNSUCCESSFUL

    item_fields = [
        Field("item_id", int),
        Field("quantity", int),
    ]
    for item in order.oitems:
        if not isinstance(item, dict):
            return UNSUCCESSFUL
        if not _check_fields(item, item_fields):
            print("Request has at least one ordered item which has wrong item fields.")
            return UNSUCCESSFUL

    print("Order valid.")
    return SUCCESSFUL


def check_items_valid(session: Session, item_ids: list[int]) -> bool:
    for iid in item_ids:
        stmt = select(Item).where(Item.item_id == iid)
        results = session.execute(stmt)
        results_count = len(results.fetchall())
        if results_count != 1:
            return False
    return True


def store_order(session: Session, order: Box):
    """Store a single order to the database.

    :param order: The order as a dictionary wrapped in a Box object.
    """
    item_ids = [item.item_id for item in order.oitems]
    if not check_items_valid(session, item_ids):
        print(f"Order has at least one invalid item ID: {order.oitems}.")
        return

    details = order.odetails
    new_order = Order(
        first_name=details.first_name,
        last_name=details.last_name,
        street=details.street,
        city=details.city,
        postal_code=details.postal_code,
    )
    session.add(new_order)
    session.flush()

    for item in order.oitems:
        new_item = OrderItem(
            order_id=new_order.order_id,
            item_id=item.item_id,
            unit_price=3.99,
            quantity=item.quantity,
        )
        session.add(new_item)

    session.flush()
    session.commit()
    print("Added new order to the database.")
