from __future__ import annotations

from datetime import datetime, timedelta
from typing import Optional, Tuple
from uuid import UUID

from pydantic import BaseModel


class CyclingActivity(BaseModel):
    """
    Python representation of a cycling activity row from `public.cycling_activities`.

    Fields follow the database snake_case naming to match Supabase RPC results.
    """

    id: Optional[UUID] = None
    user_id: Optional[UUID] = None

    started_at: datetime
    ended_at: datetime
    duration_seconds: int
    distance_km: float

    avg_speed_kmh: Optional[float] = None
    active_energy_kcal: Optional[float] = None
    elevation_gain_m: Optional[float] = None
    avg_hr_bpm: Optional[int] = None
    max_hr_bpm: Optional[int] = None
    vo2max: Optional[float] = None

    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @property
    def computed_speed_kmh(self) -> Optional[float]:
        """Compute speed from distance and duration when not provided or for consistency.

        Returns None when duration is zero or missing.
        """
        if self.duration_seconds is None or self.duration_seconds <= 0:
            return None
        return float(self.distance_km) / (self.duration_seconds / 3600.0)

    @property
    def day_key(self) -> str:
        """ISO date string (YYYY-MM-DD) for the activity's start day (UTC)."""
        return self.started_at.date().isoformat()

    @property
    def iso_week_info(self) -> Tuple[int, int, str]:
        """Return (iso_year, iso_week, week_start_monday_iso_date)."""
        iso_year, iso_week, iso_weekday = self.started_at.isocalendar()
        monday = (self.started_at - timedelta(days=iso_weekday - 1)).date().isoformat()
        return iso_year, iso_week, monday


