#!/usr/bin/env bash
# Railway start script for Presenton (official image, unmodified).
# - Login is always on: AUTH_USERNAME / AUTH_PASSWORD create the admin before the
#   public port opens. Invalid values never stop the start (STANDARD 8.29): a bad
#   user name falls back to "admin"; a missing or too short password locks the
#   login with a random password nobody knows, until a valid one is set.
# - Waits for Postgres (each probe limited to 3 s) so migrations do not race it.
# Secret values are never printed.
set -u

log() { echo "[railway] $*"; }
warn() { echo "[railway] WARNING: $*" >&2; }

DATA_DIR="${APP_DATA_DIRECTORY:-/app_data}"
mkdir -p "$DATA_DIR" 2>/dev/null || true
LOCK_MARKER="$DATA_DIR/.railway-login-locked"

# Port: nginx in the image listens on 80; Railway's healthcheck probes $PORT.
if [ "${PORT:-80}" != "80" ]; then
  warn "PORT=${PORT} is not supported by the image's nginx; using 80"
fi
export PORT=80

user="$(printf '%s' "${AUTH_USERNAME:-}" | tr -d '[:space:]')"
if [ "${#user}" -lt 3 ] || [ "${#user}" -gt 64 ]; then
  [ -n "$user" ] && warn "AUTH_USERNAME must be 3-64 characters; using 'admin'"
  user="admin"
fi
export AUTH_USERNAME="$user"

pw="${AUTH_PASSWORD:-}"
if [ "${#pw}" -lt 8 ] || [ "${#pw}" -gt 128 ]; then
  warn "AUTH_PASSWORD must be 8-128 characters. The login stays locked with a random password nobody knows; set a valid AUTH_PASSWORD and redeploy to unlock it."
  export AUTH_PASSWORD="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  # Keep the env override off for this boot: the random value must not replace a working login.
  export AUTH_OVERRIDE_FROM_ENV=false RESET_AUTH=false
  touch "$LOCK_MARKER" 2>/dev/null || true
elif [ -f "$LOCK_MARKER" ]; then
  # A previous start locked the login; apply the now valid password once.
  log "AUTH_PASSWORD is valid again: unlocking the admin login with it"
  export AUTH_OVERRIDE_FROM_ENV=true
  rm -f "$LOCK_MARKER"
fi

case "${DATABASE_URL:-}" in
  postgresql://*|postgres://*)
    export DATABASE_URL="postgresql://${DATABASE_URL#*://}"
    hostport="${DATABASE_URL#*@}"; hostport="${hostport%%/*}"
    host="${hostport%:*}"; port="${hostport##*:}"
    [ "$port" = "$hostport" ] && port=5432
    for i in $(seq 1 180); do
      if timeout 3 bash -c "</dev/tcp/${host}/${port}" 2>/dev/null; then
        log "Postgres is reachable"
        break
      fi
      [ $((i % 10)) -eq 1 ] && log "waiting for Postgres at ${host}:${port} (${i}/180)"
      sleep 2
    done
    ;;
  "") log "DATABASE_URL is empty: Presenton uses SQLite in ${DATA_DIR}" ;;
esac

log "starting Presenton (login user '${AUTH_USERNAME}')"
exec node /app/start.js
