## Database (Supabase PostgreSQL)

Supabase hosts the PostgreSQL database. Access is via SQL functions (RPCs) from the Flutter app and Python backend. LLM tools (MCP and ElevenLabs webhooks) also access these functions via RPC from the Python server.

## Tables (high level)

- `public.cycling_activities`: per-ride records (who, when, duration, distance, optional HR/energy/VO2). Indexed by user and time.
- `public.schedule_intervals`: user schedules stored as 15‑minute snapped half‑open time ranges, with a simple type enum and optional title/description.
- `public.user_memories`: lightweight user notes with title/content and timestamps.

## SQL functions (RPC)

Cycling sessions
- `insert_cycling_activity(...) → uuid`: insert one ride row.
- `load_cycling_activities(start_iso, end_iso, user_id?, limit?, offset?) → jsonb`: list rides in a date window.

Schedule intervals
- `create_schedule_interval(user_id, type, start, end, title?, description?) → uuid`: create a snapped interval.
- `list_schedule_intervals(start, end, user_id?, types?) → setof rows`: list intervals overlapping a window.
- `update_schedule_interval_by_id(id, new_start?, new_end?, type?, title?, description?, snap?) → setof rows`: update an interval.
- `delete_schedule_interval_by_id(id) → uuid`: delete an interval.

Memories
- `create_user_memory(user_id, title?, content) → uuid`: create a memory.
- `list_user_memories(user_id, limit?, offset?) → setof rows`: list a user’s memories (newest first).
- `delete_user_memory(id, user_id?) → uuid`: delete a memory (optionally enforcing ownership).


