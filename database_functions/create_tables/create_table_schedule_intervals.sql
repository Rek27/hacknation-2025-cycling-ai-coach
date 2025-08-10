-- UUIDs
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid()
-- No btree_gist / exclusion constraints needed anymore.

CREATE TYPE schedule_type AS ENUM ('Cycling','Work','Other');

CREATE TABLE schedule_intervals (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL,
  type        schedule_type NOT NULL,
  period      tstzrange NOT NULL,                          -- [start, end)
  title       text,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),

  -- Convenience (computed) columns
  start_at    timestamptz GENERATED ALWAYS AS (lower(period)) STORED,
  end_at      timestamptz   GENERATED ALWAYS AS (upper(period)) STORED,

  -- Canonical, non-empty, 15-min alignment in UTC; half-open interval
  CHECK (NOT isempty(period)),
  CHECK (lower_inc(period) AND NOT upper_inc(period)),
  CHECK (EXTRACT(second FROM (lower(period) AT TIME ZONE 'UTC')) = 0),
  CHECK (EXTRACT(second FROM (upper(period) AT TIME ZONE 'UTC')) = 0),
  CHECK (MOD(EXTRACT(minute FROM (lower(period) AT TIME ZONE 'UTC'))::int,15)=0),
  CHECK (MOD(EXTRACT(minute FROM (upper(period) AT TIME ZONE 'UTC'))::int,15)=0)
);