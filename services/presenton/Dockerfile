# Presenton v0.9.12-beta (Apache-2.0, official image unmodified, pinned by index digest)
# plus a Railway start script: login always on, safe handling of odd form values,
# Postgres wait. Image: ~1.75 GB compressed (amd64).
ARG PRESENTON_IMAGE=ghcr.io/presenton/presenton:v0.9.12-beta@sha256:dd444e4384df0caeb7cb96a26bfa7543a12d2be19c83d661446b2087d09aed54
FROM ${PRESENTON_IMAGE}

COPY --chmod=0755 railway-presenton.sh /usr/local/bin/railway-presenton.sh

ENV PORT=80
CMD ["/usr/local/bin/railway-presenton.sh"]
