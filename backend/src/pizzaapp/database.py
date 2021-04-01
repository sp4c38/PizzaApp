import sys

from decimal import Decimal
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.types import Integer, TypeDecorator


class SQLiteDecimal(TypeDecorator):
    impl = Integer

    def __init__(self, scale):
        super(SQLiteDecimal, self).__init__()
        self.scale = scale
        self.multiplier = 10 ** self.scale

    def process_bind_param(self, value, dialect):
        if value is not None:
            converted_value = int(Decimal(value) * self.multiplier)
        return converted_value

    def process_result_value(self, value, dialect):
        if value is not None:
            converted_value = value / self.multiplier
        return converted_value


def connect(location: str, debug: bool) -> Engine:
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

    engine = create_engine(database_url, future=True, echo=debug)

    return engine
