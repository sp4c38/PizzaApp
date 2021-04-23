"""Run init code and store important variables which need to be accessible throughout the entire program.
"""

from sqlalchemy import MetaData
from sqlalchemy import inspect
from sqlalchemy.orm import registry as orm_registry

from src.pizzaapp.config import configure_logging, read_config
from src.pizzaapp.database import connect

config = read_config()
configure_logging(config)

engine = connect(config.paths.database, config.pizzaapp.debug)
inspector = inspect(engine)
_metadata = MetaData(engine)
registry = orm_registry(_metadata)
Base = registry.generate_base()  # SQLAlchemy declarative ORM Base class

# skipcq: FLK-E402
# The src.pizzaapp.tables module itself imports the Base class declared above. If anything from the
# tables module is imported before the Base definition this init fails due to circular imports.
from src.pizzaapp.tables import map_tables

map_tables()
