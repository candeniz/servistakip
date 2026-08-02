"""İlk şema — tüm tablolar + PostGIS eklentisi.

Revision ID: 0001_initial
Revises:
Create Date: 2026-08-02
"""
from typing import Sequence, Union

from alembic import op

from app.core.database import Base
import app.models  # noqa: F401  (tüm modelleri metadata'ya kaydeder)

revision: str = "0001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    # PostGIS ileride coğrafi sorgular için hazır olsun (MVP lat/lng float kullanır).
    if bind.dialect.name == "postgresql":
        op.execute("CREATE EXTENSION IF NOT EXISTS postgis")
    # İlk sürümde tüm tabloları metadata'dan oluştur (DRY ve tutarlı).
    Base.metadata.create_all(bind=bind)


def downgrade() -> None:
    bind = op.get_bind()
    Base.metadata.drop_all(bind=bind)
