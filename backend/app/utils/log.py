import logging
import sys
from enum import Enum
from pathlib import Path
from typing import Optional

from loguru import logger
from loguru._logger import Logger
from pydantic import BaseSettings


class LoggingLevel(str, Enum):
    """Allowed log levels for the application"""

    CRITICAL: str = "CRITICAL"
    ERROR: str = "ERROR"
    WARNING: str = "WARNING"
    INFO: str = "INFO"
    DEBUG: str = "DEBUG"


class LoggingSettings(BaseSettings):
    """Configure your service logging using a LoggingSettings instance.

    Args:
        level (str, optional): the minimum log-level to log. Default to "DEBUG".
        format (str, optional): the logformat to use. Default to "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | <level>{message}</level>".
        filepath (Path, optional): the path where to store the logfiles. Default to None.
        rotation (str, optional): when to rotate the logfile. Default to "1 days".
        retention (str, optional): when to remove logfiles. Default to "1 months".

    """

    level: LoggingLevel = "DEBUG"
    format: str = (
        "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
        "<level>{level: <8}</level> | "
        "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | "
        "<level>{message}</level>"
    )
    filepath: Optional[Path] = None
    rotation: str = "1 days"
    retention: str = "1 months"

    class Config:
        env_prefix = "logging_"


class InterceptHandler(logging.Handler):
    """[summary]

    Args:
        logging ([type]): [description]
    """

    def emit(self, record):
        # Get corresponding Loguru level if it exists
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # Find caller from where originated the logged message
        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


def setup_logger(
    level: str,
    format: str,
    filepath: Optional[Path] = None,
    rotation: Optional[str] = None,
    retention: Optional[str] = None,
) -> Logger:
    """Define the global logger to be used by your entire service.

    Args:
        level (str): The minimum log-level to log.
        format (str): The logformat to use.
        filepath (Optional[Path], optional): The path where to store the logfiles. Defaults to None.
        rotation (Optional[str], optional): When to rotate the logfile.. Defaults to None.
        retention (Optional[str], optional): When to remove logfiles.. Defaults to None.

    Returns:
        Logger: The logger to be used by the service.

    References:
        - [Loguru: Intercepting logging logs #247](https://github.com/Delgan/loguru/issues/247)
        - [Gunicorn: generic logging options #1572](https://github.com/benoitc/gunicorn/issues/1572#issuecomment-638391953)
    """
    # Remove loguru default logger
    logger.remove()
    # Cath all existing loggers
    LOGGERS = [logging.getLogger(name) for name in logging.root.manager.loggerDict]
    # Add stdout logger
    logger.add(
        sys.stdout,
        enqueue=True,
        colorize=True,
        backtrace=True,
        level=level.upper(),
        format=format,
    )
    # Optionally add filepath logger
    if filepath:
        Path(filepath).parent.mkdir(parents=True, exist_ok=True)
        logger.add(
            str(filepath),
            rotation=rotation,
            retention=retention,
            enqueue=True,
            colorize=False,
            backtrace=True,
            level=level.upper(),
            format=format,
        )
    # Overwrite config of standard library root logger
    logging.basicConfig(handlers=[InterceptHandler()], level=0)
    # Overwrite handlers of all existing loggers from standard library logging
    for _logger in LOGGERS:
        _logger.handlers = [InterceptHandler()]
        _logger.propagate = False

    return logger


def setup_logger_from_settings(settings: Optional[LoggingSettings] = None) -> Logger:
    """Define the global logger to be used by your entire service.

    Args:
        settings (Optional[LoggingSettings], optional): The logging settings to apply. Defaults to None.

    Returns:
        Logger: The logger instance.

    """

    # Parse from env when no settings are given
    if not settings:
        settings = LoggingSettings()
    # Return logger even though it's not necessary
    return setup_logger(
        settings.level,
        settings.format,
        settings.filepath,
        settings.rotation,
        settings.retention,
    )
