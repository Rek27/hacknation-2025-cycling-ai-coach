create or replace function public.create_user_memory(
  p_user_id uuid,
  p_title   text default null,
  p_content text
)
returns uuid
language plpgsql
security invoker
as $$
declare
  v_id uuid;
begin
  if p_content is null or length(trim(p_content)) = 0 then
    raise exception 'content cannot be empty' using errcode='22023';
  end if;

  insert into public.user_memories(user_id, title, content)
  values (p_user_id, nullif(p_title, ''), p_content)
  returning id into v_id;

  return v_id;
end;
$$;


