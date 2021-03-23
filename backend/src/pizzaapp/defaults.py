from pathlib import Path

import yaml

from box import Box

DEFAULT_CONFIG = """\
[db]
path = ~/.pizzaapp/db.sqlite3
"""

_queries_path = Path(__file__).parent / "queries.yaml"
_queries = yaml.safe_load(open(_queries_path))
QUERIES = Box(_queries)
