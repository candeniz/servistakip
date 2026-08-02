"""Alembic ortam yapılandırması (senkron psycopg sürücüsü ile)."""
import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config, pool

# Modelleri içe aktar ki Base.metadata tüm tabloları bilsin.
from app.core.database import Base
import app.models  # noqa: F401  (tüm modelleri kaydeder)

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def _database_url() -> str:
    # Senkron sürücü (psycopg) kullan; asyncpg URL'si verilirse dönüştür.
    url = os.getenv("ALEMBIC_DATABASE_URL") or os.getenv("DATABASE_URL", "")
    return url.replace("+asyncpg", "+psycopg")


def run_migrations_offline() -> None:
    context.configure(
        url=_database_url(),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    configuration = config.get_section(config.config_ini_section) or {}
    configuration["sqlalchemy.url"] = _database_url()
    connectable = engine_from_config(
        configuration, prefix="sqlalchemy.", poolclass=pool.NullPool
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata, compare_type=True)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
