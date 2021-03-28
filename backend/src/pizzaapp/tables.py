from sqlalchemy import Table, Column
from sqlalchemy import Boolean, Date, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship

from src.pizzaapp import Base, config, inspector
from src.pizzaapp.defaults import NAMES_OF_TABLES
from src.pizzaapp.exceptions import RequiredTableMissing

price_type = Numeric(6, 2, asdecimal=True)

# Catalog tables
class Category(Base):
    __tablename__ = NAMES_OF_TABLES["category_table"]

    category_id = Column(Integer, primary_key=True)
    name = Column(String)


class Item(Base):
    __tablename__ = NAMES_OF_TABLES["item_table"]

    item_id = Column(Integer, primary_key=True)
    name = Column(String)
    image_name = Column(String)
    ingredient_description = Column(String)
    category_id = Column(ForeignKey("category.category_id"))

    category = relationship("Category", backref="items")


class Price(Base):
    __tablename__ = NAMES_OF_TABLES["price_table"]

    item_id = Column(ForeignKey("item.item_id"), primary_key=True)
    price_id = Column(Integer, primary_key=True)
    price = Column(price_type)

    item = relationship("Item", backref="prices")


class ItemSpeciality(Base):
    __tablename__ = NAMES_OF_TABLES["item_speciality_table"]
    
    item_id = Column(ForeignKey("item.item_id"), primary_key=True)
    vegetarian = Column(Boolean)
    vegan = Column(Boolean)
    spicy = Column(Boolean)

    item = relationship("Item", backref="speciality")


# Order tables
class Order(Base):
    __tablename__ = NAMES_OF_TABLES["order_table"]

    order_id = Column(Integer, primary_key=True)
    first_name = Column(String)
    last_name = Column(String)
    street = Column(String)
    street_number = Column(String)
    city = Column(String)
    postal_code = Column(String)


class OrderItem(Base):
    __tablename__ = NAMES_OF_TABLES["order_item_table"]

    order_id = Column(ForeignKey("order.order_id"), primary_key=True)
    item_id = Column(ForeignKey("item.item_id"), primary_key=True)
    unit_price = Column(price_type)
    quantity = Column(Integer)

    order = relationship("Order", backref="items")
    item = relationship("Item")


# User tables
class DeliveryUser(Base):
    __tablename__ = NAMES_OF_TABLES["delivery_user_table"]

    user_id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    pw_hash = Column(String(60))  # Includes hash and salt.
    date_created = Column(Date)

def confirm_required_tables_exist():
    existing_tables = inspector.get_table_names()
    required_tables = NAMES_OF_TABLES.values()

    for required_table in required_tables:
        if not required_table in existing_tables:
            raise RequiredTableMissing(required_table, config.db.path)
            sys.exit(1)