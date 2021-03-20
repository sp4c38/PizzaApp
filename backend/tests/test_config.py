from pathlib import PosixPath


def test_config_values(setup_config):
    db_section = setup_config.get("db")
    assert db_section
    db_path = db_section.get("path")
    assert db_path
    assert type(db_path) == PosixPath
