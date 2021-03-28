import sys

from configparser import ConfigParser
from pathlib import Path

from box import Box

from src.pizzaapp.defaults import DEFAULT_CONFIG


def _create_config(path: Path):
    print(f"Creating config as it doesn't exist: {path.as_posix()}.")
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as fp:
        fp.write(DEFAULT_CONFIG)


def read_config() -> Box:
    find_config_paths = (
        Path("~", ".config", "pizzaapp", "config.ini").expanduser(),
        Path("etc", "pizzaapp", "config.ini"),
    )

    config_path = None
    for path in find_config_paths:
        if path.is_file():
            config_path = path
            break

    config_parsed = ConfigParser()
    if config_path is None:
        new_config_path = find_config_paths[0]
        _create_config(new_config_path)
        config_parsed.read(new_config_path)
    else:
        config_parsed.read(config_path)

    config_json = {
        sec: dict(config_parsed.items(sec)) for sec in config_parsed.sections()
    }
    config = Box(config_json)

    config.db.path = Path(config.db.path).expanduser()

    return config


if __name__ == "__main__":
    config = read_config()
    config_toml = config.to_dict()
    print(f"Read config: {config_toml}")