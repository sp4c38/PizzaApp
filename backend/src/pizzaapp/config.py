import sys

from configparser import ConfigParser
from pathlib import Path

from box import Box
from loguru import logger

from src.pizzaapp.exceptions import ConfigValueNotBool
from src.pizzaapp.defaults import DEFAULT_CONFIG


def _create_config(path: Path):
    """Insert the default config file content to a config file.

    Will create missing directories and the file if not existing.

    :param path: Path at which to create the config file.
    """
    print(f"Creating config as it doesn't exist: {path.as_posix()}.")
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as fp:
        fp.write(DEFAULT_CONFIG)


def _translate_to_bool(key: str, value: str, config_path: str) -> bool:
    """Convert a config value to a python boolean."""
    true_strings = ["true", "on", "yes"]
    false_strings = ["false", "off", "no"]

    condition = value.lower()
    if condition in true_strings:
        return True
    if condition in false_strings:
        return False
    raise ConfigValueNotBool(key, value, config_path)


def read_config() -> Box:
    """Read the PizzaApp configuration file.

    If the config file doesn't exist it will be created and filled with a default configuration.
    """
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

    config_json = {sec: dict(config_parsed.items(sec)) for sec in config_parsed.sections()}
    config = Box(config_json)

    config.pizzaapp.debug = _translate_to_bool("debug", config.pizzaapp.debug, config_path.as_posix())
    config.paths.database = Path(config.paths.database).expanduser()
    config.paths.log = Path(config.paths.log).expanduser()

    return config


def configure_logging(config: Box):
    """Configure the python logging module."""
    log_dir_path = config.paths.log
    if log_dir_path.exists():
        if not log_dir_path.is_dir():
            sys.stderr.write(
                f"Directory used to store logs {log_dir_path.as_posix()} is a file, not a directory."
            )
            sys.exit(1)
    else:
        sys.stdout.write(f"Creating log directory at {log_dir_path.as_posix()}.")
        log_path.mkdir(parents=True)

    log_path = log_dir_path / "pizzaapp.log"
    logger.add(
        log_path,
        colorize=None,
        backtrace=True,
        diagnose=True if config.pizzaapp.debug is True else False,
        rotation="1 week",
    )
