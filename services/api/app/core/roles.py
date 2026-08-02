"""Rol sabitleri — mobil paket ile aynı değerler."""
from enum import Enum


class Role(str, Enum):
    SUPER_ADMIN = "super_admin"
    COMPANY_ADMIN = "company_admin"
    OPERATIONS_MANAGER = "operations_manager"
    DRIVER = "driver"
    PASSENGER = "passenger"


# Yönetici arayüzüne erişebilen roller
ADMIN_ROLES = {Role.COMPANY_ADMIN, Role.OPERATIONS_MANAGER}
