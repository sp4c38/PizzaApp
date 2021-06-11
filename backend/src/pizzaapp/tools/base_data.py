"""Load and insert base data to the database."""

import csv

from pathlib import Path

from box import Box
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session

from pizzaapp.app import Base
from pizzaapp.app.defaults import NAMES_OF_TABLES
from pizzaapp.app.tables import Category, Item, ItemPrice, ItemSpeciality


def get_files() -> list[Path]:
    """Get paths of all CSV files containing base table data.

    CSV files are tried to be lcoated in backend/res/base_data.
    """
    file_dir = Path(__file__).parents[3] / "res" / "base_data"
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
    r"""Apply multiple transformations on the values of a row.

    Example:
    Map all \True (one backslash) values to a python boolean.
    """
    for column in row.keys():
        if row[column] == "\\True":
            row[column] = True
        elif row[column] == "\\False":
            row[column] = False

    return row


def load_base_data(files: list[Path]) -> Box:
    """Load the base data CSV files.

    Also runs the row transformation function on each row.
    """
    base_data = Box()

    for file in files:
        table_name_parts = file.name.split("#")
        table_name = max(table_name_parts).removesuffix(".csv")

        with file.open("r", encoding="utf-8-sig") as fp:
            reader = csv.DictReader(fp, delimiter=",")
            file_rows = [transform_row(Box(row)) for row in reader]
            base_data[table_name] = file_rows

    return base_data


def _create_table_records(Table: Base, rows: list[dict]) -> list[Base]:
    """Convert rows of a certain table type to table objects.

    Table objects are the ORM objects representing tables. For example Category or Item.

    :param Table: The table object to which to convert to.
    :param rows: A list of rows with each row represented by a dictionary. The dictionary
        keys (column names) must match the names of the attributes on the table object.
    :return: A list with table objects.
    """
    table_records = []
    for row in rows:
        record = Table(**row)
        table_records.append(record)

    return table_records


def map_base_data(data: dict):
    """Map the base data rows to their exact table object.

    The difference to _create_table_records is that this function takes
    care of mapping all rows of a table to their exact table object type (like Category).
    It then calls _create_table_records to get all table objects of a certain type.
    """
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


def insert_mapped_base_data(engine: Engine, data: list):
    """Insert a set of rows containing one or multiple different table object row types."""
    with Session(engine, future=True) as session:
        for item in data:
            session.add(item)
        session.commit()


def base_data_populate(engine: Engine):
    """Insert base data into database by reading CSV files."""
    file_paths = get_files()
    base_data = load_base_data(file_paths)
    mapped_base_data = map_base_data(base_data)
    insert_mapped_base_data(engine, mapped_base_data)
