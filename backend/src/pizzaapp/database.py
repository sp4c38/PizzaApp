import sys

from decimal import Decimal
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.types import Integer, TypeDecorator


# skipcq: PYL-W0223
class SQLiteDecimal(TypeDecorator):
    """A SQLAlchemy TypeDecorator that stores decimals to SQLite.

    Problem:
        The SQLAlchemy pysqlite dialect doesn't support decimals.

    Before database insertion decimals are converted to integers.
    After database read operations integers are converted to decimals.

    Initialization:
    :param scale: Maximum scale respected when converting from decimals to integers.
        When converting all decimal digits after the amount of scale digits are truncated.
    """

    impl = Integer

    def __init__(self, scale):
        super(SQLiteDecimal, self).__init__()
        self.scale = scale
        self.multiplier = 10 ** self.scale

    def process_bind_param(self, value, dialect):
        """Convert a decimal value to an integer (usually called before db write operations)."""
        if value is not None:
            converted_value = int(Decimal(value) * self.multiplier)
        return converted_value

    def process_result_value(self, value, dialect):
        """Convert an interger value to a decimal (usually called after db read operations)."""
        if value is not None:
            converted_value = value / self.multiplier
        return converted_value


def connect(location: str, debug: bool) -> Engine:
    """Connect to the SQLite database with SQLAlchemy.

    :param location: Location of the database. If location is :memory: the function will use
        an in-memory database connection. If location is a file system path the function
        will read the file. 
    :returns: A SQLAlchemy Engine object.
    """
    database_url = None
    if location == ":memory:":
        database_url = "sqlite+pysqlite:///:memory:"
    else:
        db_path = Path(location)
        db_path_posix = db_path.as_posix()
        db_path_parent = db_path.parent

        if not db_path_parent.exists():
            print(f"Creating database parent directory at {db_path_parent}.")
            db_path_parent.mkdir()

        if not db_path.exists():
            print(f"Creating new SQLite database at {db_path_posix}.")
        else:
            if not db_path.is_file():
                print(f"Path {db_path_posix} is a directory, no SQLite database file.")
                sys.exit()

        database_url = f"sqlite+pysqlite:///{location}"

    engine = create_engine(database_url, future=True, echo=debug)

    return engine
