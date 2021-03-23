#!/usr/bin/env python

import csv
import sqlite3
import traceback

from pathlib import Path

from src.pizzaapp.config import read_config
from src.pizzaapp.database import DatabaseManager, check_table_exists


def get_base_data_files():
    data_dir = Path(__file__).parents[2] / "res" / "base_db_data"
    data_items = data_dir.iterdir()

    data_csv = []
    for item in data_items:
        if not item.is_file():
            continue
        if not item.name.endswith("csv"):
            continue
        data_csv.append(item)
    data_csv.sort(key=lambda path: path.name)
    return data_csv


def parse_base_data_files(files: [Path]):
    all_data = {}
    for file in files:
        table_name_parts = file.name.split("#")
        table_name = max(table_name_parts).removesuffix(".csv")

        with file.open("r", encoding="utf-8-sig") as fp:
            reader = csv.DictReader(fp, delimiter=",")
            file_rows = [row for row in reader]
            all_data[table_name] = file_rows

    return all_data


def insert_base_data(manager: DatabaseManager, base_data: dict):
    cursor = manager.conn.cursor()
    for table in base_data:
        if check_table_exists(cursor, table):
            table_name = str(table)
            for base_row in base_data[table]:
                columns = [str(c) for c in base_row.keys()]
                columns_name = ", ".join(columns)
                values = tuple(base_row.values())

                query = f"""
                INSERT INTO {table_name}({columns_name}) VALUES({", ".join(["?" for i in range(0, len(columns))])})
                """

                try:
                    cursor.execute(query, values)
                except sqlite3.IntegrityError as exp:
                    print(f"Couldn't insert base data {base_row}: {exp}.")

            print(f"Inserted base data for table {table_name}.")

            manager.conn.commit()
        else:
            print(f"Won't insert base data as table doesn't exist: {table}")
    cursor.close()


def base_data_populate(db_manager: DatabaseManager):
    base_data_files = get_base_data_files()
    base_data = parse_base_data_files(base_data_files)
    insert_base_data(db_manager, base_data)


def main():
    config = read_config()

    db_manager = DatabaseManager(Path(config.db.path))
    base_data_populate(db_manager)


if __name__ == "__main__":
    main()
