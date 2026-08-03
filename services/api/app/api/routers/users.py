"""Kullanıcı yönetimi — yönetici kendi tenant'ı içinde alt kullanıcı oluşturur."""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from sqlalchemy import select

from app.core.deps import CurrentUser, DbSession, require_roles
from app.core.roles import ADMIN_ROLES, Role
from app.core.security import hash_password
from app.models.user import EmployeeProfile, User
from app.schemas.common import MessageResponse, Paginated
from app.schemas.entities import UserCreate, UserOut, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])

_admin = require_roles(Role.COMPANY_ADMIN, Role.OPERATIONS_MANAGER)

# Yöneticinin oluşturabileceği roller (super_admin oluşturulamaz).
_CREATABLE_ROLES = {
    Role.COMPANY_ADMIN.value,
    Role.OPERATIONS_MANAGER.value,
    Role.DRIVER.value,
    Role.PASSENGER.value,
}


@router.get("", response_model=Paginated[UserOut])
async def list_users(db: DbSession, current: User = Depends(_admin)) -> Paginated[UserOut]:
    # Tenant izolasyonu: yalnızca kendi şirketinin kullanıcıları.
    result = await db.execute(select(User).where(User.tenant_id == current.tenant_id))
    users = result.scalars().all()
    return Paginated[UserOut](items=[UserOut.model_validate(u) for u in users], total=len(users))


@router.post("", response_model=UserOut, status_code=201)
async def create_user(body: UserCreate, db: DbSession, current: User = Depends(_admin)) -> UserOut:
    if body.role not in _CREATABLE_ROLES:
        raise HTTPException(status_code=403, detail="Bu rol oluşturulamaz.")
    existing = await db.execute(select(User).where(User.email == body.email.lower()))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Bu e-posta zaten kayıtlı.")
    user = User(
        tenant_id=current.tenant_id,  # tenant client'tan alınmaz, mevcut kullanıcıdan gelir
        first_name=body.first_name,
        last_name=body.last_name,
        email=body.email.lower(),
        phone=body.phone,
        role=body.role,
        password_hash=hash_password(body.password),
        status="active",
    )
    db.add(user)
    await db.flush()
    return UserOut.model_validate(user)


async def _get_scoped_user(db: DbSession, current: User, user_id: str) -> User:
    user = await db.get(User, user_id)
    if user is None or user.tenant_id != current.tenant_id:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı.")
    return user


@router.get("/{user_id}", response_model=UserOut)
async def get_user(user_id: str, db: DbSession, current: User = Depends(_admin)) -> UserOut:
    return UserOut.model_validate(await _get_scoped_user(db, current, user_id))


@router.patch("/{user_id}", response_model=UserOut)
async def update_user(user_id: str, body: UserUpdate, db: DbSession, current: User = Depends(_admin)) -> UserOut:
    user = await _get_scoped_user(db, current, user_id)
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    return UserOut.model_validate(user)


@router.delete("/{user_id}", response_model=MessageResponse)
async def delete_user(user_id: str, db: DbSession, current: User = Depends(_admin)) -> MessageResponse:
    user = await _get_scoped_user(db, current, user_id)
    user.status = "disabled"  # yumuşak silme
    return MessageResponse(detail="Kullanıcı pasife alındı.")


class UserImportRow(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone: str | None = None
    role: str = Role.PASSENGER.value
    employee_number: str | None = None
    department: str | None = None


class UserImportBody(BaseModel):
    users: list[UserImportRow]
    default_password: str = "Servis123!"


class UserImportResult(BaseModel):
    created: int
    skipped: int
    errors: list[str]


@router.post("/import", response_model=UserImportResult)
async def import_users(body: UserImportBody, db: DbSession, current: User = Depends(_admin)) -> UserImportResult:
    """Excel/CSV'den ayrıştırılmış personel satırlarını toplu oluşturur.

    Geçersiz rol ve kayıtlı e-postalar atlanır; her satır savepoint içinde işlenir,
    böylece bir hatalı satır diğerlerini bozmaz. Tenant client'tan değil oturumdan alınır.
    """
    created = 0
    skipped = 0
    errors: list[str] = []

    for i, row in enumerate(body.users, start=1):
        email = row.email.lower()
        if row.role not in _CREATABLE_ROLES:
            errors.append(f"Satır {i} ({email}): geçersiz rol '{row.role}'")
            continue
        exists = await db.execute(select(User.id).where(User.email == email))
        if exists.scalar_one_or_none():
            skipped += 1
            continue
        try:
            async with db.begin_nested():  # satır bazlı savepoint
                user = User(
                    tenant_id=current.tenant_id,
                    first_name=row.first_name,
                    last_name=row.last_name,
                    email=email,
                    phone=row.phone,
                    role=row.role,
                    password_hash=hash_password(body.default_password),
                    status="active",
                )
                db.add(user)
                await db.flush()
                if row.employee_number or row.department:
                    db.add(
                        EmployeeProfile(
                            tenant_id=current.tenant_id or "",
                            user_id=user.id,
                            employee_number=row.employee_number,
                            department_id=row.department,
                        )
                    )
            created += 1
        except Exception:  # noqa: BLE001 — satır hatası tüm yüklemeyi durdurmasın
            errors.append(f"Satır {i} ({email}): kayıt hatası")

    return UserImportResult(created=created, skipped=skipped, errors=errors)
