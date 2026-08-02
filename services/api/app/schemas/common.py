"""Ortak şemalar."""
from typing import Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class Paginated(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int = 1
    page_size: int = 50


class MessageResponse(BaseModel):
    detail: str
