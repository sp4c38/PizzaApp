import pytest

from box import Box

from src.config import read_config
from src.database import DatabaseManager
from tests.mock_database import make_mock_database


@pytest.fixture
def setup_config() -> Box:
    config = read_config()
    return config


@pytest.fixture
def setup_database(setup_config) -> DatabaseManager:
    db_path = setup_config.db.path
    db_manager = make_mock_database()
    return db_manager
