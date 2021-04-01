import pytest

from sqlalchemy import Table
from sqlalchemy.engine import Engine


@pytest.mark.parametrize(
    "db_manager",
    pytest.lazy_fixture(["mock_db_manager", "real_db_manager"]),
)
def test_database_manager(db_manager):
    assert isinstance(db_manager.engine, Engine)
    conn = db_manager.engine.connect()
    conn.close()
    assert isinstance(db_manager.sqlite_master_table, Table)


@pytest.mark.parametrize(
    "db_manager",
    pytest.lazy_fixture(["mock_db_manager", "real_db_manager"]),
)
def test_tables_exist(db_manager):
    cursor = db_manager.conn.cursor()
    cursor.execute("""SELECT name FROM sqlite_master WHERE type="table";""")
    response_rows = cursor.fetchall()

    response_table_names = [name for row in response_rows for name in row]
    required_table_names = [
        "delivery_users",
        "categories",
        "items",
        "prices",
        "item_specialities",
        "orders",
        "order_items",
    ]

    for required_table in required_table_names:
        assert required_table in response_table_names
    cursor.close()
