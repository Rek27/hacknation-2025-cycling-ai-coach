from __future__ import annotations

"""Supabase client helpers for FastAPI.

Provides centralized factory functions for creating Supabase clients using
either the anon key (public API routes) or the service role key (server tools).
This avoids duplicating env validation and import checks across routers.
"""

import os
from typing import Any

from fastapi import HTTPException

try:
    from supabase import create_client  # type: ignore
except Exception:
    create_client = None  # type: ignore


def _ensure_lib() -> None:
    if create_client is None:
        raise HTTPException(status_code=500, detail="Supabase client not installed")


def get_client_anon() -> Any:
    """Return Supabase client using anon key for public API routes."""
    _ensure_lib()
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_anon_key = os.environ.get("SUPABASE_ANON_KEY")
    if not supabase_url or not supabase_anon_key:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured")
    return create_client(supabase_url, supabase_anon_key)


def get_client_service() -> Any:
    """Return Supabase client using service role key for server-side tools (MCP, jobs)."""
    _ensure_lib()
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_service_key = os.environ.get("SUPABASE_SERVICE_KEY")
    if not supabase_url or not supabase_service_key:
        raise HTTPException(status_code=500, detail="Supabase service credentials not configured")
    return create_client(supabase_url, supabase_service_key)


