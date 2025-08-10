"""
Register backend webhook tools with ElevenLabs using raw HTTP (requests).

Usage:
  - Set XI_API_KEY (or ELEVENLABS_API_KEY) env var with your ElevenLabs key
  - Optionally set BACKEND_BASE_URL (defaults to http://localhost:8001)
  - Run: python -m src.register_elevenlabs_tools_requests
"""

from __future__ import annotations

import os
from typing import Any, Dict, List, Optional
from dotenv import load_dotenv

import requests


def _props(pairs: List[Dict[str, Any]]) -> Dict[str, Any]:
    properties: Dict[str, Any] = {}
    for p in pairs:
        properties[p["name"]] = {k: v for k, v in p.items() if k != "name"}
    return {"properties": properties}


def build_tools(base_url: str) -> List[Dict[str, Any]]:
    base = base_url.rstrip("/")
    return [
        {
            "type": "webhook",
            "name": "stats-summary",
            "description": "High-signal overview for a date window. Returns: { total_distance_km, total_duration_seconds, total_elevation_gain_m, rides_count, avg_speed_kmh }. Useful for quick volume/pacing checks to guide session planning.",
            "api_schema": {
                "url": f"{base}/stats/summary",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDateIso", "type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                    {"name": "endDateIso", "type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id) to scope results"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "stats-weekly",
            "description": "Weekly rollups (ISO weeks, Monday start). Returns: weeks[{ iso_year, iso_week, week_start_monday, total_distance_km, total_duration_seconds, total_elevation_gain_m, rides_count, avg_speed_kmh }]. Useful to assess weekly load, recovery needs, and progression.",
            "api_schema": {
                "url": f"{base}/stats/weekly",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDate", "type": "string", "description": "Inclusive start as YYYY-MM-DD or ISO-8601 (UTC assumed if date-only)"},
                    {"name": "endDate", "type": "string", "description": "Exclusive end as YYYY-MM-DD or ISO-8601 (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id)"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "stats-overtraining",
            "description": "Load risk snapshot using TSB (CTL−ATL) and ACWR (7d/28d). Returns: { tsb, acwr, risk: low|medium|high, flags }. Useful to catch spikes/accumulated fatigue; hrMax/hrRest enable HR-based TRIMP when avg_hr_bpm exists.",
            "api_schema": {
                "url": f"{base}/stats/overtraining",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDateIso", "type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                    {"name": "endDateIso", "type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id)"},
                    {"name": "hrMax", "type": "integer", "description": "Max heart rate in bpm; enables HR-based TRIMP if activity avg_hr_bpm is present"},
                    {"name": "hrRest", "type": "integer", "description": "Resting heart rate in bpm; used with hrMax for HR-based TRIMP"},
                    {"name": "ctlDays", "type": "integer", "description": "CTL EMA time constant in days (default 42)"},
                    {"name": "atlDays", "type": "integer", "description": "ATL EMA time constant in days (default 7)"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "stats-workload-score",
            "description": "Per-ride workload score (1–10) normalized vs last 28 days using volume (distance), intensity (speed), and terrain load (elevation/km). Returns: { scores[{id, started_at, distance_km, speed_kmh, climb_density, score}], avg7d, avg28d }. Useful for triaging hard days and spotting spikes/drops.",
            "api_schema": {
                "url": f"{base}/stats/workload_score",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDateIso", "type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                    {"name": "endDateIso", "type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id)"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "stats-vo2max-trend",
            "description": "VO2max progression from activity values. Returns: { rolling_pr, slope_per_30d }. Useful to track aerobic capacity direction and velocity of change.",
            "api_schema": {
                "url": f"{base}/stats/vo2max_trend",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDateIso", "type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                    {"name": "endDateIso", "type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id)"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "stats-climb-metrics",
            "description": "Climbing performance leaderboard. Returns: { best_vam[{id, started_at, vam_m_per_h, elevation_gain_m, distance_km, duration_seconds}], best_climb_density[{id, started_at, climb_per_km, elevation_gain_m, distance_km, duration_seconds}] }. Useful for hill-focused prep and profiling.",
            "api_schema": {
                "url": f"{base}/stats/climb_metrics",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDateIso", "type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                    {"name": "endDateIso", "type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id)"},
                    {"name": "limit", "type": "integer", "description": "Number of items to return per list (1–100, default 10)"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "sessions-get-range",
            "description": "Get raw cycling sessions in a date range from Supabase (no aggregation). Returns: { activities: [activity rows…] }. Use as the canonical source for client-side processing or external tools.",
            "api_schema": {
                "url": f"{base}/api/tools/load_cycling_activities",
                "method": "POST",
                "request_body_schema": {
                    "type": "object",
                    "properties": {
                        "start_date_iso": {"type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                        "end_date_iso": {"type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                        "user_id": {"type": "string", "description": "Optional athlete UUID (Supabase user id)"}
                    },
                    "required": ["start_date_iso", "end_date_iso"]
                }
            },
            "response_timeout_secs": 20
        },
        {
            "type": "webhook",
            "name": "sessions-create",
            "description": "Create a new cycling session for an athlete by inserting one activity row via Supabase RPC. Returns: { id }. Useful for ingesting sessions from external sources.",
            "api_schema": {
                "url": f"{base}/activities",
                "method": "POST",
                "query_params_schema": {
                    "properties": {
                        "userId": {"type": "string", "description": "Athlete UUID (Supabase user id) for the new session"}
                    }
                },
                "request_body_schema": {
                    "type": "object",
                    "properties": {
                        "startTime": {"type": "string", "description": "ISO-8601 UTC start time"},
                        "endTime": {"type": "string", "description": "ISO-8601 UTC end time"},
                        "durationSeconds": {"type": "integer", "description": "Duration in seconds"},
                        "distanceKm": {"type": "number", "description": "Distance in kilometers"},
                        "averageSpeedKmh": {"type": "number", "description": "Average speed in km/h", "nullable": True},
                        "activeEnergyKcal": {"type": "number", "description": "Active energy in kcal", "nullable": True},
                        "elevationGainMeters": {"type": "number", "description": "Elevation gain in meters", "nullable": True},
                        "averageHeartRateBpm": {"type": "number", "description": "Average HR in bpm", "nullable": True},
                        "maxHeartRateBpm": {"type": "number", "description": "Max HR in bpm", "nullable": True},
                        "vo2Max": {"type": "number", "description": "VO2max value", "nullable": True}
                    },
                    "required": ["startTime", "endTime", "durationSeconds", "distanceKm"]
                }
            },
            "response_timeout_secs": 20
        },
        {
            "type": "webhook",
            "name": "list-schedule-intervals",
            "description": "List schedule intervals overlapping a date window. Returns: { intervals: [interval…] } where interval matches the schedule_intervals table (id, user_id, type, start_at, end_at, title, description, created_at, updated_at).",
            "api_schema": {
                "url": f"{base}/schedule/intervals",
                "method": "GET",
                "query_params_schema": _props([
                    {"name": "startDateIso", "type": "string", "description": "Inclusive ISO-8601 UTC start (e.g. 2025-06-01T00:00:00Z)"},
                    {"name": "endDateIso", "type": "string", "description": "Exclusive ISO-8601 UTC end (boundary not included)"},
                    {"name": "userId", "type": "string", "description": "Optional athlete UUID (Supabase user id)"},
                    {"name": "types", "type": "string", "description": "Optional comma-separated list of types: Cycling,Work,Other"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "create-schedule-interval",
            "description": "Create a schedule interval (snapped to 15 minutes). Returns: { id } for the new interval.",
            "api_schema": {
                "url": f"{base}/schedule/intervals",
                "method": "POST",
                "request_body_schema": {
                    "type": "object",
                    "properties": {
                        "userId": {"type": "string", "description": "Athlete UUID (Supabase user id)"},
                        "type": {"type": "string", "description": "One of Cycling, Work, Other"},
                        "startIso": {"type": "string", "description": "ISO-8601 UTC start"},
                        "endIso": {"type": "string", "description": "ISO-8601 UTC end (exclusive)"},
                        "title": {"type": "string", "description": "Title (required)"},
                        "description": {"type": "string", "description": "Description (required)"},
                    },
                    "required": ["userId", "type", "startIso", "endIso"],
                },
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "update-schedule-interval",
            "description": "Update a schedule interval by id with optional fields. Returns: { interval } with the updated interval.",
            "api_schema": {
                "url": f"{base}/schedule/intervals",
                "method": "PATCH",
                "request_body_schema": {
                    "type": "object",
                    "properties": {
                        "id": {"type": "string", "description": "Interval UUID"},
                        "newStartIso": {"type": "string", "description": "New ISO-8601 UTC start", "nullable": True},
                        "newEndIso": {"type": "string", "description": "New ISO-8601 UTC end (exclusive)", "nullable": True},
                        "type": {"type": "string", "description": "One of Cycling, Work, Other", "nullable": True},
                        "title": {"type": "string", "description": "New title", "nullable": True},
                        "description": {"type": "string", "description": "New description", "nullable": True},
                        "snap": {"type": "boolean", "description": "Snap to 15-minute grid (default true)", "nullable": True},
                    },
                    "required": ["id"],
                },
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "delete-schedule-interval",
            "description": "Delete a schedule interval by id. Returns: { id } of the deleted interval.",
            "api_schema": {
                "url": f"{base}/schedule/intervals",
                "method": "DELETE",
                "query_params_schema": _props([
                    {"name": "id", "type": "string", "description": "Interval UUID to delete"},
                ]),
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "memory-create",
            "description": "Create a user memory entry. Returns: { id } of the new memory.",
            "api_schema": {
                "url": f"{base}/memories",
                "method": "POST",
                "request_body_schema": {
                    "type": "object",
                    "properties": {
                        "userId": {"type": "string", "description": "User UUID (Supabase user id)"},
                        "content": {"type": "string", "description": "Memory content"},
                        "title": {"type": "string", "description": "Optional title", "nullable": True},
                    },
                    "required": ["userId", "content"]
                }
            },
            "response_timeout_secs": 20,
        },
        {
            "type": "webhook",
            "name": "memory-delete",
            "description": "Delete a user memory entry by id. Returns: { id } of the deleted memory.",
            "api_schema": {
                "url": f"{base}/memories",
                "method": "DELETE",
                "query_params_schema": _props([
                    {"name": "id", "type": "string", "description": "Memory UUID to delete"},
                    {"name": "userId", "type": "string", "description": "Optional user UUID to enforce ownership"},
                ]),
            },
            "response_timeout_secs": 20,
        },
    ]


def main() -> None:
    load_dotenv()
    api_key = os.environ.get("XI_API_KEY") or os.environ.get("ELEVENLABS_API_KEY")
    if not api_key:
        raise RuntimeError("Set XI_API_KEY or ELEVENLABS_API_KEY in environment")

    base_url = os.environ.get("BACKEND_BASE_URL", "https://9eb277142d3e.ngrok-free.app")
    url = "https://api.elevenlabs.io/v1/convai/tools"
    headers = {"xi-api-key": api_key, "Content-Type": "application/json"}
    update_only = os.environ.get("XI_UPDATE_ONLY", "false").lower() in ("1", "true", "yes")

    # Discover existing tools by name → id so we can PATCH even without env IDs
    existing_by_name: Dict[str, str] = {}
    try:
        list_resp = requests.get(url, headers=headers, timeout=30)
        if list_resp.ok:
            body = list_resp.json()
            seq = []
            if isinstance(body, list):
                seq = body
            elif isinstance(body, dict):
                for key in ("items", "data", "tools", "result"):
                    if isinstance(body.get(key), list):
                        seq = body[key]
                        break
            for t in seq:
                cfg = t.get("tool_config") or {}
                name = t.get("name") or cfg.get("name")
                tid = t.get("id") or t.get("tool_id")
                if name and tid:
                    existing_by_name[str(name)] = str(tid)
    except Exception as e:
        print(f"WARN: failed to list tools: {e}")

    def tool_env_id(tool_name: str) -> Optional[str]:
        # Check specific env like XI_TOOL_ID_STATS_SUMMARY or generic XI_TOOL_ID
        specific_key = f"XI_TOOL_ID_{tool_name.upper().replace('-', '_')}"
        return os.environ.get(specific_key) or os.environ.get("XI_TOOL_ID")

    for tool in build_tools(base_url):
        name = tool["name"]
        payload = {"tool_config": tool}
        tool_id = tool_env_id(name) or existing_by_name.get(name)

        # Try PATCH first if tool_id provided
        if tool_id:
            patch_url = f"{url}/{tool_id}"
            resp = requests.patch(patch_url, headers=headers, json=payload, timeout=30)
            try:
                data = resp.json()
            except Exception:
                data = {"text": resp.text}
            print(f"PATCH {name}: {resp.status_code} -> {data}")
            if 200 <= resp.status_code < 300:
                continue  # updated successfully

        if update_only:
            print(f"SKIP create for {name} (XI_UPDATE_ONLY=true)")
        else:
            # Fallback to POST create
            resp = requests.post(url, headers=headers, json=payload, timeout=30)
            try:
                data = resp.json()
            except Exception:
                data = {"text": resp.text}
            print(f"POST {name}: {resp.status_code} -> {data}")


if __name__ == "__main__":
    main()


