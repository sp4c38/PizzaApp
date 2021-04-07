from collections import namedtuple

from box import Box

# Named tuple used when verifying that a field has a certain type.
Field = namedtuple("Field", ["name", "type_"])

def save_order():
    """Save new order to the database."""
    pass


def _check_fields(dict_: Box, fields: tuple[Field]) -> bool:
    """Check if fields are in the parsed dictionary and have correct type.

    Function only checks keys of the dictionary which are in the root depth.
    """

    for field in fields:
        if field[0] not in dict_:
            return False
        field_value = dict_[field.name]
        if not isinstance(field_value, field.type_):
            return False
    return True


def verify_order(order_json: dict) -> bool:
    """Verify if the order has the valid format.

    :param order_json: The order as a dictionary.
    """
    SUCCESSFUL = True
    UNSUCCESSFULL = False

    if order_json is None:
        return False
    order = Box(order_json)

    sections = (
        Field("order_details", dict),
        Field("order_items", list),
    )
    if not _check_fields(order, sections):
        print("Request has wrong order sections.")
        return UNSUCCESSFUL

    items_ordered = len(order.order_items)
    if items_ordered < 1 or items_ordered > 100:
        return UNSUCCESSFUL

    detail_fields = (
        Field("first_name", str),
        Field("last_name", str),
        Field("street", str),
        Field("city", str),
        Field("postal_code", str),
    )
    if not _check_fields(order.order_details, detail_fields):
        print("Request has wrong order detail fields.")
        return UNSUCCESSFUL

    item_fields = (Field("category_id", int), Field("item_id", int), Field("quantity", int))
    for item in order.order_items:
        if not isinstance(item, dict):
            return UNSUCCESSFUL
        if not _check_fields(item, item_fields):
            print("Request has at least one ordered item which has wrong item fields.")
            return UNSUCCESSFUL

    print("Order valid.")
    return SUCCESFULL
