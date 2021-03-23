from src.pizzaapp.defaults import QUERIES
from src.pizzaapp.database import DatabaseManager


class Catalog:
    def __init__(self):
        pass

    def _get_categories(self, cursor):
        cursor.execute(QUERIES.catalog.get_categories)
        categories = cursor.fetchall()
        return categories

    def _get_category_items(self, cursor):
        cursor.execute(QUERIES.catalog.get_items)
        items = cursor.fetchall()
        return items

    def _combine_catalog(self, categories: list, items: list):
        catalog = {}
        for category in categories:
            catalog[category[0]] = {"id": category[1]}
        for item in items:
            pass

    def construct(self, db_manager: DatabaseManager):
        cursor = db_manager.conn.cursor()
        categories = self._get_categories(cursor)
        category_items = self.get_category_items(cursor)

        catalog = {"categories": []}
        catalog["categories"] = _combine_to_categories(categories, category_items)

        print(categories)
