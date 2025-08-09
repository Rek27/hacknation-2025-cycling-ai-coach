import os
from typing import Any, Dict, Optional

from fastapi import HTTPException
from mcp.server.fastmcp import FastMCP

try:
    from supabase import create_client
except Exception:
    create_client = None  # type: ignore


def _get_supabase_client():
    if create_client is None:
        raise HTTPException(status_code=500, detail="Supabase client not installed")
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_service_key = os.environ.get("SUPABASE_SERVICE_KEY")
    if not supabase_url or not supabase_service_key:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured")
    return create_client(supabase_url, supabase_service_key)


def register_tools(mcp: FastMCP) -> None:
    @mcp.tool()
    async def agg_cycling_summary(start_date_iso: str, end_date_iso: str, user_id: Optional[str] = None) -> Dict[str, Any]:
        client = _get_supabase_client()
        res = client.rpc(
            "agg_cycling_summary",
            {"p_start_date_iso": start_date_iso, "p_end_date_iso": end_date_iso, "p_user_id": user_id},
        ).execute()
        data = getattr(res, "data", None)
        err = getattr(res, "error", None)
        if err:
            raise HTTPException(status_code=500, detail=str(err))
        return data or {}

    @mcp.tool()
    async def ts_cycling_daily(start_date: str, end_date: str, user_id: Optional[str] = None) -> Dict[str, Any]:
        client = _get_supabase_client()
        res = client.rpc(
            "ts_cycling_daily",
            {"p_start_date": start_date, "p_end_date": end_date, "p_user_id": user_id},
        ).execute()
        data = getattr(res, "data", None)
        err = getattr(res, "error", None)
        if err:
            raise HTTPException(status_code=500, detail=str(err))
        return {"days": data or []}

    @mcp.tool()
    async def wk_cycling_summary(start_date: str, end_date: str, user_id: Optional[str] = None) -> Dict[str, Any]:
        client = _get_supabase_client()
        res = client.rpc(
            "wk_cycling_summary",
            {"p_start_date": start_date, "p_end_date": end_date, "p_user_id": user_id},
        ).execute()
        data = getattr(res, "data", None)
        err = getattr(res, "error", None)
        if err:
            raise HTTPException(status_code=500, detail=str(err))
        return {"weeks": data or []}

    @mcp.tool()
    async def top_rides(
        start_date_iso: str,
        end_date_iso: str,
        user_id: Optional[str] = None,
        order_by: Optional[str] = "distance",
        limit: Optional[int] = 10,
    ) -> Dict[str, Any]:
        client = _get_supabase_client()
        res = client.rpc(
            "top_rides",
            {
                "p_start_date_iso": start_date_iso,
                "p_end_date_iso": end_date_iso,
                "p_user_id": user_id,
                "p_order_by": order_by,
                "p_limit": limit,
            },
        ).execute()
        data = getattr(res, "data", None)
        err = getattr(res, "error", None)
        if err:
            raise HTTPException(status_code=500, detail=str(err))
        return {"rides": data or []}

