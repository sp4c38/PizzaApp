#!/usr/bin/env python

import argparse
import sys

from rich.console import Console
from rich.prompt import Confirm

from src.pizzaapp import config, engine, registry
from src.tools.base_data import base_data_populate

console = Console(highlight=True)

metadata = registry.metadata


def get_parser():
    parser = argparse.ArgumentParser(
        description="Perform operations to setup the database for the PizzaApp backend."
    )
    parser.add_argument(
        "-g", action="store_true", help="return database path", dest="show_db_path"
    )
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


def create_tables():
    metadata.create_all(checkfirst=True)
    console.print("[green bold]Created PizzaApp tables in database.[/green bold]")


def insert_base_data():
    base_data_populate()
    console.print("[green bold]Inserted PizzaApp base data.[/green bold]")


def delete_tables():
    really_delete = Confirm.ask(
        "[red bold]Delete all existing PizzaApp tables?[/red bold]"
    )

    if really_delete:
        metadata.drop_all(checkfirst=True)
        console.print("[green bold]All PizzaApp tables were deleted.[/green bold]")
    else:
        console.print("[green bold]No PizzaApp tables were deleted.[/green bold]")


def main():
    parser = get_parser()
    args = parser.parse_args()

    if args.show_db_path:
        console.print(f"[bold blue]Database path:[/bold blue] {config.db.path}")
    elif args.create is True:
        create_tables()
    elif args.insert is True:
        insert_base_data()
    elif args.delete is True:
        delete_tables()
    else:
        console.print("[yellow]Run with -h or --help for usage information.[yellow]")


if __name__ == "__main__":
    main()