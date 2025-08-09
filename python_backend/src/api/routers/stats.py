from fastapi import APIRouter, HTTPException, Query, status
from typing import Optional, Dict, Any, List, Iterable
from datetime import datetime, timezone, timedelta
import os
import math

try:
    from supabase import create_client
except ImportError:
    create_client = None  # type: ignore


router = APIRouter(prefix="/stats", tags=["Stats"])


def _get_supabase_client():
    if create_client is None:
        raise HTTPException(status_code=500, detail="Supabase client not installed")
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_anon_key = os.environ.get("SUPABASE_ANON_KEY")
    if not supabase_url or not supabase_anon_key:
        raise HTTPException(status_code=500, detail="Supabase credentials not configured")
    return create_client(supabase_url, supabase_anon_key)


from src.models.cycling_activity import CyclingActivity


def _fetch_activities(
    client,
    start_date_iso: str,
    end_date_iso: str,
    user_id: Optional[str],
    limit: int = 5000,
    offset: int = 0,
) -> List[CyclingActivity]:
    res = client.rpc(
        "load_cycling_activities",
        {
            "p_start_date_iso": start_date_iso,
            "p_end_date_iso": end_date_iso,
            "p_user_id": user_id,
            "p_limit": limit,
            "p_offset": offset,
        },
    ).execute()
    data = getattr(res, "data", None)
    err = getattr(res, "error", None)
    if err:
        raise HTTPException(status_code=500, detail=str(err))
    rows: List[Dict[str, Any]] = data or []
    return [CyclingActivity(**row) for row in rows]


@router.get("/summary", status_code=status.HTTP_200_OK)
def get_summary(
    start_date_iso: str = Query(..., alias="startDateIso", description="Inclusive ISO-8601 start, e.g., 2025-01-01T00:00:00Z"),
    end_date_iso: str = Query(..., alias="endDateIso", description="Exclusive ISO-8601 end, e.g., 2025-02-01T00:00:00Z"),
    user_id: Optional[str] = Query(None, alias="userId"),
) -> Dict[str, Any]:
    client = _get_supabase_client()
    activities = _fetch_activities(client, start_date_iso, end_date_iso, user_id)

    total_distance_km = 0.0
    total_duration_seconds = 0
    total_elevation_gain_m = 0.0
    rides_count = 0

    for a in activities:
        rides_count += 1
        total_distance_km += float(a.distance_km or 0)
        total_duration_seconds += int(a.duration_seconds or 0)
        total_elevation_gain_m += float(a.elevation_gain_m or 0)

    avg_speed_kmh = None
    if total_duration_seconds > 0:
        avg_speed_kmh = total_distance_km / (total_duration_seconds / 3600.0)

    return {
        "total_distance_km": round(total_distance_km, 6),
        "total_duration_seconds": total_duration_seconds,
        "total_elevation_gain_m": round(total_elevation_gain_m, 6),
        "rides_count": rides_count,
        "avg_speed_kmh": round(avg_speed_kmh, 6) if avg_speed_kmh is not None else None,
    }


# (Removed) /daily endpoint to keep API compact


