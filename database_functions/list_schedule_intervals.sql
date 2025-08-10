create or replace function public.list_schedule_intervals(
  p_start   timestamptz,
  p_end     timestamptz,
  p_user_id uuid default null,
  p_types   schedule_type[] default null
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
security invoker          -- let RLS apply; avoid security definer unless necessary
stable
as $$
begin
  if p_start >= p_end then
    raise exception 'p_start (%) must be before p_end (%)', p_start, p_end
      using errcode = '22007';
  end if;

  return query
  select
    si.id,
    si.user_id,
    si.type,
    greatest(lower(si.period), p_start) as start_at,
    least(upper(si.period), p_end)      as end_at,
    si.title,
    si.description
  from public.schedule_intervals si
  where
    -- overlap test with half-open window [p_start, p_end)
    si.period && tstzrange(p_start, p_end, '[)')
    and (p_user_id is null or si.user_id = p_user_id)
    and (p_types  is null or si.type = any (p_types))
    -- ensure the clipped bounds are still a non-empty interval
    and greatest(lower(si.period), p_start) < least(upper(si.period), p_end)
  order by start_at;
end;
$$;
