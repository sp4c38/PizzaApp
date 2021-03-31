from sqlalchemy import MetaData
from sqlalchemy import inspect
from sqlalchemy.orm import registry as orm_registry

from src.pizzaapp.config import read_config
from src.pizzaapp.database import connect

config = read_config()

engine = connect(config.db.path, config.pizzaapp.debug)

inspector = inspect(engine)

registry = orm_registry()
Base = registry.generate_base()  # SQLAlchemy declarative ORM Base class

# Import map_tables function at this point because it reliese on the Base class declared above.
# If this import statment would stand before the Base declaration the program would fail due to circular imports.
from src.pizzaapp.tables import map_tables

map_tables()