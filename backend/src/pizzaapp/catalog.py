from box import Box
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session
from src.pizzaapp.tables import Category


class Catalog:
    def __init__(self, engine: Engine):
        # Only store categories, as they are the main access points to get
        # any catalog object (i.e.: Category.items).
        self.categories = self._load_categories(engine)
        self._parsed_json = None

    @staticmethod
    def _load_categories(engine: Engine) -> list[Category]:
        with Session(engine) as session:
            categories = session.query(Category).all()
        return categories

    def to_json(self):
        if self._parsed_json is not None:
            return self._parsed_json

        parsed_data = Box()
        parsed_data.categories = {}

        for category in self.categories:
            parsed_category = Box()
            parsed_category.all_items = []

            for item in category.items:
                parsed_item = Box()
                parsed_item.id = item.item_id
                parsed_item.name = item.name
                parsed_item.image_name = item.image_name
                parsed_item.ingredient_description = item.ingredient_description
                parsed_item.prices = [row.price for row in item.prices]

                parsed_item.speciality = Box()
                parsed_item.speciality.vegetarian = item.speciality.vegetarian
                parsed_item.speciality.vegan = item.speciality.vegan
                parsed_item.speciality.spicy = item.speciality.spicy

                parsed_category.all_items.append(parsed_item)

            category_name = category.name.lower()
            parsed_data.categories[category_name] = parsed_category

        self._parsed_json = parsed_data.to_json()
        return self._parsed_json
