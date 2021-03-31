#!/usr/bin/env python

import argparse
import sys

from rich.console import Console
from rich.prompt import Confirm

from src.pizzaapp import config, engine, registry

TABLE_OPERATIONS = ["create", "delete"]

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
        "operation",
        action="store",
        nargs="?",
        default=None,
        choices=TABLE_OPERATIONS,
        help="manipulate PizzaApp tables",
    )
    return parser


def create_tables():
    metadata.create_all(checkfirst=True)
    console.print(
        "[green bold]Created PizzaApp tables in database.[/green bold]"
    )


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
    elif args.operation is not None:
        if args.operation == TABLE_OPERATIONS[0]:
            create_tables()
        elif args.operation == TABLE_OPERATIONS[1]:
            delete_tables()
    else:
        console.print("[yellow]Run with -h or --help for usage information.[yellow]")


if __name__ == "__main__":
    main()
