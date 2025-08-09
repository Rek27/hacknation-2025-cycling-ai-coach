-- Inserts one cycling activity row and returns the new id
-- Designed for reusable, one-at-a-time ingestion from CSV

create or replace function public.insert_cycling_activity(
  p_user_id uuid,
  p_start_time timestamptz,
  p_end_time timestamptz,
  p_duration_seconds integer,
  p_distance_km numeric,
  p_avg_speed_kmh numeric,
  p_active_energy_kcal numeric,
  p_elevation_gain_m numeric,
  p_avg_hr_bpm smallint,
  p_max_hr_bpm smallint,
  p_vo2max numeric
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  insert into public.cycling_activities (
    user_id, started_at, ended_at, duration_seconds, distance_km,
    avg_speed_kmh, active_energy_kcal, elevation_gain_m, avg_hr_bpm, max_hr_bpm, vo2max
  ) values (
    p_user_id, p_start_time, p_end_time, p_duration_seconds, p_distance_km,
    p_avg_speed_kmh, p_active_energy_kcal, p_elevation_gain_m, p_avg_hr_bpm, p_max_hr_bpm, p_vo2max
  ) returning id into v_id;

  return v_id;
end;
$$;
