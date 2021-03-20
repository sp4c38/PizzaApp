#!/usr/bin/env python

import csv
import sqlite3
import traceback

from pathlib import Path

from config import read_config
from database import DatabaseManager, check_table_exists, sanitize_string


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

    return data_csv


def parse_csvs(files: [Path]):
    all_data = {}
    for file in files:
        table_name = file.name.removesuffix(".csv")
        with file.open("r", encoding="utf-8-sig") as fp:
            reader = csv.DictReader(fp, delimiter=",")
            file_data = [row for row in reader]
            all_data[table_name] = file_data

    return all_data


def insert_base_data(manager: DatabaseManager, base_data: dict):
    cursor = manager.conn.cursor()
    for table in base_data:
        if check_table_exists(cursor, table):
            for base_row in base_data[table]:
                table_name = str(table)
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

        else:
            print(f"Won't insert base data as table doesn't exist: {table}")

    manager.conn.commit()
    cursor.close()


def main():
    config = read_config()
    data_files = get_base_data_files()
    db_manager = DatabaseManager(config)
    base_data = parse_csvs(data_files)
    insert_base_data(db_manager, base_data)


if __name__ == "__main__":
    main()
