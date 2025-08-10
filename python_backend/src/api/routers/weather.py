from __future__ import annotations

from typing import Any, Dict, Optional, List
from datetime import datetime, timezone

import requests
from fastapi import APIRouter, HTTPException, Query, status


router = APIRouter(prefix="/weather", tags=["Weather"])


def _parse_iso_utc(ts: str) -> datetime:
    try:
        if ts.endswith("Z"):
            ts = ts.replace("Z", "+00:00")
        dt = datetime.fromisoformat(ts)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)
    except Exception:
        raise HTTPException(status_code=400, detail="datetimeIso must be ISO-8601 (e.g. 2025-08-10T09:00:00Z)")


@router.get("/by_time", status_code=status.HTTP_200_OK)
def weather_by_time(
    lat: float = Query(..., description="Latitude in decimal degrees"),
    lon: float = Query(..., description="Longitude in decimal degrees"),
    datetime_iso: str = Query(..., alias="datetimeIso", description="ISO-8601 UTC time (e.g., 2025-08-10T09:00:00Z)"),
    variables_csv: Optional[str] = Query(
        None,
        alias="variables",
        description="Comma-separated Open-Meteo hourly variables (e.g., temperature_2m,windspeed_10m,winddirection_10m,precipitation,cloudcover)",
    ),
) -> Dict[str, Any]:
    """Fetch hourly weather at a given time using the free Open-Meteo API.

    Returns the nearest-hour values for requested variables.
    """

    dt = _parse_iso_utc(datetime_iso)
    start = dt.replace(minute=0, second=0, microsecond=0)
    end = start

    default_vars = [
        "temperature_2m",
        "windspeed_10m",
        "winddirection_10m",
        "precipitation",
        "cloudcover",
    ]
    vars_list: List[str] = default_vars
    if variables_csv:
        seq = [v.strip() for v in variables_csv.split(",") if v.strip()]
        if seq:
            vars_list = seq

    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": lat,
        "longitude": lon,
        "hourly": ",".join(vars_list),
        "timezone": "UTC",
        # limit to the single target hour window
        "start_hour": start.isoformat().replace("+00:00", "Z"),
        "end_hour": (end.isoformat().replace("+00:00", "Z")),
    }

    # Open-Meteo expects start/end as start/end hour; some deployments use start_date/end_date.
    # Fallback to the generic start/end params if the above are not supported.
    alt_params = {
        "latitude": lat,
        "longitude": lon,
        "hourly": ",".join(vars_list),
        "timezone": "UTC",
        "start": start.isoformat().replace("+00:00", "Z"),
        "end": end.isoformat().replace("+00:00", "Z"),
    }

    try:
        resp = requests.get(url, params=params, timeout=15)
        if resp.status_code >= 400 or not resp.ok:
            # Try fallback param names
            resp = requests.get(url, params=alt_params, timeout=15)
        data = resp.json()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Failed to fetch weather: {e}")

    hourly = data.get("hourly") or {}
    times = hourly.get("time") or []
    if not times:
        return {"time": start.isoformat().replace("+00:00", "Z"), "values": {}}

    # Find exact hour index
    target_iso = start.isoformat().replace("+00:00", "Z")
    try:
        idx = times.index(target_iso)
    except ValueError:
        # If not found, return first element or empty
        idx = 0

    values: Dict[str, Any] = {}
    for v in vars_list:
        seq = hourly.get(v)
        if isinstance(seq, list) and len(seq) > idx:
            values[v] = seq[idx]

    return {"time": target_iso, "latitude": lat, "longitude": lon, "values": values}


@router.get("/daylight", status_code=status.HTTP_200_OK)
def daylight_for_date(
    lat: float = Query(..., description="Latitude in decimal degrees"),
    lon: float = Query(..., description="Longitude in decimal degrees"),
    date_iso: Optional[str] = Query(None, alias="dateIso", description="Date YYYY-MM-DD (UTC). Defaults to today (UTC) if omitted."),
) -> Dict[str, Any]:
    """Get sunrise/sunset times for a given date using sunrise-sunset.org (free)."""

    if date_iso is None:
        date_iso = datetime.now(timezone.utc).date().isoformat()

    url = "https://api.sunrise-sunset.org/json"
    params = {
        "lat": lat,
        "lng": lon,
        "date": date_iso,
        "formatted": 0,  # return ISO-8601
    }
    try:
        resp = requests.get(url, params=params, timeout=15)
        data = resp.json()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Failed to fetch daylight: {e}")

    status_str = data.get("status")
    if status_str != "OK":
        raise HTTPException(status_code=502, detail=f"Daylight API error: {status_str}")

    res = data.get("results", {})
    subset = {
        "sunrise": res.get("sunrise"),
        "sunset": res.get("sunset"),
        "solar_noon": res.get("solar_noon"),
        "day_length": res.get("day_length"),
        "civil_twilight_begin": res.get("civil_twilight_begin"),
        "civil_twilight_end": res.get("civil_twilight_end"),
    }
    return {"date": date_iso, "latitude": lat, "longitude": lon, **subset}


@router.get("/air_quality", status_code=status.HTTP_200_OK)
def air_quality_by_location(
    lat: float = Query(..., description="Latitude in decimal degrees"),
    lon: float = Query(..., description="Longitude in decimal degrees"),
    radius_m: int = Query(10000, ge=1000, le=50000, description="Search radius in meters (default 10km)"),
    limit: int = Query(10, ge=1, le=50, description="Max stations to include"),
) -> Dict[str, Any]:
    """Fetch latest air quality near coordinates using OpenAQ (free)."""

    url = "https://api.openaq.org/v2/latest"
    params = {
        "coordinates": f"{lat},{lon}",
        "radius": radius_m,
        "limit": limit,
        "order_by": "distance",
        "sort": "asc",
    }
    try:
        resp = requests.get(url, params=params, timeout=20)
        data = resp.json()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Failed to fetch air quality: {e}")

    results = data.get("results", [])
    pollutants: Dict[str, Any] = {}
    for site in results:
        for m in site.get("measurements", []):
            param = str(m.get("parameter")).lower()
            value = m.get("value")
            unit = m.get("unit")
            # Keep the best (nearest) value per pollutant; since ordered by distance asc, first wins
            if param not in pollutants and value is not None:
                pollutants[param] = {"value": value, "unit": unit}

    return {
        "latitude": lat,
        "longitude": lon,
        "radius_m": radius_m,
        "pollutants": pollutants,
        "source": "OpenAQ",
    }


