from __future__ import annotations

from typing import Optional, Any, Dict
from uuid import UUID
import os

from fastapi import APIRouter, HTTPException, status, Depends, Request, Body, Query
from pydantic import BaseModel, Field, ConfigDict, constr, ValidationError
import json

try:
    from supabase import create_client
except ImportError:
    create_client = None  # type: ignore

router = APIRouter(prefix="/memories", tags=["Memories"])
FIXED_USER_ID = UUID("00000000-0000-0000-0000-000000000000")

class CreateMemoryRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)  # accept alias keys
    user_id: UUID = Field(alias="userId")
    content: constr(strip_whitespace=True, min_length=1)
    title: Optional[str] = None

def _get_supabase_client():
    if create_client is None:
        raise HTTPException(500, "Supabase client not installed")
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_ANON_KEY")
    if not url or not key:
        raise HTTPException(500, "Supabase credentials not configured")
    return create_client(url, key)

@router.post("", status_code=status.HTTP_200_OK)
async def create_memory(request: Request, client = Depends(_get_supabase_client)):
    raw = await request.body()                               # <- await
    try:
        payload = json.loads(raw or b"{}")
    except json.JSONDecodeError as e:
        raise HTTPException(400, f"Invalid JSON: {e}")

    # If ElevenLabs wraps as {"body": {...}}, unwrap:
    if isinstance(payload, dict) and isinstance(payload.get("body"), dict):
        payload = payload["body"]

    # Validate explicitly to see precise field errors
    try:
        payload["userId"] = FIXED_USER_ID
        req = CreateMemoryRequest.model_validate(payload)
    except ValidationError as e:
        # Return and log exact validation errors (what 422 means in FastAPI)
        raise HTTPException(status_code=422, detail=e.errors())

    res = client.rpc(
        "create_user_memory",
        {"p_user_id": str(req.user_id), "p_title": req.title, "p_content": req.content},
    ).execute()

    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(500, str(err))
    if not data:
        raise HTTPException(500, "Empty response from RPC")

    try:
        new_id = str(UUID(str(data)))
    except Exception:
        new_id = str(data)
    return {"id": new_id}


@router.delete("/{memory_id}", status_code=status.HTTP_200_OK)
def delete_memory(memory_id: str, client = Depends(_get_supabase_client)):
    # validate UUID
    try:
        p_id = str(UUID(memory_id))
    except Exception:
        # client error -> raise HTTPException
        raise HTTPException(status_code=400, detail="id must be a UUID")  # raised, not returned. :contentReference[oaicite:1]{index=1}

    # always use FIXED_USER_ID
    res = client.rpc(
        "delete_user_memory",
        {"p_id": p_id, "p_user_id": str(FIXED_USER_ID)},
    ).execute()

    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(status_code=500, detail=str(err))
    if not data:
        raise HTTPException(status_code=404, detail="Memory not found")

    try:
        deleted_id = str(UUID(str(data)))
    except Exception:
        deleted_id = str(data)
    return {"id": deleted_id}


