import sys

from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy import and_, bindparam, MetaData, select, Table
from sqlalchemy.engine import Engine


def connect(location: str) -> Engine:
    database_url = None
    if location == ":memory:":
        database_url = "sqlite+pysqlite:///:memory:"
    else:
        db_path = Path(location)
        db_path_posix = db_path.as_posix()
        db_path_parent = db_path.parent

        if not db_path_parent.exists():
            print(f"Creating database parent directory at {db_path_parent}.")
            parent.mkdir()

        if not db_path.exists():
            print(f"Creating new SQLite database at {db_path_posix}.")
        else:
            if not db_path.is_file():
                print(f"Path {db_path_posix} is a directory, no SQLite database file.")
                sys.exit()

        database_url = f"sqlite+pysqlite:///{location}"

    engine = create_engine(database_url, future=True)

    return engine
