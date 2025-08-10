## App Overview

Flutter app + FastAPI backend for cycling analytics, scheduling, and AI chat. Supabase provides PostgreSQL and Auth; ElevenLabs webhooks call backend routes via an ngrok HTTPS URL.

### Why Flutter
- Multi‑platform support (iOS/Android/Desktop/Web) from a single codebase
- High‑quality UI and fast iteration with hot reload

### Screens
- Home/Analytics: charts and summaries (distance, energy, HR, speed)
- Scheduler: create/edit/delete schedule intervals (15‑minute grid)
- AI Chat: embedded assistant UI from ElevenLabs Conversation AI

### Backend and public access
- FastAPI runs on `http://localhost:8001`, containerized with Docker; Python deps managed with `uv`
- ngrok exposes the backend publicly for ElevenLabs webhook tools; set the public base URL when registering tools

## How to run

1) Prerequisites
- Flutter SDK installed and `flutter doctor` is green
- Python 3.11+, Docker, and ngrok

2) Create a `.env` at the repository root with:
- `SUPABASE_URL` — your Supabase project URL
- `SUPABASE_ANON_KEY` — anon key for the app/backend
- `ELEVENLABS_API_KEY` — for tool registration/updates
- `BACKEND_BASE_URL` — set to your public ngrok URL when registering tools

3) Start the FastAPI backend (Dockerized)
```bash
cd python_backend
docker-compose up --build
# The API will be available at http://localhost:8001
```

4) Expose the API with ngrok (for ElevenLabs webhooks)
```bash
ngrok http 8001
# Copy the HTTPS forwarding URL, e.g. https://<your-subdomain>.ngrok-free.app
```

5) Update ElevenLabs tools to point to your ngrok URL
```bash
cd python_backend
python -m src.register_elevenlabs_tools_requests
```
The tool definitions and registration script live in `python_backend/src/register_elevenlabs_tools_requests.py`.

6) Run the Flutter app
```bash
flutter run
```
