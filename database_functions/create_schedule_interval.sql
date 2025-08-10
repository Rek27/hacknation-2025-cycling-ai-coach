-- Inserts a single interval. Enforces [start,end) & optional snapping to 15-min grid.
create or replace function public.create_schedule_interval(
  p_user_id     uuid,
  p_type        schedule_type,
  p_start       timestamptz,
  p_end         timestamptz,
  p_title       text default null,
  p_description text default null,
  p_snap        boolean default true
)
returns table (
  id          uuid,
  user_id     uuid,
  type        schedule_type,
  start_at    timestamptz,
  end_at      timestamptz,
  title       text,
  description text
)
language plpgsql
security invoker
strict
as $$
declare
  v_start timestamptz;
  v_end   timestamptz;
begin
  -- snap to 15-min grid if requested
  if p_snap then
    -- floor to 15
    v_start := date_trunc('hour', p_start)
               + make_interval(mins => (extract(minute from p_start)::int / 15) * 15);
    -- ceil to 15
    v_end   := date_trunc('hour', p_end)
               + make_interval(mins => (extract(minute from p_end)::int / 15) * 15);
    if v_end < p_end then
      v_end := v_end + interval '15 minutes';
    end if;
  else
    v_start := p_start;
    v_end   := p_end;
  end if;

  if v_start >= v_end then
    raise exception 'start must be before end: % >= %', v_start, v_end
      using errcode = '22007';
  end if;

  return query
  insert into public.schedule_intervals (
    user_id, type, period, title, description
  )
  values (
    p_user_id, p_type, tstzrange(v_start, v_end, '[)'), p_title, p_description
  )
  returning id, user_id, type, start_at, end_at, title, description;
end;
$$;
