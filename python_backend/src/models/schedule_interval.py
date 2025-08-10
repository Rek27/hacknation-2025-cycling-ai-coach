from enum import Enum
from pydantic import BaseModel, field_validator
from typing import Optional
from uuid import UUID
from datetime import datetime

class ScheduleType(str, Enum):
    Cycling = "Cycling"
    Work = "Work"
    Other = "Other"

class ScheduleInterval(BaseModel):
    id: UUID
    user_id: UUID
    type: ScheduleType
    start_at: datetime  # tz-aware
    end_at: datetime    # tz-aware
    title: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @field_validator("start_at", "end_at", "created_at", "updated_at")
    @classmethod
    def tz_aware(cls, v: datetime) -> datetime:
        if v is None:
            return v
        if v.tzinfo is None or v.tzinfo.utcoffset(v) is None:
            raise ValueError("timestamps must be timezone-aware")
        return v
