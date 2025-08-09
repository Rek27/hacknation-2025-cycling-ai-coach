from fastapi import APIRouter, Header, HTTPException, status
from pydantic import BaseModel, Field
from typing import Optional
import os

try:
    from supabase import create_client
except ImportError:  # Defer import error until runtime if deps not installed yet
    create_client = None  # type: ignore


router = APIRouter(prefix="/api/tools", tags=["Tools"])


class LoadCyclingActivitiesInput(BaseModel):
    start_date_iso: str = Field(..., description="Inclusive ISO-8601 date or datetime string, e.g., 2025-01-01 or 2025-01-01T00:00:00Z")
    end_date_iso: str = Field(..., description="Exclusive ISO-8601 end bound, e.g., 2025-02-01 or 2025-02-01T00:00:00Z")
    user_id: Optional[str] = Field(None, description="Optional user id filter if needed")


class CreateCyclingActivityInput(BaseModel):
    """
    Create one cycling session aligned with `public.cycling_activities` (see create_table_cycling_activities.sql).
    Required: user_id, start_time, end_time, duration_seconds, distance_km.
    Optional: avg_speed_kmh, active_energy_kcal, elevation_gain_m, avg_hr_bpm, max_hr_bpm, vo2max.
    """

    user_id: str = Field(..., description="Athlete UUID (Supabase user id)")
    start_time: str = Field(..., description="ISO-8601 start time, e.g., 2025-06-01T07:00:00Z")
    end_time: str = Field(..., description="ISO-8601 end time, e.g., 2025-06-01T08:15:00Z")
    duration_seconds: int = Field(..., ge=0)
    distance_km: float = Field(..., ge=0)
    avg_speed_kmh: Optional[float] = Field(None, ge=0)
    active_energy_kcal: Optional[float] = Field(None, ge=0)
    elevation_gain_m: Optional[float] = Field(None, ge=0)
    avg_hr_bpm: Optional[float] = Field(None, ge=0)
    max_hr_bpm: Optional[float] = Field(None, ge=0)
    vo2max: Optional[float] = Field(None, ge=0)


def _get_supabase_client():
    if create_client is None:
        raise HTTPException(status_code=500, detail="Supabase client not installed")
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_service_key = os.environ.get("SUPABASE_SERVICE_KEY")
    if not supabase_url or not supabase_service_key:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured")
    return create_client(supabase_url, supabase_service_key)


def _validate_tool_secret(x_tool_secret: Optional[str]):
    expected = os.environ.get("ELEVENLABS_TOOL_SECRET")
    if not expected:
        # Allow running locally without secret while developing
        return
    if x_tool_secret != expected:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")


@router.post("/load_cycling_activities")
def load_cycling_activities(
    payload: LoadCyclingActivitiesInput,
    x_tool_secret: Optional[str] = Header(default=None, alias="x-tool-secret"),
):
    """
    Tool webhook: Loads cycling activities in a date range using a Supabase SQL function.
    Expects a SQL function named `load_cycling_activities` with params
    (p_start_date_iso text, p_end_date_iso text, p_user_id text|null)
    and returns a JSON array of activities.
    """
    _validate_tool_secret(x_tool_secret)
    client = _get_supabase_client()

    rpc_args = {
        "p_start_date_iso": payload.start_date_iso,
        "p_end_date_iso": payload.end_date_iso,
        "p_user_id": payload.user_id,
    }
    result = client.rpc("load_cycling_activities", rpc_args).execute()
    # The python supabase client returns an object with .data and .error depending on version
    data = getattr(result, "data", None)
    error = getattr(result, "error", None)
    if error:
        raise HTTPException(status_code=500, detail=str(error))

    # Normalize response shape for the agent
    return {"activities": data or []}


@router.post("/create_cycling_activity", status_code=status.HTTP_201_CREATED)
def create_cycling_activity(
    payload: CreateCyclingActivityInput,
    x_tool_secret: Optional[str] = Header(default=None, alias="x-tool-secret"),
):
    """
    Tool webhook: Inserts one cycling activity row via Supabase RPC `insert_cycling_activity`.
    Mirrors table columns from create_table_cycling_activities.sql.
    """
    _validate_tool_secret(x_tool_secret)
    client = _get_supabase_client()

    avg_hr_int = int(round(payload.avg_hr_bpm)) if payload.avg_hr_bpm is not None else None
    max_hr_int = int(round(payload.max_hr_bpm)) if payload.max_hr_bpm is not None else None

    rpc_args = {
        "p_user_id": payload.user_id,
        "p_start_time": payload.start_time,
        "p_end_time": payload.end_time,
        "p_duration_seconds": payload.duration_seconds,
        "p_distance_km": payload.distance_km,
        "p_avg_speed_kmh": payload.avg_speed_kmh,
        "p_active_energy_kcal": payload.active_energy_kcal,
        "p_elevation_gain_m": payload.elevation_gain_m,
        "p_avg_hr_bpm": avg_hr_int,
        "p_max_hr_bpm": max_hr_int,
        "p_vo2max": payload.vo2max,
    }

    result = client.rpc("insert_cycling_activity", rpc_args).execute()
    data = getattr(result, "data", None)
    error = getattr(result, "error", None)
    if error:
        raise HTTPException(status_code=500, detail=str(error))

    return {"id": data}


