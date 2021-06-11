"""Commands to add and modify the projects database tables."""

from sqlalchemy import MetaData


def create_tables(metadata: MetaData):
    """Create all of the project tables.

    The projects tables must have been added to the projects MetaData.
    This is handled by the main projects __init__.py.
    """
    metadata.create_all(checkfirst=True)


def delete_tables(metadata: MetaData):
    """Delete all projects tables.

    See the create_table function how these tables are located.
    """
    metadata.drop_all(checkfirst=True)
