from sqlalchemy import Table, Column
from sqlalchemy import Boolean, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship

from src.pizzaapp import Base

class Category(Base):
    print("Run categories")
    __tablename__ = "category"

    category_id = Column(Integer, primary_key=True)
    name = Column(String)

class Item(Base):
    print("Run items")
    __tablename__ = "item"

    item_id = Column(Integer, primary_key=True)
    name = Column(String)
    image_name = Column(String)
    ingredient_description = Column(String)
    category_id = Column(ForeignKey("category.category_id"))

    category = relationship("Category", backref="items")

class Price(Base):
    item_id = Column(ForeignKey("item.item_id"), primary_key=True) 
    price_id = Column(Integer, primary_key=True)
    price = Column(Numeric(6, 2, asdecimal=True))

class ItemSpecialities(Base):
    __tablename__ = "item_specialities"
    vegetarian = Column(Boolean)
    vegan = Column(Boolean)
    spicy = Column(Boolean)

# if __name__ == "__main__":
#     import IPython;IPython.embed()