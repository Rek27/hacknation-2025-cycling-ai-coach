# Flutter App

This directory contains the Flutter/Dart client application. It provides a multi‑platform UI for cycling analytics, schedule planning, and an AI chat assistant.

## Why Flutter and Dart
- Flutter: a single codebase targeting iOS, Android, Web, and Desktop with a high‑performance rendering engine and a consistent widget set.
- Dart: ahead‑of‑time (AOT) compilation for production builds (fast startup/perf) and just‑in‑time (JIT) for development (hot reload, quick iteration).

We primarily focused on iOS (both developers use iPhones), but thanks to Flutter’s portability the app can run on Android and other platforms with minor adjustments (e.g., platform permissions, signing configs, and safe‑origin policies for embedded content).

## App structure (high level)
- `lib/view/` — Screens and widgets (Home/Analytics, Scheduler, AI chat widget)
- `lib/model/` — Data models used across the UI
- `lib/dto/` — DTOs for transport/serialization
- `lib/services/` — Services and integrations (Supabase init, health/export helpers)
- `lib/themes/` — Design tokens and theming (colors, fonts, theme data)
- `lib/main.dart` — Application entry point

## Data & backend
- Supabase (Auth + PostgreSQL) is used directly from the app for auth and RPC where appropriate. See `lib/services/supabase_manager.dart` for initialization via env.
- Server‑driven features call the FastAPI backend (local `http://localhost:8001` in dev; exposed via ngrok for public LLM webhooks).

## AI chat and safe origin
- The AI chat UI is embedded in the Home screen. For iOS/Safari, embedded web content must be served from a secure/safe origin (HTTPS). During development we keep the app pointing at `localhost` for the embedding link and expose the backend over HTTPS with ngrok so WebViews meet Apple’s requirements. **On release, configure a production HTTPS origin.**

## Running
- Ensure Flutter SDK is installed and `flutter doctor` is green.
- iOS focus: open the iOS simulator or attach an iPhone; then run:
  ```bash
  flutter run
  ```
- For Android, ensure an emulator/device is available. Minor configuration changes (permissions, signing) may be required.


