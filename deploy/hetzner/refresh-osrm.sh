#!/usr/bin/env bash
# Weekly OSRM map refresh.
# Drops the cached pbf + preprocessed graph so `osrm-init` re-downloads
# the latest Jordan snapshot from Geofabrik and re-runs the extract/
# partition/customize pipeline, then restarts the osrm runtime against
# the new data. Total downtime ~30s on a CPX31.
#
# Install (once):
#   chmod +x /opt/tilmezbus/deploy/hetzner/refresh-osrm.sh
#   ( crontab -l 2>/dev/null; echo '0 3 * * 0 /opt/tilmezbus/deploy/hetzner/refresh-osrm.sh >> /var/log/osrm-refresh.log 2>&1' ) | crontab -
#
# Runs every Sunday at 03:00 server time.

set -euo pipefail

COMPOSE_DIR=/opt/tilmezbus/deploy/hetzner
cd "$COMPOSE_DIR"

echo "── $(date -u +%FT%TZ) refresh start ──"

# 1. Stop osrm so we can safely mutate /data
docker compose -f docker-compose.yml -f docker-compose.override.yml stop osrm

# 2. Purge cached map + preprocessed files inside the osrmdata volume.
#    Using a throwaway container so we don't depend on osrm being up.
docker run --rm -v hetzner_osrmdata:/data alpine sh -c '
  cd /data && rm -f jordan-latest.osm.pbf jordan-latest.osrm*
'

# 3. Run init again (downloads + preprocesses), then start osrm
docker compose -f docker-compose.yml -f docker-compose.override.yml \
  up -d --force-recreate osrm-init osrm

# 4. Wait for the new osrm-routed to accept traffic
for _ in $(seq 1 30); do
  if curl -fsS -o /dev/null "http://127.0.0.1/route/v1/driving/35.9,31.9;35.8,31.8"; then
    echo "── $(date -u +%FT%TZ) refresh OK ──"
    exit 0
  fi
  sleep 2
done

echo "── $(date -u +%FT%TZ) refresh FAILED (osrm didn't come up in 60s) ──"
exit 1
