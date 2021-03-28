class RequiredTableMissing(Exception):
    def __init__(self, table_name: str, db_path: str):
        self.table_name = table_name
        self.db_path = db_path

    def __str__(self):
        return f"""
        Required table "{self.table_name}" does not exist in database at {self.db_path}.
        """
