from flask import Flask
from sqlalchemy import MetaData
from sqlalchemy import inspect
from sqlalchemy.orm import registry as orm_registry

from src.pizzaapp.config import read_config
from src.pizzaapp.database import connect

config = read_config()

engine = connect(config.db.path, config.pizzaapp.debug)

inspector = inspect(engine)

_metadata = MetaData(engine)

registry = orm_registry(_metadata)
Base = registry.generate_base()  # SQLAlchemy declarative ORM Base class
