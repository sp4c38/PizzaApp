#!/usr/bin/env python

import csv

from pathlib import Path

from box import Box
from sqlalchemy.orm import Session

from src.pizzaapp import Base, engine
from src.pizzaapp.defaults import NAMES_OF_TABLES
from src.pizzaapp.tables import Category, Item, ItemPrice, ItemSpeciality


def get_files() -> list[Path]:
    file_dir = Path(__file__).parents[2] / "res" / "base_data"
    dir_items = file_dir.iterdir()
    file_paths = []

    for item in dir_items:
        if not item.is_file():
            continue
        if not item.name.endswith(".csv"):
            continue
        file_paths.append(item)

    file_paths.sort(key=lambda path: path.name)
    return file_paths


def transform_row(row: Box) -> Box:
    for column in row.keys():
        if row[column] == "\\True":
            row[column] = True
        elif row[column] == "\\False":
            row[column] = False

    return row


def load_base_data(files: [Path]) -> Box:
    base_data = Box()

    for file in files:
        table_name_parts = file.name.split("#")
        table_name = max(table_name_parts).removesuffix(".csv")

        with file.open("r", encoding="utf-8-sig") as fp:
            reader = csv.DictReader(fp, delimiter=",")
            file_rows = [transform_row(Box(row)) for row in reader]
            base_data[table_name] = file_rows

    return base_data


def _create_table_records(Table: Base, rows: list[dict]) -> list:
    table_records = []
    for row in rows:
        record = Table(**row)
        table_records.append(record)

    return table_records


def map_base_data(data: dict):
    base_data = []

    for table_name in data.keys():
        table_rows = data[table_name]

        if table_name == NAMES_OF_TABLES["category_table"]:
            mapped_rows = _create_table_records(Category, table_rows)

        elif table_name == NAMES_OF_TABLES["item_table"]:
            mapped_rows = _create_table_records(Item, table_rows)

        elif table_name == NAMES_OF_TABLES["item_price_table"]:
            mapped_rows = _create_table_records(ItemPrice, table_rows)

        elif table_name == NAMES_OF_TABLES["item_speciality_table"]:
            mapped_rows = _create_table_records(ItemSpeciality, table_rows)

        else:
            continue

        base_data.extend(mapped_rows)

    return base_data


def insert_mapped_base_data(data: list):
    with Session(engine, future=True) as session:
        for item in data:
            session.add(item)
        session.commit()


def base_data_populate():
    file_paths = get_files()
    base_data = load_base_data(file_paths)
    mapped_base_data = map_base_data(base_data)
    insert_mapped_base_data(mapped_base_data)
