import csv
import os
from typing import Optional

import requests


def ingest_csv_activities(
    csv_path: str,
    base_url: str = "http://localhost:8001",
    user_id: Optional[str] = None,
    user_id_header: Optional[str] = None,
):
    """
    Load a CSV file with columns:
    start_time,end_time,duration_seconds,distance_km,avg_speed_kmh,active_energy_kcal,elevation_gain_m,avg_hr_bpm,max_hr_bpm,vo2max

    and POST each row to POST /activities one by one.

    - If user_id is provided, it will be sent as query param userId unless user_id_header is set,
      in which case it's sent as header x-user-id.
    - base_url defaults to local dev server.
    """
    endpoint = f"{base_url.rstrip('/')}/activities"

    headers = {"Content-Type": "application/json"}
    params = {}
    if user_id:
        if user_id_header:
            headers[user_id_header] = user_id
        else:
            params["userId"] = user_id

    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required = [
            "start_time",
            "end_time",
            "duration_seconds",
            "distance_km",
            "avg_speed_kmh",
            "active_energy_kcal",
            "elevation_gain_m",
            "avg_hr_bpm",
            "max_hr_bpm",
            "vo2max",
        ]
        missing = [c for c in required if c not in reader.fieldnames]
        if missing:
            raise ValueError(f"CSV is missing required columns: {missing}")

        for row in reader:
            payload = {
                # Map CSV snake_case to API camelCase expected by FastAPI model
                "startTime": row["start_time"],
                "endTime": row["end_time"],
                "durationSeconds": int(row["duration_seconds"]) if row["duration_seconds"] else 0,
                "distanceKm": float(row["distance_km"]) if row["distance_km"] else 0.0,
                "averageSpeedKmh": float(row["avg_speed_kmh"]) if row["avg_speed_kmh"] else None,
                "activeEnergyKcal": float(row["active_energy_kcal"]) if row["active_energy_kcal"] else None,
                "elevationGainMeters": float(row["elevation_gain_m"]) if row["elevation_gain_m"] else None,
                "averageHeartRateBpm": float(row["avg_hr_bpm"]) if row["avg_hr_bpm"] else None,
                "maxHeartRateBpm": float(row["max_hr_bpm"]) if row["max_hr_bpm"] else None,
                "vo2Max": float(row["vo2max"]) if row["vo2max"] else None,
            }

            resp = requests.post(endpoint, json=payload, headers=headers, params=params, timeout=30)
            if resp.status_code >= 400:
                raise RuntimeError(f"Failed to insert row: {resp.status_code} {resp.text}")

    return True


