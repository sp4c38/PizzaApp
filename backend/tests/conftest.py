import pytest

from box import Box

from src.config import read_config
from src.database import DatabaseManager
from tests.mock_database import make_mock_database


@pytest.fixture(scope="session")
def config() -> Box:
    config = read_config()
    return config


@pytest.fixture(scope="session")
def mock_db_manager() -> DatabaseManager:
    db_manager = make_mock_database()
    yield db_manager
    db_manager.conn.close()


@pytest.fixture(scope="session")
def real_db_manager(config) -> DatabaseManager:
    db_manager = DatabaseManager(config.db.path)
    yield db_manager
    db_manager.conn.close()
