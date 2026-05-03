#!/usr/bin/env bash
# Weekly OSM data refresh. Builds the new OSRM index in a staging dir,
# then atomically swaps it in and restarts the container — so live traffic
# only sees a few seconds of downtime.
set -euo pipefail

REGION_URL="${REGION_URL:-http://download.geofabrik.de/asia/jordan-latest.osm.pbf}"
DATA_DIR="${DATA_DIR:-/opt/osrm/data}"
STAGE_DIR="${DATA_DIR}.new"

echo "[$(date -u +%FT%TZ)] Refreshing OSRM data from $REGION_URL"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
curl -fL -o "$STAGE_DIR/region.osm.pbf" "$REGION_URL"

docker run --rm -t -v "$STAGE_DIR:/data" osrm/osrm-backend \
  osrm-extract -p /opt/car.lua /data/region.osm.pbf
docker run --rm -t -v "$STAGE_DIR:/data" osrm/osrm-backend \
  osrm-partition /data/region.osrm
docker run --rm -t -v "$STAGE_DIR:/data" osrm/osrm-backend \
  osrm-customize /data/region.osrm

# Atomic swap.
BACKUP_DIR="${DATA_DIR}.old"
rm -rf "$BACKUP_DIR"
mv "$DATA_DIR" "$BACKUP_DIR"
mv "$STAGE_DIR" "$DATA_DIR"
docker restart osrm
rm -rf "$BACKUP_DIR"

echo "[$(date -u +%FT%TZ)] OSRM refresh complete."
