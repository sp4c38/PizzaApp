import re
import sys

from pathlib import Path

from box import Box
from sqlalchemy import create_engine
from sqlalchemy import and_, bindparam, select, Table
from sqlalchemy.engine import Engine
from sqlalchemy.orm import registry


class DatabaseManager:
    db_location: str
    engine: Engine
    registry: registry
    sqlite_master_table: Table

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
        self.registry = registry()
        self.sqlite_master_table = Table("sqlite_master", self.registry.metadata, autoload_with=self.engine)


def check_table_exists(db_manager: DatabaseManager, name: str) -> bool:
    sqm_table = db_manager.sqlite_master_table
    stmt = select(sqm_table).where(and_(sqm_table.c.type == "table", "name" == bindparam("name")))
    
    with db_manager.engine.connect() as conn:
        table_matches = conn.execute(stmt, [{"name": name}]).all()
    if len(table_matches) > 0:
        return True
    else:
        return False
