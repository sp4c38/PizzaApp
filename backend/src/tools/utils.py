from pathlib import Path


def get_tools_query(name: str) -> str:
    current_path = Path(__file__).parents[0]
    query_path = current_path / "queries" / name
    query = query_path.read_text()
    return query
