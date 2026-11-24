# Deploy and Host Presenton with Railway

Presenton is an open-source AI presentation generator, an alternative to Gamma and Beautiful.ai. Describe a topic or upload a document and it writes the outline, designs the slides and exports PowerPoint or PDF. This template runs Presenton with PostgreSQL, a persistent volume and a login that is always on.

## About Hosting Presenton

Presenton ships as one container: a Next.js editor, a FastAPI backend, an MCP server and Chromium for exports, behind nginx on port 80. Text comes from the model provider you choose (OpenAI, Anthropic, Google Gemini, OpenRouter, DeepSeek, Ollama or any OpenAI-compatible endpoint); images from GPT image models, Gemini, Pexels or Pixabay.

Users, presentations and provider settings live in PostgreSQL; exports, uploaded documents, images and fonts in a volume. Presenton has its own login: this template creates the admin account from `AUTH_USERNAME` and a generated `AUTH_PASSWORD` before the site goes online, so the first-run setup page is never open to strangers. API keys are optional at deploy time; the admin can add them in Settings.

## Common Use Cases

- Turn a prompt, notes or a PDF/Word document into a designed slide deck
- Generate decks from your own PowerPoint templates and brand fonts
- Automate presentations through the REST API or the MCP server from AI agents
- Keep slide generation private with your own model keys or a self-hosted model

## Dependencies for Presenton Hosting

- Presenton v0.9.12-beta (`ghcr.io/presenton/presenton`, pinned by digest)
- PostgreSQL 18 (Railway's `postgres-ssl` image)
- A volume for exports, images, uploads and fonts
- An API key for at least one model provider (can be added after deploy)

### Deployment Dependencies

- Presenton source and releases: https://github.com/presenton/presenton
- Presenton docs: https://docs.presenton.ai
- Model providers: https://platform.openai.com, https://console.anthropic.com, https://aistudio.google.com, https://openrouter.ai

### Implementation Details

| Service | What it does | Public |
|---|---|---|
| Presenton | Editor, API, MCP server and export engine (nginx on port 80), volume `/app_data` | yes |
| Postgres | Users, presentations, slides and settings | no |

**First login**

1. Open the Presenton public URL.
2. Sign in with `AUTH_USERNAME` (default `admin`) and the generated `AUTH_PASSWORD` from the Presenton service's Variables tab.
3. Pick a model provider and enter its key in Settings, or set `LLM` and the matching key (for example `LLM=openai` and `OPENAI_API_KEY`) on the service and redeploy.

**Password reset.** Set a new `AUTH_PASSWORD`, add `AUTH_OVERRIDE_FROM_ENV=true`, redeploy once, then remove the flag (Presenton rotates sessions and API keys when it applies it). A password shorter than 8 characters never stops the deploy: the login stays locked with a random password and the log explains how to fix it; the next valid value unlocks it automatically.

**More users.** The admin can create accounts in Presenton's user settings; there is no open sign-up.

**Images and web search.** Set `IMAGE_PROVIDER` (for example `pexels` with `PEXELS_API_KEY`, or `gpt-image-1.5` with `OPENAI_API_KEY`). Web grounding uses the provider's native search for OpenAI, Google and Anthropic, or Tavily, Exa or SearXNG with their variables.

**Presentation memory.** Mem0 memory is off by default (`MEM0_ENABLED=false`) because it needs an extra OpenAI-compatible endpoint (`MEM0_LLM_BASE_URL`, `MEM0_LLM_API_KEY`, `MEM0_LLM_MODEL`).

**Custom domain.** Add it to the Presenton service and set `PRESENTON_PUBLIC_URL` to `https://{your-domain}`.

**Scaling.** Presenton keeps files on its volume, so it runs as a single replica; give it more RAM and CPU for large decks and parallel exports.

**Versions.** The image is pinned in `services/presenton/Dockerfile` (`PRESENTON_IMAGE`, tag and digest). Presenton is pre-1.0: read the release notes and back up Postgres before upgrading.

**Resources.** Measured idle: Presenton about 0.58 GB RAM, Postgres 0.1 GB; exports (Chromium) need more. Hobby or Pro is recommended; Trial's 1 GB per service is tight during exports.

### Why Deploy Presenton on Railway?

Railway runs Presenton and its database from one template with a volume, private networking and a generated admin password. You get a private AI slide generator with your own model keys in a few minutes, and pay only for the resources it uses.
