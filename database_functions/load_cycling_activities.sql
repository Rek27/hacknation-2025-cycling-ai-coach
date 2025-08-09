create or replace function public.load_cycling_activities(
  p_start_date_iso text,
  p_end_date_iso text,
  p_user_id uuid default null,
  p_limit int default 1000,
  p_offset int default 0
)
returns jsonb
language sql
security definer
as $$
  with bounds as (
    select (p_start_date_iso)::timestamptz as start_ts,
           (p_end_date_iso)::timestamptz   as end_ts
  ), rows as (
    select
      id, user_id, started_at, ended_at, duration_seconds, distance_km,
      avg_speed_kmh, active_energy_kcal, elevation_gain_m, avg_hr_bpm,
      max_hr_bpm, vo2max, created_at, updated_at
    from public.cycling_activities, bounds
    where started_at >= bounds.start_ts
      and started_at <  bounds.end_ts
      and (p_user_id is null or user_id = p_user_id)
    order by started_at desc
    limit p_limit offset p_offset
  )
  select coalesce(jsonb_agg(to_jsonb(rows)), '[]'::jsonb)
  from rows;
$$;


