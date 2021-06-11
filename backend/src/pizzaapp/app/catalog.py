"""Store information about the catalog and provide helper functions for it."""

from box import Box
from loguru import logger
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, selectinload

from pizzaapp.app.tables import Category, Item


class Catalog:
    """Catalog holds all Category objects and contains multiple helper functions.

    Through the Category sub-category-objects can be accessed like
    Category.items or Category.items[index].speciality.
    """

    def __init__(self, engine: Engine):
        with Session(engine) as session:
            self.categories = self._load_catalog(session)
        self._parsed_json = None

    def _load_catalog(self, session: Session) -> list[Category]:
        """Load the catalog.

        The catalog is loaded by quering all categories, items, prices and specialities.

        :returns: A list of all categories. The other catalog objects can be accessed using the appropriate
            attributes on a category.
        """
        categories = (
            session.query(Category)
            # Applying selectinload two times will still only load the items once.
            .options(selectinload(Category.items).selectinload(Item.prices))
            .options(selectinload(Category.items).selectinload(Item.speciality))
            .all()
        )
        return categories

    def to_json(self) -> dict:
        """Convert the catalog to a json representation."""
        if self._parsed_json is not None:
            return self._parsed_json

        parsed_data = Box()
        parsed_data.categories = {}

        for category in self.categories:
            parsed_category = Box()
            parsed_category.category_id = category.category_id
            parsed_category.all_items = []

            for item in category.items:
                parsed_item = Box()
                parsed_item.id = item.item_id
                parsed_item.name = item.name
                parsed_item.image_name = item.image_name
                parsed_item.ingredient_description = item.ingredient_description
                parsed_item.prices = [row.price for row in item.prices]

                # A speciality for an item is optional. If no speciality exists a
                # default speciality will be used - to have a consistent JSON structure.
                default_speciality = Box(vegetarian=False, vegan=False, spicy=False)
                parsed_item.speciality = default_speciality
                if item.speciality is not None:
                    parsed_item.speciality.vegetarian = item.speciality.vegetarian
                    parsed_item.speciality.vegan = item.speciality.vegan
                    parsed_item.speciality.spicy = item.speciality.spicy

                parsed_category.all_items.append(parsed_item)

            category_name = category.name.lower()
            parsed_data.categories[category_name] = parsed_category

        self._parsed_json = parsed_data.to_dict()
        return self._parsed_json


def items_valid(catalog: Catalog, items: list[Item]) -> bool:
    """Check if the parsed items can be created based on the catalog.

    For example check if the item ids of the parsed items exist in the catalog.

    :returns: True if the parsed items are valid, false if not. Will also return false if there
        are no items in the list.
    """
    if not len(items) >= 1:
        return False

    category_item_ids = []
    for category in catalog.categories:
        for item in category.items:
            category_item_ids.append(item.item_id)
    for item in items:
        if item.item_id not in category_item_ids:
            logger.info(f"Item id {item.item_id} not found in catalog.")
            return False
    return True
