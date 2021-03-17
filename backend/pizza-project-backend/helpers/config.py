import sys

from configparser import ConfigParser 
from pathlib import Path

from defaults import DEFAULT_CONFIG

def create_config(path: Path):
    print(f"Creating config as it doesn't exist: {path.as_posix()}.")
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w") as fp:
        fp.write(DEFAULT_CONFIG)

def read_config() -> ConfigParser:
    find_config_paths = (
        Path("~", ".config", "pizzaapp", "config.ini").expanduser(),
        Path("etc", "pizzaapp", "config.ini"),
    )

    config_path = None
    for path in find_config_paths:
        if path.is_file():
            config_path = path
            break

    config = ConfigParser()
    if config_path is None:
        new_config_path = find_config_paths[0]
        create_config(new_config_path)
        config.read(new_config_path)
    else:
        print(f"Config file found at: {config_path.as_posix()}.")
        config.read(config_path)

    return config

if __name__ == '__main__':
    read_config()