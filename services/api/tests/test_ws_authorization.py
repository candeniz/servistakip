"""WebSocket kanal yetkilendirme testleri (DB gerektirmeyen dallar)."""
import pytest

from app.models.user import User
from app.ws.router import _authorize_channel

pytestmark = pytest.mark.asyncio


def _user(role: str, user_id: str, tenant_id: str | None) -> User:
    return User(
        id=user_id, tenant_id=tenant_id, first_name="T", last_name="U",
        email=f"{user_id}@demo.com", role=role, password_hash="x", status="active",
    )


async def test_user_can_only_access_own_notification_channel() -> None:
    user = _user("passenger", "u-1", "t-1")
    assert await _authorize_channel(user, "user:u-1:notifications") is True
    assert await _authorize_channel(user, "user:u-2:notifications") is False


async def test_admin_can_access_own_tenant_operations() -> None:
    admin = _user("company_admin", "u-admin", "t-1")
    assert await _authorize_channel(admin, "tenant:t-1:operations") is True
    # Başka tenant'ın operasyon kanalına erişemez.
    assert await _authorize_channel(admin, "tenant:t-2:operations") is False


async def test_passenger_cannot_access_tenant_operations() -> None:
    passenger = _user("passenger", "u-1", "t-1")
    assert await _authorize_channel(passenger, "tenant:t-1:operations") is False


async def test_super_admin_can_access_any_tenant_operations() -> None:
    su = _user("super_admin", "u-su", None)
    assert await _authorize_channel(su, "tenant:t-1:operations") is True
    assert await _authorize_channel(su, "tenant:t-9:operations") is True


async def test_unknown_channel_denied() -> None:
    user = _user("company_admin", "u-admin", "t-1")
    assert await _authorize_channel(user, "random:channel") is False
