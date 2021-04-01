

class ConfigValueNotBool(Exception):
    def __init__(self, key: str, value: str, config_path: str):
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
    def __init__(self, table_name: str, db_path: str):
        self.table_name = table_name
        self.db_path = db_path

    def __str__(self):
        return (
            f'Required table "{self.table_name}" does not exist in database '
            f"at {self.db_path}."
        )