@router.get("/weekly", status_code=status.HTTP_200_OK)
def get_weekly_summary(
    start_date: str = Query(..., alias="startDate", description="Inclusive start date YYYY-MM-DD or ISO-8601"),
    end_date: str = Query(..., alias="endDate", description="Exclusive end date YYYY-MM-DD or ISO-8601"),
    user_id: Optional[str] = Query(None, alias="userId"),
) -> Dict[str, Any]:
    start_iso = start_date if "T" in start_date else f"{start_date}T00:00:00Z"
    end_iso = end_date if "T" in end_date else f"{end_date}T00:00:00Z"

    client = _get_supabase_client()
    activities = _fetch_activities(client, start_iso, end_iso, user_id)

    week_to_agg: Dict[str, Dict[str, Any]] = {}
    for a in activities:
        iso_year, iso_week, monday_iso = a.iso_week_info
        week_key = f"{iso_year}-W{iso_week:02d}"

        agg = week_to_agg.setdefault(
            week_key,
            {
                "iso_year": iso_year,
                "iso_week": iso_week,
                "week_start_monday": monday_iso,
                "total_distance_km": 0.0,
                "total_duration_seconds": 0,
                "total_elevation_gain_m": 0.0,
                "rides_count": 0,
            },
        )
        agg["total_distance_km"] += float(a.distance_km or 0)
        agg["total_duration_seconds"] += int(a.duration_seconds or 0)
        agg["total_elevation_gain_m"] += float(a.elevation_gain_m or 0)
        agg["rides_count"] += 1

    weeks = []
    for key in sorted(week_to_agg.keys(), key=lambda k: (week_to_agg[k]["week_start_monday"])):
        agg = week_to_agg[key]
        avg_speed_kmh = None
        if agg["total_duration_seconds"] > 0:
            avg_speed_kmh = agg["total_distance_km"] / (agg["total_duration_seconds"] / 3600.0)
        weeks.append(
            {
                "iso_year": agg["iso_year"],
                "iso_week": agg["iso_week"],
                "week_start_monday": agg["week_start_monday"],
                "total_distance_km": round(agg["total_distance_km"], 6),
                "total_duration_seconds": agg["total_duration_seconds"],
                "total_elevation_gain_m": round(agg["total_elevation_gain_m"], 6),
                "rides_count": agg["rides_count"],
                "avg_speed_kmh": round(avg_speed_kmh, 6) if avg_speed_kmh is not None else None,
            }
        )

    return {"weeks": weeks}


# (Removed) /top_rides endpoint to keep API compact


def _speed_kmh(activity: CyclingActivity) -> Optional[float]:
    if activity.avg_speed_kmh is not None:
        return float(activity.avg_speed_kmh)
    return activity.computed_speed_kmh


# (Removed) percentile helper, no longer used


def _daterange(start_inclusive: datetime, end_exclusive: datetime) -> Iterable[datetime]:
    current = start_inclusive
    while current < end_exclusive:
        yield current
        current = current + timedelta(days=1)


# (Removed) /streaks endpoint to keep API compact


# (Removed) /training_load endpoint; /overtraining covers key signals


# (Removed) /consistency endpoint to keep API compact


# (Removed) /speed_percentiles endpoint to keep API compact


# (Removed) /long_rides endpoint to keep API compact


# (Removed) /climbing_density endpoint to keep API compact



def _compute_day_trimp(
    activities: List[CyclingActivity], hr_max: Optional[int], hr_rest: Optional[int]
) -> Dict[str, float]:
    day_to_trimp: Dict[str, float] = {}
    for a in activities:
        duration_min = (a.duration_seconds or 0) / 60.0
        trimp = 0.0
        if hr_max is not None and hr_rest is not None and a.avg_hr_bpm is not None:
            hr_reserve = max(1, hr_max - hr_rest)
            delta_hr = max(0.0, min(1.0, (a.avg_hr_bpm - hr_rest) / hr_reserve))
            trimp = duration_min * 0.64 * math.exp(1.92 * delta_hr) * delta_hr
        else:
            spd = _speed_kmh(a) or 0.0
            intensity = min(1.5, spd / 30.0)
            trimp = duration_min * (0.5 + intensity)
        key = a.started_at.date().isoformat()
        day_to_trimp[key] = day_to_trimp.get(key, 0.0) + trimp
    return day_to_trimp


