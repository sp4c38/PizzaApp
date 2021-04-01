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

# skipcq: FLK-E402
# The src.pizzaapp.tables file itself imports the Base class declared above.
# If anything from this file is imported before the Base definition this init
# would fail due to circular imports.
from src.pizzaapp.tables import map_tables

map_tables()
