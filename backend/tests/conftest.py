import pytest

from sqlalchemy import MetaData

from src.pizzaapp.database import connect
from src.pizzaapp.config import read_config
from src.tools.base_data import base_data_populate

@pytest.fixture(scope="session")
def get_config() -> Box:
    config = read_config()
    return config


@pytest.fixture(scope="session")
def mock_db_manager() -> DatabaseManager:
    mock_engine = connect(":memory:")
    metadata = MetaData(mock_engine)
    base_data_populate(mock_engine)
    yield db_manager
    mock_engine.dispose()


@pytest.fixture(scope="session")
def real_db_manager(config) -> DatabaseManager:
    db_manager = DatabaseManager(config.db.path)
    yield db_manager
    db_manager.engine.dispose()
