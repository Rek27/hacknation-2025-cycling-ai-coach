from __future__ import annotations

"""Pydantic model for cycling activity rows.

Represents records from `public.cycling_activities` returned by Supabase RPCs.
The model uses database snake_case field names to avoid mapping overhead.
Utility properties provide derived values used by analytics endpoints.
"""

from datetime import datetime, timedelta
from typing import Optional, Tuple
from uuid import UUID

from pydantic import BaseModel


class CyclingActivity(BaseModel):
    """Cycling activity row with helpers for analytics.

    Fields mirror database columns (snake_case) to match Supabase RPC results.
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
        """Compute speed from distance and duration when missing in the row.

        Returns None if duration is zero or not set.
        """
        if self.duration_seconds is None or self.duration_seconds <= 0:
            return None
        return float(self.distance_km) / (self.duration_seconds / 3600.0)

    @property
    def day_key(self) -> str:
        """Return ISO date string (YYYY-MM-DD) for the activity's start day (UTC)."""
        return self.started_at.date().isoformat()

    @property
    def iso_week_info(self) -> Tuple[int, int, str]:
        """Return (iso_year, iso_week, week_start_monday_iso_date)."""
        iso_year, iso_week, iso_weekday = self.started_at.isocalendar()
        monday = (self.started_at - timedelta(days=iso_weekday - 1)).date().isoformat()
        return iso_year, iso_week, monday


