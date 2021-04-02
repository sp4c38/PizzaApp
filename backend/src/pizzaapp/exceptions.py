class ConfigValueNotBool(Exception):
    """ Exception indicating that a value inside the config can't be mapped to a python boolean."""

    def __init__(self, key: str, value: str, config_path: str):
        super().__init__(key, value, config_path)
        self.key = key
        self.value = value
        self.config_path = config_path

    def __str__(self):
        return (
            f'Key "{self.key}" with value "{self.value}" in '
            f"config file {self.config_path} can't be converted to a bool. "
            "Use values like true, on, yes or false, off, no (case insensitive)."
        )


class RequiredTableMissing(Exception):
    """Exception raised whenever a required table is missing inside the database.
    Example:
    At startup the program checks if all tables required for the backend exist.
    """

    def __init__(self, table_name: str, db_path: str):
        super().__init__(table_name, db_path)
        self.table_name = table_name
        self.db_path = db_path

    def __str__(self):
        return (
            f'Required table "{self.table_name}" does not exist in database ' f"at {self.db_path}."
        )
