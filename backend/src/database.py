import re
import sqlite3
import sys

from box import Box


class DatabaseManager:
    conn: sqlite3.Connection

    def __init__(self, config: Box):
        self._connect(config)

    def _connect(self, config: Box):
        if not config.db.path.parent.exists():
            print(f"Creating database parent directory at {config.db.path.parent}.")
            config.db.path.parent.mkdir()

        if not config.db.path.exists():
            print(f"Creating new SQLite database at {config.db.path}.")
        else:
            if not config.db.path.is_file():
                print(f"Path {config.db.path} is a directory, no SQLite database file.")
                sys.exit()

        self.conn = sqlite3.connect(config.db.path)


def check_table_exists(cursor: sqlite3.Cursor, name: str) -> bool:
    cursor.execute(
        """SELECT * FROM sqlite_master WHERE type = "table" AND name = ?""", (name,)
    )
    matches = cursor.fetchall()
    if len(matches) > 0:
        return True
    else:
        return False
