create or replace function public.update_schedule_interval_by_id(
  p_id          uuid,
  p_new_start   timestamptz default null,
  p_new_end     timestamptz default null,
  p_type        schedule_type default null,
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
as $$
#variable_conflict use_column
declare
  v_start timestamptz;
  v_end   timestamptz;
begin
  select lower(si.period), upper(si.period)
    into v_start, v_end
  from public.schedule_intervals as si
  where si.id = p_id;

  if v_start is null then
    raise exception 'No interval with id %', p_id;
  end if;

  if p_new_start is not null then
    v_start := case
                 when p_snap then date_bin('15 minutes', p_new_start, 'epoch'::timestamptz)
                 else p_new_start
               end;
  end if;

  if p_new_end is not null then
    v_end := case
               when p_snap then date_bin('15 minutes', p_new_end + interval '14 minutes 59 seconds', 'epoch'::timestamptz)
               else p_new_end
             end;
  end if;

  if v_start >= v_end then
    raise exception 'start must be before end: % >= %', v_start, v_end;
  end if;

  return query
  update public.schedule_intervals as si
     set type        = coalesce(p_type, si.type),
         period      = tstzrange(v_start, v_end, '[)'),
         title       = coalesce(p_title, si.title),
         description = coalesce(p_description, si.description),
         updated_at  = now()
   where si.id = p_id
   returning si.id, si.user_id, si.type,
             lower(si.period) as start_at, upper(si.period) as end_at,
             si.title, si.description;
end;
$$;
