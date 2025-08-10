create or replace function public.delete_user_memory(
  p_id uuid,
  p_user_id uuid default null
)
returns uuid
language plpgsql
security invoker
as $$
declare
  v_id uuid;
begin
  delete from public.user_memories as m
   where m.id = p_id
     and (p_user_id is null or m.user_id = p_user_id)
   returning m.id into v_id;

  if v_id is null then
    raise exception 'No memory with id % (or not owned by user)', p_id;
  end if;

  return v_id;
end;
$$;


