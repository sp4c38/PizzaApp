def test_database_manager(setup_database):
    assert not setup_database.conn is None
