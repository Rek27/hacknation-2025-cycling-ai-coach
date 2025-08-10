create or replace function public.list_user_memories(
  p_user_id uuid,
  p_limit integer default 50,
  p_offset integer default 0
)
returns table (
  id         uuid,
  user_id    uuid,
  title      text,
  content    text,
  created_at timestamptz
)
language sql
security invoker
stable
as $$
  select m.id, m.user_id, m.title, m.content, m.created_at
    from public.user_memories as m
   where m.user_id = p_user_id
   order by m.created_at desc
   limit greatest(0, p_limit)
   offset greatest(0, p_offset);
$$;


