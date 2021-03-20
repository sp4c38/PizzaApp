from pathlib import Path

from src.database import DatabaseManager
from src.other.insert_base_data import base_data_populate


def make_mock_database() -> DatabaseManager:
    db_manager = DatabaseManager(Path(":memory:"))

    create_table = Path(__file__).parents[1] / "res" / "tables" / "create_tables.sql"
    sql_query = create_table.read_text()
    db_manager.conn.executescript(sql_query)
    db_manager.conn.commit()

    base_data_populate(db_manager)

    return db_manager
