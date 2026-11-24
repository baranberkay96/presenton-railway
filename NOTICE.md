# Notice

This package deploys **Presenton** (https://github.com/presenton/presenton), Copyright Presenton contributors, licensed under the **Apache License 2.0** (see the upstream `LICENSE` and `NOTICE` files, shipped inside the image at `/app/LICENSE` and `/app/NOTICE`). The image `ghcr.io/presenton/presenton:v0.9.12-beta` is used unmodified as the base.

What is used and how:

- `services/presenton/railway-presenton.sh` is original work for this template. It validates the login variables documented upstream (`AUTH_USERNAME`, `AUTH_PASSWORD`, `AUTH_OVERRIDE_FROM_ENV`) and then runs upstream's `/app/start.js`.
- Configuration follows upstream `docker-compose.yml`, `Dockerfile`, `nginx.conf`, `start.js`, `README.md` and `servers/fastapi/api/v1/auth/bootstrap.py` at tag `v0.9.12-beta` (checked 2026-11-24).
- Icon: Presenton's own app icon (`electron/build/appx/Square150x150Logo.png`, Apache-2.0), served through jsDelivr.
- PostgreSQL service definition from Railway's official templates.

Market templates were read for comparison only; no files or text were copied. README and docs text are original.

This is a community template and is not affiliated with or endorsed by the Presenton project.
