# Presenton AI Presentation Generator (Postgres): composer spec

Listing name: **Presenton AI Presentation Generator (Postgres)** (no version label: Presenton is 0.9.x beta)
Description (70 chars): Open-source AI slide generator with login, PPTX/PDF export and an API.
Category: AI/ML. Icon: Presenton's app icon via jsDelivr (`electron/build/appx/Square150x150Logo.png` at `v0.9.12-beta`).
Repository: `baranberkay96/presenton-railway` (this folder is the repo root).

## Services

| Service | Source | Public | Volume | Healthcheck |
|---|---|---|---|---|
| Presenton | repo `/services/presenton` (`FROM ghcr.io/presenton/presenton:v0.9.12-beta@sha256:dd444e43…ed54`, released 2026-10-26; 1.75 GB compressed amd64) | domain → 80 | `/app_data` | `/api/v1/auth/status`, 900 s |
| Postgres | `ghcr.io/railwayapp-templates/postgres-ssl:18.6@sha256:4fc833b4…c863` | no | `/var/lib/postgresql/data` | — |

No required inputs. Optional: `LLM`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`, `OPENROUTER_API_KEY`, `PEXELS_API_KEY`.

## Start sequence (`railway-presenton.sh`)

1. `PORT` forced to 80 (the image's nginx port; Railway's healthcheck probes `PORT`).
2. `AUTH_USERNAME` outside 3-64 chars → `admin` (upstream raises at start).
3. `AUTH_PASSWORD` outside 8-128 chars → random password nobody knows, `AUTH_OVERRIDE_FROM_ENV=false`, marker `/app_data/.railway-login-locked`. The next start with a valid password sees the marker and sets `AUTH_OVERRIDE_FROM_ENV=true` once (unlock).
4. Waits up to 6 min for Postgres (`timeout 3 bash -c '</dev/tcp/host/port'` per probe).
5. `exec node /app/start.js` (upstream: migrations, admin bootstrap from env before nginx serves, FastAPI, Next.js, MCP, nginx).

## Improvements over market templates

Market (2026-11): leader "Presenton - AI Presentations and API" 232 active on `ghcr.io/presenton/presenton:latest`, no volume, no database, no auth variables: a fresh deploy shows the first-run setup page to whoever opens the URL first. Second: pinned v0.9.12 with a volume and auth, SQLite, a start command that exits 64 on a short password (fails the deploy). Third: v0.9.10 with Postgres 18, `CAN_CHANGE_KEYS` (now ignored), no auth.

- Pinned v0.9.12-beta by digest; Postgres for users/presentations; volume for exports.
- Admin login always on and created before the public port serves; odd passwords lock instead of crashing (STANDARD 8.29).
- Postgres wait with per-attempt timeout; healthcheck on the FastAPI auth status endpoint through nginx.
- Mem0 off by default (upstream points it at a local Ollama that does not exist on Railway).

## Resources

See "Measured" below. Prices: RAM $10/GB-month, vCPU $20/month, volume $0.15/GB-month. Minimum plan: Hobby recommended (exports start Chromium).

## Verification checklist

1. Both services SUCCESS; `/api/v1/auth/status` 200; log shows migrations and the admin bootstrap.
2. Setup endpoint `POST /api/v1/auth/setup` → 409 (already configured); login with generated credentials 200; wrong password 401.
3. With a model key: generate a short deck, export PPTX and PDF.
4. Redeploy: login unchanged, exports still in `/app_data`.
5. `AUTH_PASSWORD=abc` → SUCCESS with warning, login locked; a valid password afterwards unlocks it.

## Open questions

- Presenton is pre-1.0; env variables changed between 0.9.x releases (`CAN_CHANGE_KEYS` removed). Re-check on upgrades.
