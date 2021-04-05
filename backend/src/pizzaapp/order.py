from box import Box

from src.pizzaapp.utils import check_keys_in_dict

def save_order():
    """Save new order to the database."""
    pass

def verify_order(order_json: Box) -> bool:
    """Verify if the order has the valid format.

    :param order_json: The order as a dictionary which is JSON valid or None.
    """
    UNSUCCESSFUL = False

    if order_json is None:
        return False
    order = Box(order_json)
_____
    order_sections = (
        "order_details", "items"
    )
    if not check_keys_in_dict(order, order_sections):
        print("Request has wrong order sections.")
        return RETURN_UNSUCCESSFUL

    amount_ordered = len(order.items)
    if not amount_ordered > 0 and not amount_ordered > 100:
        return RETURN_UNSUCCESSFUL

    detail_fields = (
        "first_name", "last_name", "street", "city", "postal_code"
    )
    if not check_keys_in_dict(order.order_details, detail_fields):
        print("Request has wrong order detail fields.")
        return RETURN_UNSUCCESSFUL

    item_fields = ("category_id", "item_id", "quantity") 
    for item in order.items:
        if not check_keys_in_dict(item, item_fields):
            return RETURN_UNSUCCESSFUL

    import IPython;IPython.embed()
