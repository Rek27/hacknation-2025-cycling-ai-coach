create or replace function public.delete_schedule_interval_by_id(
  p_id uuid
)
returns uuid
language plpgsql
security invoker
as $$
declare
  v_id uuid;
begin
  delete from public.schedule_intervals as si
   where si.id = p_id
   returning si.id into v_id;

  if v_id is null then
    raise exception 'No interval with id %', p_id;
  end if;

  return v_id;
end;
$$;


