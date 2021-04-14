from sqlalchemy.types import Boolean, Date, Integer, String
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.orm import relationship

from src.pizzaapp import Base, config, inspector
from src.pizzaapp.database import SQLiteDecimal
from src.pizzaapp.defaults import NAMES_OF_TABLES
from src.pizzaapp.exceptions import RequiredTableMissing

price_type = SQLiteDecimal(scale=2)


# Catalog tables
class Category(Base):
    """A Category has a name is the parent/root of multiple Item objects."""

    __tablename__ = NAMES_OF_TABLES["category_table"]

    category_id = Column(Integer, primary_key=True)
    name = Column(String)

    items = relationship("Item", back_populates="category", lazy="selectin")


class Item(Base):
    """An Item holds information about a product."""

    __tablename__ = NAMES_OF_TABLES["item_table"]

    item_id = Column(Integer, primary_key=True)
    name = Column(String)
    image_name = Column(String)
    ingredient_description = Column(String)
    category_id = Column(ForeignKey(Category.category_id))

    category = relationship("Category", back_populates="items", lazy="selectin")
    prices = relationship("ItemPrice", back_populates="item", lazy="selectin")
    speciality = relationship(
        "ItemSpeciality", uselist=False, back_populates="item", lazy="selectin"
    )


class ItemPrice(Base):
    """An ItemPrice holds information about the price for a product."""

    __tablename__ = NAMES_OF_TABLES["item_price_table"]

    item_id = Column(ForeignKey(Item.item_id), primary_key=True)
    price_id = Column(Integer, primary_key=True)
    price = Column(price_type)

    item = relationship("Item", back_populates="prices", lazy="selectin")


class ItemSpeciality(Base):
    """An ItemSpeciality holds information about specific special traits for a product."""

    __tablename__ = NAMES_OF_TABLES["item_speciality_table"]

    item_id = Column(ForeignKey(Item.item_id), primary_key=True)
    vegetarian = Column(Boolean)
    vegan = Column(Boolean)
    spicy = Column(Boolean)

    item = relationship("Item", uselist=False, back_populates="speciality", lazy="selectin")


# Order tables
class Order(Base):
    """An Order holds contact and address information for a placed order.

    PizzaApp doesn't use a user table approach because it doesn't support accounts.
    That's why all contact and address information of the person placing the order
    are stored together with the order.
    """

    __tablename__ = NAMES_OF_TABLES["order_table"]

    order_id = Column(Integer, primary_key=True)
    first_name = Column(String)
    last_name = Column(String)
    street = Column(String)
    city = Column(String)
    postal_code = Column(String)


class OrderItem(Base):
    """Entry to store information about a single item which was ordered.

    A ordered item is always linked to an order.
    The unit price at which the product is sold is stored extra, as the price of a product
    could change in the future.
    """

    __tablename__ = NAMES_OF_TABLES["order_item_table"]

    order_id = Column(ForeignKey(Order.order_id), primary_key=True)
    item_id = Column(ForeignKey(Item.item_id), primary_key=True)
    unit_price = Column(price_type)
    quantity = Column(Integer)

    order = relationship("Order", backref="items")
    item = relationship("Item")


# User tables
class DeliveryUser(Base):
    """Entry to store information about a delivery user."""

    __tablename__ = NAMES_OF_TABLES["delivery_user_table"]

    user_id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    pw_hash = Column(String(60))  # Includes hash and salt.
    date_created = Column(Integer)  # Stored as timestamp.


class RefreshToken(Base):
    """Entry to store refresh token information."""

    __tablename__ = NAMES_OF_TABLES["refresh_token_table"]

    refresh_token_id = Column(Integer, primary_key=True)
    user_id = Column(ForeignKey(DeliveryUser.user_id), nullable=False)
    refresh_token = Column(String, nullable=False, unique=True)
    valid = Column(Boolean, nullable=False)
    # A description for the user to roughly see which devices have access to his account.
    # Example: "iPhone X"
    device_description = Column(String, nullable=True)
    issuing_time = Column(Integer, nullable=False)  # Store as timestamp.


class AccessToken(Base):
    """Entry to store access token information."""

    __tablename__ = NAMES_OF_TABLES["access_token_table"]

    access_token_id = Column(Integer, primary_key=True)
    # Refresh token with which the access token was created.
    refresh_token_id = Column(ForeignKey(RefreshToken.refresh_token_id), nullable=False)
    access_token = Column(String, nullable=False, unique=True)
    expiration_time = Column(Integer)  # Stored as timestamp.


# skipcq: PTC-W0049
def map_tables():
    """Run to add above tables to the Base's metadata.

    After the Base class from src.pizzaapp was created the table
    classes above which conform to Base need to be processed to be
    added to the Base's metadata. A simple import would be sufficient,
    but to increase code readability this function can be called.
    """


def confirm_required_tables_exist():
    """Check if all required tables exist in the database.

    The table names specified in defaults.py are used to identify and thus check if
    tables exist.
    """
    existing_tables = inspector.get_table_names()
    required_tables = NAMES_OF_TABLES.values()

    for required_table in required_tables:
        if required_table not in existing_tables:
            raise RequiredTableMissing(required_table, config.db.path)
