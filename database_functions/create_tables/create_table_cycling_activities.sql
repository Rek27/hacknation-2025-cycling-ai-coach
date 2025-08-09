-- Table for cycling activities aligned with CSV columns
-- CSV header: start_time,end_time,duration_seconds,distance_km,avg_speed_kmh,active_energy_kcal,elevation_gain_m,avg_hr_bpm,max_hr_bpm,vo2max

create extension if not exists pgcrypto;

create table if not exists public.cycling_activities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,

  started_at timestamptz not null,
  ended_at   timestamptz not null,
  duration_seconds integer not null check (duration_seconds >= 0),
  distance_km numeric(8,3) not null check (distance_km >= 0),
  avg_speed_kmh numeric(6,2) check (avg_speed_kmh is null or avg_speed_kmh >= 0),
  active_energy_kcal numeric(8,1) check (active_energy_kcal is null or active_energy_kcal >= 0),
  elevation_gain_m numeric(8,1) check (elevation_gain_m is null or elevation_gain_m >= 0),
  avg_hr_bpm smallint check (avg_hr_bpm is null or avg_hr_bpm >= 0),
  max_hr_bpm smallint check (max_hr_bpm is null or max_hr_bpm >= 0),
  vo2max numeric(5,1) check (vo2max is null or vo2max >= 0),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint ck_started_before_ended check (ended_at > started_at)
);

create index if not exists idx_cycling_activities_started_at
  on public.cycling_activities (started_at desc);

create index if not exists idx_cycling_activities_user_started
  on public.cycling_activities (user_id, started_at desc);

alter table public.cycling_activities enable row level security;

-- Policies (adjust to your needs). Backend with service key can bypass RLS or use security definer functions.
create policy if not exists "cycling_activities_select_own"
  on public.cycling_activities for select
  using (auth.uid() = user_id);

create policy if not exists "cycling_activities_insert_own"
  on public.cycling_activities for insert
  with check (auth.uid() = user_id);

create policy if not exists "cycling_activities_update_own"
  on public.cycling_activities for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "cycling_activities_delete_own"
  on public.cycling_activities for delete
  using (auth.uid() = user_id);


