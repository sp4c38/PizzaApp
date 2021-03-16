import sys

from configparser import ConfigParser 
from pathlib import Path

from .defaults import DEFAULT_CONFIG

def create_config(path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w") as fp:
        fp.write(DEFAULT_CONFIG)

def read_config():
    config_paths = (
        Path("~", ".config", "pizzaapp", "config.ini").expanduser(),
        Path("etc", "pizzaapp", "config.ini"),
    )

    config_path = None
    for path in config_paths:
        if path.is_file():
            config_path = path
            break

    if config_path is None:
        create_config(config_path)