@router.get("/overtraining", status_code=status.HTTP_200_OK)
def get_overtraining_metrics(
    start_date_iso: str = Query(..., alias="startDateIso"),
    end_date_iso: str = Query(..., alias="endDateIso"),
    user_id: Optional[str] = Query(None, alias="userId"),
    hr_max: Optional[int] = Query(None, alias="hrMax", ge=100, le=230),
    hr_rest: Optional[int] = Query(None, alias="hrRest", ge=30, le=120),
    ctl_days: int = Query(42, ge=7, le=180),
    atl_days: int = Query(7, ge=3, le=28),
) -> Dict[str, Any]:
    client = _get_supabase_client()
    activities = _fetch_activities(client, start_date_iso, end_date_iso, user_id)

    start_dt = datetime.fromisoformat(start_date_iso.replace("Z", "+00:00")).astimezone(timezone.utc)
    end_dt = datetime.fromisoformat(end_date_iso.replace("Z", "+00:00")).astimezone(timezone.utc)

    day_to_trimp = _compute_day_trimp(activities, hr_max, hr_rest)

    # Build ordered daily series across the window
    daily: List[Dict[str, Any]] = []
    for d in _daterange(start_dt, end_dt):
        key = d.date().isoformat()
        daily.append({"day": key, "trimp": day_to_trimp.get(key, 0.0)})

    # CTL/ATL/TSB over the window
    alpha_ctl = 1.0 - math.exp(-1.0 / float(ctl_days))
    alpha_atl = 1.0 - math.exp(-1.0 / float(atl_days))
    ctl = 0.0
    atl = 0.0
    tsb_series: List[float] = []
    for d in daily:
        t = d["trimp"]
        ctl = ctl + alpha_ctl * (t - ctl)
        atl = atl + alpha_atl * (t - atl)
        tsb_series.append(ctl - atl)
    current_tsb = tsb_series[-1] if tsb_series else 0.0

    # ACWR = (mean 7d)/(mean 28d)
    def sum_range(days: int) -> float:
        return float(sum(x["trimp"] for x in daily[-days:])) if len(daily) >= days else float(sum(x["trimp"] for x in daily))

    acute_days = 7
    chronic_days = 28
    acute_mean = (sum_range(acute_days) / float(min(acute_days, len(daily))) ) if daily else 0.0
    chronic_mean = (sum_range(chronic_days) / float(min(chronic_days, len(daily))) ) if daily else 0.0
    acwr = (acute_mean / chronic_mean) if chronic_mean > 0 else None
    # Minimal, coach-ready summary with the two most-used training load signals
    # (TSB, ACWR). Wellness metrics like RHR/HRV/RPE are commonly tracked,
    # but are not available from activities alone.
    risk_level = "low"
    if current_tsb < -20 or (acwr is not None and acwr > 1.5):
        risk_level = "high"
    elif current_tsb < -10 or (acwr is not None and acwr > 1.3):
        risk_level = "medium"

    flags: List[str] = []
    if current_tsb < -10:
        flags.append("tsb")
    if acwr is not None and acwr > 1.3:
        flags.append("acwr")

    return {
        "tsb": round(current_tsb, 2),
        "acwr": (round(acwr, 2) if acwr is not None else None),
        "risk": risk_level,
        "flags": flags,
    }


@router.get("/workload_score", status_code=status.HTTP_200_OK)
def get_workload_score(
    start_date_iso: str = Query(..., alias="startDateIso"),
    end_date_iso: str = Query(..., alias="endDateIso"),
    user_id: Optional[str] = Query(None, alias="userId"),
) -> Dict[str, Any]:
    client = _get_supabase_client()
    activities = _fetch_activities(client, start_date_iso, end_date_iso, user_id)

    # Baseline window = last 28 days ending at end_date_iso
    end_dt = datetime.fromisoformat(end_date_iso.replace("Z", "+00:00")).astimezone(timezone.utc)
    baseline_start = (end_dt - timedelta(days=28)).isoformat().replace("+00:00", "Z")
    baseline_acts = _fetch_activities(client, baseline_start, end_date_iso, user_id)

    def features(a: CyclingActivity) -> Dict[str, float]:
        dist = float(a.distance_km or 0.0)
        spd = _speed_kmh(a) or 0.0
        elev = float(a.elevation_gain_m or 0.0)
        density = (elev / dist) if dist > 0 else 0.0
        return {"dist": dist, "spd": spd, "dens": density}

    def mean_std(values: List[float]) -> tuple[float, float]:
        if not values:
            return 0.0, 1.0
        m = sum(values) / len(values)
        var = sum((v - m) ** 2 for v in values) / max(1, len(values))
        s = math.sqrt(var) if var > 1e-9 else 1.0
        return m, s

    base_lists = {"dist": [], "spd": [], "dens": []}
    for a in baseline_acts:
        f = features(a)
        for k in base_lists:
            base_lists[k].append(f[k])

    m_dist, s_dist = mean_std(base_lists["dist"])
    m_spd, s_spd = mean_std(base_lists["spd"])
    m_dens, s_dens = mean_std(base_lists["dens"])

    def score(a: CyclingActivity) -> float:
        f = features(a)
        z = 0.4 * ((f["dist"] - m_dist) / s_dist) + 0.4 * ((f["spd"] - m_spd) / s_spd) + 0.2 * ((f["dens"] - m_dens) / s_dens)
        # Clamp then map to 1..10 with center ~5
        z = max(-4.0, min(4.0, z))
        return round(5.0 + z, 2)

    items = [
        {
            "id": str(a.id) if a.id else None,
            "started_at": a.started_at.isoformat(),
            "distance_km": float(a.distance_km or 0),
            "speed_kmh": _speed_kmh(a),
            "climb_density": (float(a.elevation_gain_m or 0) / float(a.distance_km)) if (a.distance_km and a.distance_km > 0) else 0.0,
            "score": score(a),
        }
        for a in activities
    ]

    def avg_since(days: int) -> Optional[float]:
        cutoff = end_dt - timedelta(days=days)
        vals = [it["score"] for it in items if datetime.fromisoformat(it["started_at"].replace("Z", "+00:00")).astimezone(timezone.utc) >= cutoff]
        return round(sum(vals) / len(vals), 2) if vals else None

    items.sort(key=lambda x: x["started_at"], reverse=True)
    return {"scores": items, "avg7d": avg_since(7), "avg28d": avg_since(28)}


