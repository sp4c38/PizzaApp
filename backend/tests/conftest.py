import pytest

from pathlib import Path

from box import Box

from src.pizzaapp.config import read_config
from src.pizzaapp.database import DatabaseManager
from src.tools.insert_base_data import base_data_populate
from src.tools.tables import create_tables


@pytest.fixture(scope="session")
def config() -> Box:
    config = read_config()
    return config


@pytest.fixture(scope="session")
def mock_db_manager() -> DatabaseManager:
    db_manager = DatabaseManager(Path(":memory:"))
    create_tables(db_manager)
    base_data_populate(db_manager)
    yield db_manager
    db_manager.conn.close()


@pytest.fixture(scope="session")
def real_db_manager(config) -> DatabaseManager:
    db_manager = DatabaseManager(config.db.path)
    yield db_manager
    db_manager.conn.close()
