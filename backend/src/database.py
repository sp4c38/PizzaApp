import re
import sqlite3
import sys

from box import Box
from pathlib import Path, PosixPath


class DatabaseManager:
    conn: sqlite3.Connection

    def __init__(self, db_location: PosixPath):
        self._connect(db_location)

    def _connect(self, db_location: PosixPath):
        if not db_location == Path(":memory:"):
            path = Path(db_location)
            if not path.parent.exists():
                print(f"Creating database parent directory at {path.parent}.")
                path.parent.mkdir()

            if not path.exists():
                print(f"Creating new SQLite database at {path}.")
            else:
                if not path.is_file():
                    print(f"Path {path} is a directory, no SQLite database file.")
                    sys.exit()

        self.conn = sqlite3.connect(db_location)


def check_table_exists(cursor: sqlite3.Cursor, name: str) -> bool:
    cursor.execute(
        """SELECT * FROM sqlite_master WHERE type = "table" AND name = ?""", (name,)
    )
    matches = cursor.fetchall()
    if len(matches) > 0:
        return True
    else:
        return False
