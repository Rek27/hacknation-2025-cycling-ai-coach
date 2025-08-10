# Python Backend

FastAPI backend for cycling stats, schedules, and user memories. Containerized with Docker; dependencies are managed with `uv`.

## Containerization and public access
- Dockerfile and docker-compose are in `python_backend/`. Run locally with Docker; the API listens on port 8001 in the container.
- Ngrok is used to expose the local backend publicly for LLM webhook tools (ElevenLabs). Set `BACKEND_BASE_URL` to the ngrok HTTPS URL when registering tools so ElevenLabs can reach your webhooks.

## Setup
1) Install `uv` and create a venv
```bash
pip install uv
uv venv
# Windows
.\.venv\Scripts\activate
# macOS/Linux
# source .venv/bin/activate
```
2) Install dependencies (from `pyproject.toml`/`uv.lock`)
```bash
uv sync
```
3) Run with Docker
```bash
docker-compose build
docker-compose up
```

## Environment
Create a `.env` at repo root. Common variables:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- `BACKEND_BASE_URL` (e.g., your ngrok URL) for tool registration
- `ELEVENLABS_API_KEY` for tool registration or updating

## Routes

Base URL (local): `http://localhost:8001`

- Stats (`/stats`)
  - `GET /stats/summary` — totals over a date window (distance, duration, elevation, rides, avg speed).
  - `GET /stats/weekly` — weekly rollups (Monday-start ISO weeks).
  - `GET /stats/overtraining` — TSB/ACWR snapshot and risk flags.
  - `GET /stats/workload_score` — per-ride workload scores vs 28d baseline.
  - `GET /stats/vo2max_trend` — VO2max progression (rolling PR, slope per 30d).
  - `GET /stats/climb_metrics` — best VAM and climb density rides.

- Schedule (`/schedule`)
  - `GET /schedule/intervals` — list intervals overlapping [start,end).
  - `POST /schedule/intervals` — create interval (accepts JSON or query params).
  - `PATCH /schedule/intervals` — update interval by id (partial fields).
  - `DELETE /schedule/intervals` — delete interval by id.

- Memories (`/memories`)
  - `POST /memories` — create memory (accepts JSON; userId, content, optional title).
  - `GET /memories` — list user memories with limit/offset.
  - `DELETE /memories` — delete memory by id (query) or `DELETE /memories/{id}`.
  
- Health
  - `GET /temp/health/` — basic health/info check.

Tool registration/update script
- Tool definitions and the script to create/update them in ElevenLabs live in `src/register_elevenlabs_tools_requests.py`.
- Usage (from `python_backend/`):
  ```bash
  # Set your ElevenLabs API key and public backend URL (ngrok)
  # PowerShell
  $env:ELEVENLABS_API_KEY="<your_key>"; $env:BACKEND_BASE_URL="https://<your-ngrok>.ngrok-free.app"; python -m src.register_elevenlabs_tools_requests
  # bash
  ELEVENLABS_API_KEY=<your_key> BACKEND_BASE_URL=https://<your-ngrok>.ngrok-free.app python -m src.register_elevenlabs_tools_requests
  ```

## LLM tools
- Tools are registered to ElevenLabs using the ngrok URL and call backend routes; the backend calls Supabase SQL functions via RPC.
- MCP tools are exposed from the Python server and also execute Supabase RPCs directly.