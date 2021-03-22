#!/usr/bin/env python

import argparse
import sys

from rich.console import Console
from rich.prompt import Confirm

from src.config import read_config
from src.database import DatabaseManager
from src.tools.utils import get_tools_query


TABLE_OPERATIONS = ["create", "delete"]

console = Console(highlight=True)

def get_parser():
    parser = argparse.ArgumentParser(
        description="Perform operations to setup the database for the PizzaProject backend."
    )
    parser.add_argument(
        "-g", action="store_true", help="return database path", dest="show_db_path"
    )
    parser.add_argument(
        "operation",
        action="store",
        nargs="?",
        default=None,
        choices=TABLE_OPERATIONS,
        help="operation to perform for tables",
    )
    return parser

def run_query(db_manager: DatabaseManager, query: str):
    cursor = db_manager.conn.cursor()
    cursor.executescript(query)
    db_manager.conn.commit()
    cusor.close()

def create_tables(db_manager: DatabaseManager):
    query = get_tools_query("create_tables.sql")
    run_query(db_manager, query)
    console.print("[green bold]Created missing PizzaProject tables in database.[/green bold]")

def delete_tables(db_manager: DatabaseManager):
    really_delete = Confirm.ask("[red bold]Delete all existing PizzaProject tables?[/red bold]")

    if really_delete:
        query = get_tools_query("delete_tables.sql")
        run_query(db_manager, query)
        console.print("[green bold]Operation successful.[/green bold]")
    else:
        console.print("[green bold]Operation cancelled.[/green bold]")

def main():
    parser = get_parser()
    args = parser.parse_args()

    config = read_config()
    db_manager = DatabaseManager(config.db.path)

    if args.show_db_path:
        console.print(f"[bold blue]Database path:[/bold blue] {config.db.path}")
    elif args.operation is not None:
        if args.operation == TABLE_OPERATIONS[0]:
            create_tables(db_manager)
        elif args.operation == TABLE_OPERATIONS[1]:
            delete_tables(db_manager)
    else:
        console.print("[yellow]Parse -h or --help to see usage information.[yellow]")

if __name__ == "__main__":
    main()
