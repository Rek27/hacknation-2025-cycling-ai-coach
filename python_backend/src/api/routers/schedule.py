from __future__ import annotations

from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status

try:
    from supabase import create_client
except ImportError:
    create_client = None  # type: ignore

from datetime import datetime

from src.models.schedule_interval import ScheduleInterval, ScheduleType
import os


router = APIRouter(prefix="/schedule", tags=["Schedule"])


def _get_supabase_client():
    if create_client is None:
        raise HTTPException(status_code=500, detail="Supabase client not installed")
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_anon_key = os.environ.get("SUPABASE_ANON_KEY")
    if not supabase_url or not supabase_anon_key:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured")
    return create_client(supabase_url, supabase_anon_key)


def _parse_uuid(value: Optional[str]) -> Optional[str]:
    if value is None or value == "":
        return None
    try:
        return str(UUID(value))
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid UUID provided")


@router.get("/intervals", status_code=status.HTTP_200_OK)
def list_intervals(
    start_date_iso: str = Query(..., alias="startDateIso", description="Inclusive ISO-8601 UTC start (e.g., 2025-06-01T00:00:00Z)"),
    end_date_iso: str = Query(..., alias="endDateIso", description="Exclusive ISO-8601 UTC end (boundary not included)"),
    user_id: Optional[str] = Query(None, alias="userId"),
    types_csv: Optional[str] = Query(None, alias="types", description="Optional comma-separated types: Cycling,Work,Other"),
) -> Dict[str, Any]:
    client = _get_supabase_client()

    p_user_uuid = _parse_uuid(user_id)

    p_types: Optional[List[str]] = None
    if types_csv:
        seq = [t.strip() for t in types_csv.split(",") if t.strip()]
        # Validate against enum values
        valid = {e.value for e in ScheduleType}
        for t in seq:
            if t not in valid:
                raise HTTPException(status_code=400, detail=f"Invalid type '{t}'. Must be one of {sorted(valid)}")
        p_types = seq if seq else None

    res = client.rpc(
        "list_schedule_intervals",
        {
            "p_start": start_date_iso,
            "p_end": end_date_iso,
            "p_user_id": p_user_uuid,
            **({"p_types": p_types} if p_types is not None else {}),
        },
    ).execute()

    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(status_code=500, detail=str(err))
    rows: List[Dict[str, Any]] = data or []
    items = [ScheduleInterval(**row) for row in rows]
    return {"intervals": items}


@router.post("/intervals", status_code=status.HTTP_200_OK)
def create_interval(payload: Dict[str, Any]) -> Dict[str, Any]:
    client = _get_supabase_client()

    # Required fields
    user_id = payload.get("userId")
    type_str = payload.get("type")
    start_iso = payload.get("startIso")
    end_iso = payload.get("endIso")

    if not user_id or not type_str or not start_iso or not end_iso:
        raise HTTPException(status_code=400, detail="userId, type, startIso, endIso are required")

    # Validate UUID and enum
    p_user_uuid = _parse_uuid(user_id)
    try:
        stype = ScheduleType(type_str)
    except Exception:
        valid = [e.value for e in ScheduleType]
        raise HTTPException(status_code=400, detail=f"Invalid type '{type_str}'. Must be one of {valid}")

    title = payload.get("title")
    description = payload.get("description")

    res = client.rpc(
        "create_schedule_interval",
        {
            "p_user_id": p_user_uuid,
            "p_type": stype.value,
            "p_start": start_iso,
            "p_end": end_iso,
            "p_title": title,
            "p_description": description,
        },
    ).execute()

    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(status_code=500, detail=str(err))

    new_id = data
    try:
        # Ensure it's a UUID string
        new_id = str(UUID(str(data)))
    except Exception:
        pass

    return {"id": new_id}


@router.patch("/intervals", status_code=status.HTTP_200_OK)
def update_interval(payload: Dict[str, Any]) -> Dict[str, Any]:
    client = _get_supabase_client()

    p_id = payload.get("id")
    if not p_id:
        raise HTTPException(status_code=400, detail="id is required")
    try:
        p_id = str(UUID(str(p_id)))
    except Exception:
        raise HTTPException(status_code=400, detail="id must be a UUID")

    new_start = payload.get("newStartIso")
    new_end = payload.get("newEndIso")
    type_str = payload.get("type")
    title = payload.get("title")
    description = payload.get("description")
    snap = payload.get("snap", True)

    p_type: Optional[str] = None
    if type_str is not None:
        try:
            p_type = ScheduleType(type_str).value
        except Exception:
            valid = [e.value for e in ScheduleType]
            raise HTTPException(status_code=400, detail=f"Invalid type '{type_str}'. Must be one of {valid}")

    res = client.rpc(
        "update_schedule_interval_by_id",
        {
            "p_id": p_id,
            **({"p_new_start": new_start} if new_start is not None else {}),
            **({"p_new_end": new_end} if new_end is not None else {}),
            **({"p_type": p_type} if p_type is not None else {}),
            **({"p_title": title} if title is not None else {}),
            **({"p_description": description} if description is not None else {}),
            "p_snap": bool(snap),
        },
    ).execute()

    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(status_code=500, detail=str(err))

    rows: List[Dict[str, Any]] = data or []
    if not rows:
        raise HTTPException(status_code=404, detail="Interval not found")
    interval = ScheduleInterval(**rows[0])
    return {"interval": interval}


@router.delete("/intervals", status_code=status.HTTP_200_OK)
def delete_interval(
    interval_id: str = Query(..., alias="id", description="Interval UUID to delete"),
) -> Dict[str, Any]:
    """Delete a schedule interval by id via Supabase RPC."""
    client = _get_supabase_client()

    try:
        p_id = str(UUID(str(interval_id)))
    except Exception:
        raise HTTPException(status_code=400, detail="id must be a UUID")

    res = client.rpc(
        "delete_schedule_interval_by_id",
        {"p_id": p_id},
    ).execute()

    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(status_code=500, detail=str(err))

    # The RPC returns the deleted id or raises an error if not found
    deleted_id = data
    try:
        deleted_id = str(UUID(str(data)))
    except Exception:
        pass

    if not deleted_id:
        raise HTTPException(status_code=404, detail="Interval not found")

    return {"id": deleted_id}

