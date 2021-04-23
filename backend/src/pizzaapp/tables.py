"""Contains the sqlalchemy orm table representations and some table helper functions."""

from typing import Optional

from box import Box

from sqlalchemy.types import Boolean, Integer, String
from sqlalchemy.schema import Column, ForeignKey
from sqlalchemy.orm import backref, relationship

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

    items = relationship("Item", back_populates="category")  # , lazy="selectin")


class Item(Base):
    """An Item holds information about a product."""

    __tablename__ = NAMES_OF_TABLES["item_table"]

    item_id = Column(Integer, primary_key=True)
    category_id = Column(ForeignKey(Category.category_id))
    name = Column(String)
    image_name = Column(String)
    ingredient_description = Column(String)

    category = relationship("Category", back_populates="items")
    prices = relationship("ItemPrice", back_populates="item")
    speciality = relationship("ItemSpeciality", uselist=False, back_populates="item")


class ItemPrice(Base):
    """An ItemPrice holds information about the price for a product."""

    __tablename__ = NAMES_OF_TABLES["item_price_table"]

    item_id = Column(ForeignKey(Item.item_id), primary_key=True)
    price_id = Column(Integer, primary_key=True)
    price = Column(price_type)

    item = relationship("Item", back_populates="prices")


class ItemSpeciality(Base):
    """An ItemSpeciality holds information about specific special traits for a product."""

    __tablename__ = NAMES_OF_TABLES["item_speciality_table"]

    item_id = Column(ForeignKey(Item.item_id), primary_key=True)
    vegetarian = Column(Boolean)
    vegan = Column(Boolean)
    spicy = Column(Boolean)

    item = relationship("Item", uselist=False, back_populates="speciality")


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

    items = relationship("OrderItem", back_populates="order", cascade="all, delete, delete-orphan")

    def to_json(self) -> dict:
        jsoned = Box()
        jsoned.details = {}
        jsoned.details.first_name = self.first_name
        jsoned.details.last_name = self.last_name
        jsoned.details.street = self.street
        jsoned.details.city = self.city
        jsoned.details.postal_code = self.postal_code

        jsoned["items"] = [item.to_json() for item in self.items]
        return jsoned.to_dict()


class OrderItem(Base):
    """Entry to store information about a single item which was ordered.

    A ordered item is always linked to an order.
    The unit price at which the product is sold is stored extra, as the price of a product
    could change in the future.
    """

    __tablename__ = NAMES_OF_TABLES["order_item_table"]

    order_item_id = Column(Integer, primary_key=True)
    order_id = Column(ForeignKey(Order.order_id, ondelete="CASCADE"), nullable=False)
    # If the item to deliver is deleted we still want to keep the ordered item.
    item_id = Column(ForeignKey(Item.item_id, ondelete="SET NULL"), nullable=True)
    unit_price = Column(price_type)
    quantity = Column(Integer)

    order = relationship("Order", back_populates="items")
    item = relationship("Item")

    def to_json(self) -> dict:
        jsoned = Box()
        jsoned.order_id = self.order_id
        jsoned.item_id = self.item_id
        jsoned.unit_price = self.unit_price
        jsoned_quantity = self.quantity
        return jsoned.to_dict()


# User tables
class DeliveryUser(Base):
    """Entry to store information about a delivery user."""

    __tablename__ = NAMES_OF_TABLES["delivery_user_table"]

    user_id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    pw_hash = Column(String(60), nullable=False)  # Includes hash and salt.
    date_created = Column(Integer, nullable=False)  # Stored as timestamp.


class RefreshTokenDescription(Base):
    """Store extra information for a refresh token.

    A refresh token chain is created quite rapidly. To prevent storing data which can
    be considered the same for each item in the chain, a entry in this table is created
    and referred to by the items of the chain.
    """

    __tablename__ = NAMES_OF_TABLES["refresh_token_description_table"]

    description_id = Column(Integer, primary_key=True)
    user_id = Column(ForeignKey(DeliveryUser.user_id, ondelete="CASCADE"), nullable=False)
    device_description = Column(String, nullable=True)

    refresh_tokens = relationship(
        "RefreshToken", back_populates="description", cascade="all, delete, delete-orphan"
    )


class RefreshToken(Base):
    """Entry to store refresh token information."""

    __tablename__ = NAMES_OF_TABLES["refresh_token_table"]

    refresh_token_id = Column(Integer, primary_key=True)
    originated_from = Column(
        ForeignKey(f"{NAMES_OF_TABLES['refresh_token_table']}.refresh_token_id", ondelete="SET NULL"),
        nullable=True,
    )
    # Hashed refresh token which gets stored to the database.
    refresh_token_hash = Column(String, nullable=False, unique=True)
    # Non hashed refresh token which gets sent back to the user.
    refresh_token: Optional[str] = None
    valid = Column(Boolean, nullable=False)
    issuing_time = Column(Integer, nullable=False)  # Store as timestamp.
    description_id = Column(
        ForeignKey(RefreshTokenDescription.description_id, ondelete="CASCADE"), nullable=False
    )

    originator = relationship(
        "RefreshToken",
        remote_side=refresh_token_id,
        backref=backref("successor"),
    )
    description = relationship("RefreshTokenDescription", back_populates="refresh_tokens")
    access_tokens = relationship(
        "AccessToken", back_populates="refresh_token", cascade="all, delete, delete-orphan"
    )

    def response_json(self):
        """Generate json for providing information about a refresh token in a response."""
        # Beaware which information to leak in a response.
        jsoned = {"token": self.refresh_token}
        return jsoned


class AccessToken(Base):
    """Entry to store access token information."""

    __tablename__ = NAMES_OF_TABLES["access_token_table"]

    access_token_id = Column(Integer, primary_key=True)
    # Refresh token with which the access token was created.
    refresh_token_id = Column(ForeignKey(RefreshToken.refresh_token_id, ondelete="CASCADE"), nullable=False)
    # Hashed access token which gets stored to the database.
    access_token_hash = Column(String, nullable=False, unique=True)
    # Non hashed access token which gets sent back to the user.
    access_token: Optional[str] = None
    expiration_time = Column(Integer, nullable=False)  # Stored as timestamp.

    refresh_token = relationship("RefreshToken", back_populates="access_tokens")

    def response_json(self):
        """Generate json for providing information about a access token in a response."""
        # Beaware of which information to leak to the client.
        jsoned = {"token": self.access_token, "expiration_time": self.expiration_time}
        return jsoned


# skipcq: PTC-W0049
def map_tables():
    """Run to add above tables to the Base's metadata.

    First the Base needs to be created which is done in the __init__.py file. Then the above tables
    need to be added to the Base's metadata. To do this the python interpreter needs to execute the
    above class declarations. This could be simply done by importing this module, but to increase code
    readability this function should be called.
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
