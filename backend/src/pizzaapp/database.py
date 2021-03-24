import re
import sys

from pathlib import Path

from box import Box
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


class DatabaseManager:
    engine: Engine
    db_location: str

    def __init__(self, db_location: str):
        self._connect(db_location)

    def _connect(self, location: str):
        database_url = None
        if location == ":memory:":
            self.db_location = ":memory:"
            database_url = "sqlite+pysqlite:///:memory:"
        else:
            db_path = Path(location)
            db_path_posix = db_path.as_posix()
            self.db_location = db_path_posix
            db_path_parent = db_path.parent

            if not db_path_parent.exists():
                print(f"Creating database parent directory at {db_path_parent}.")
                parent.mkdir()

            if not db_path.exists():
                print(f"Creating new SQLite database at {db_path_posix}.")
            else:
                if not db_path.is_file():
                    print(
                        f"Path {db_path_posix} is a directory, no SQLite database file."
                    )
                    sys.exit()

            database_url = f"sqlite+pysqlite:///{location}"

        self.engine = create_engine(database_url, future=True)


def check_table_exists(cursor: sqlite3.Cursor, name: str) -> bool:
    cursor.execute(
        """SELECT * FROM sqlite_master WHERE type = "table" AND name = ?""", (name,)
    )
    matches = cursor.fetchall()
    if len(matches) > 0:
        return True
    else:
        return False
