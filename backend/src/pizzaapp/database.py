import re
import sqlite3
import sys

from box import Box
from pathlib import Path, PosixPath


class DatabaseManager:
    conn: sqlite3.Connection
    location: PosixPath

    def __init__(self, db_location: PosixPath):
        self.location = db_location
        self._connect()

    def _connect(self):
        if not self.location == Path(":memory:"):
            parent = self.location.parent
            if not parent.exists():
                print(f"Creating database parent directory at {location.parent}.")
                parent.mkdir()

            if not self.location.exists():
                print(f"Creating new SQLite database at {self.location}.")
            else:
                if not self.location.is_file():
                    print(
                        f"Path {self.location} is a directory, no SQLite database file."
                    )
                    sys.exit()

        self.conn = sqlite3.connect(self.location)


def check_table_exists(cursor: sqlite3.Cursor, name: str) -> bool:
    cursor.execute(
        """SELECT * FROM sqlite_master WHERE type = "table" AND name = ?""", (name,)
    )
    matches = cursor.fetchall()
    if len(matches) > 0:
        return True
    else:
        return False
