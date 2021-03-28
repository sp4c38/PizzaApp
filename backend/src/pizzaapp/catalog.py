from box import Box
from sqlalchemy import select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

from src.pizzaapp import Base
from src.pizzaapp.tables import Category, Item, Price, ItemSpeciality

class Catalog:
    categories: tuple[Category]
    items: tuple[Item]
    prices: tuple[Price]
    item_specialities = tuple[ItemSpeciality]

    def __init__(self, engine: Engine):
        self._load_tables(engine)

    def _select_all(self, session: Session, table_type: Base) -> list:
        stmt = select(table_type)
        results = session.execute(stmt)
        rows = [row[0] for row in results.all()]
        return rows

    def _load_tables(self, engine: Engine):
        with Session(engine) as session:
            session.expire_on_commit = False

            self.categories = self._select_all(session, Category)
            self.items = self._select_all(session, Item)
            self.prices = self._select_all(session, Price)
            self.item_specialities = self._select_all(session, ItemSpeciality)

    # def as_json(self):
    #     res = Box()
    #     res.categories = {}

    #     for category_row in self.categories:
    #         res_category = Box()
    #         res_category.all_items = {}


    #     import IPython;IPython.embed()