@router.get("/vo2max_trend", status_code=status.HTTP_200_OK)
def get_vo2max_trend(
    start_date_iso: str = Query(..., alias="startDateIso"),
    end_date_iso: str = Query(..., alias="endDateIso"),
    user_id: Optional[str] = Query(None, alias="userId"),
) -> Dict[str, Any]:
    client = _get_supabase_client()
    acts = _fetch_activities(client, start_date_iso, end_date_iso, user_id)
    pts = [(a.started_at, float(a.vo2max)) for a in acts if a.vo2max is not None]
    pts.sort(key=lambda x: x[0])
    pr = round(max(v for _, v in pts), 2) if pts else None

    slope_per_30d = None
    if len(pts) >= 2:
        t0 = pts[0][0]
        xs = [(p[0] - t0).days for p in pts]
        ys = [p[1] for p in pts]
        n = len(xs)
        sx = sum(xs); sy = sum(ys)
        sxx = sum(x * x for x in xs); sxy = sum(x * y for x, y in zip(xs, ys))
        denom = (n * sxx - sx * sx)
        if abs(denom) > 1e-9:
            slope_per_day = (n * sxy - sx * sy) / denom
            slope_per_30d = round(slope_per_day * 30.0, 3)

    return {"rolling_pr": pr, "slope_per_30d": slope_per_30d}


@router.get("/climb_metrics", status_code=status.HTTP_200_OK)
def get_climb_metrics(
    start_date_iso: str = Query(..., alias="startDateIso"),
    end_date_iso: str = Query(..., alias="endDateIso"),
    user_id: Optional[str] = Query(None, alias="userId"),
    limit: int = Query(10, ge=1, le=100),
) -> Dict[str, Any]:
    client = _get_supabase_client()
    acts = _fetch_activities(client, start_date_iso, end_date_iso, user_id)

    rows = []
    for a in acts:
        dur_h = (a.duration_seconds or 0) / 3600.0
        elev = float(a.elevation_gain_m or 0)
        dist = float(a.distance_km or 0)
        vam = (elev / dur_h) if dur_h > 0 else 0.0
        density = (elev / dist) if dist > 0 else 0.0
        rows.append({
            "id": str(a.id) if a.id else None,
            "started_at": a.started_at.isoformat(),
            "vam_m_per_h": round(vam, 1),
            "climb_per_km": round(density, 3),
            "elevation_gain_m": elev,
            "distance_km": dist,
            "duration_seconds": int(a.duration_seconds or 0),
        })

    best_vam = sorted(rows, key=lambda r: r["vam_m_per_h"], reverse=True)[:limit]
    best_density = sorted(rows, key=lambda r: r["climb_per_km"], reverse=True)[:limit]
    return {"best_vam": best_vam, "best_climb_density": best_density}

