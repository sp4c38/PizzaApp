#!/usr/bin/env python

import argparse

from sqlalchemy import MetaData
from sqlalchemy.engine import Engine
from rich.console import Console
from rich.prompt import Confirm

from src.pizzaapp import config, engine, registry
from src.tools.base_data import base_data_populate
from src.tools.tables import create_tables, delete_tables
from src.tools.base_data import get_files

console = Console(highlight=True)

metadata = registry.metadata


def get_parser():
    """Get the configured argparse.ArgumentParser for this tool."""
    parser = argparse.ArgumentParser(
        description="Perform operations to setup the database for the PizzaApp backend."
    )
    parser.add_argument("-g", action="store_true", help="return database path", dest="show_db_path")
    parser.add_argument(
        "-c",
        "--create",
        action="store_true",
        default=False,
        help="create pizzaapp tables",
    )
    parser.add_argument(
        "-i",
        "--insert",
        action="store_true",
        default=False,
        help="insert pizzaapp base data into tables",
    )
    parser.add_argument(
        "-d",
        "--delete",
        action="store_true",
        default=False,
        help="delete pizzaapp tables",
    )
    return parser


def cmd_create_tables(metadata: MetaData):
    """Handle CLI command to create all projects tables."""
    create_tables(metadata)
    console.print("[green bold]Created PizzaApp tables in database.[/green bold]")


def cmd_insert_base_data(engine: Engine):
    """Handle CLI command to insert base data."""
    base_data_populate(engine)
    console.print("[green bold]Inserted PizzaApp base data.[/green bold]")


def cmd_delete_tables(metadata: MetaData):
    """Handle CLI command to delete all projects tables.

    See the create_table function how these tables are located.
    """
    really_delete = Confirm.ask("[red bold]Delete all existing PizzaApp tables?[/red bold]")

    if really_delete:
        delete_tables(metadata)
        console.print("[green bold]All PizzaApp tables were deleted.[/green bold]")
    else:
        console.print("[green bold]No PizzaApp tables were deleted.[/green bold]")


def main():
    """Handle commands to this CLI."""
    parser = get_parser()
    args = parser.parse_args()

    if args.show_db_path:
        console.print(f"[bold blue]Database path:[/bold blue] {config.db.path}")
    elif args.create is True:
        cmd_create_tables(metadata)
    elif args.insert is True:
        cmd_insert_base_data(engine)
    elif args.delete is True:
        cmd_delete_tables(metadata)
    else:
        console.print("[yellow]Run with -h or --help for usage information.[yellow]")


if __name__ == "__main__":
    main()
