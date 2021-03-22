import pytest


@pytest.mark.parametrize(
    "db_manager",
    pytest.lazy_fixture(["mock_db_manager", "real_db_manager"]),
)
def test_database_manager(db_manager):
    assert not db_manager.conn is None


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
