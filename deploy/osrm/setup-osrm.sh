#!/usr/bin/env bash
# One-time setup for self-hosted OSRM routing on Ubuntu 22.04+ (Hetzner CPX21).
# Usage:
#   sudo bash setup-osrm.sh routing.yourdomain.com you@email
# Pass your domain (with A-record pointing here) and a contact email for Let's Encrypt.

set -euo pipefail

DOMAIN="${1:-}"
EMAIL="${2:-}"
REGION_URL="${3:-http://download.geofabrik.de/asia/jordan-latest.osm.pbf}"
DATA_DIR="/opt/osrm/data"
PROFILE="/opt/car.lua"

if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
  echo "Usage: $0 <domain> <email> [osm-pbf-url]"
  exit 1
fi

echo ">>> Installing Docker, nginx, certbot..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg nginx certbot python3-certbot-nginx
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">>> Downloading map extract..."
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"
curl -fL -o region.osm.pbf "$REGION_URL"

echo ">>> Preprocessing OSRM data (this takes 5-15 minutes)..."
docker run --rm -t -v "$DATA_DIR:/data" osrm/osrm-backend \
  osrm-extract -p /opt/car.lua /data/region.osm.pbf
docker run --rm -t -v "$DATA_DIR:/data" osrm/osrm-backend \
  osrm-partition /data/region.osrm
docker run --rm -t -v "$DATA_DIR:/data" osrm/osrm-backend \
  osrm-customize /data/region.osrm

echo ">>> Starting OSRM container..."
docker rm -f osrm 2>/dev/null || true
docker run -d --name osrm --restart=always \
  -p 127.0.0.1:5000:5000 \
  -v "$DATA_DIR:/data" \
  osrm/osrm-backend osrm-routed --algorithm mld --max-table-size 10000 /data/region.osrm

echo ">>> Configuring nginx reverse proxy at $DOMAIN..."
cat > /etc/nginx/sites-available/osrm <<NGINX
server {
    listen 80;
    server_name $DOMAIN;

    # Lock down to driving routes only — other OSRM endpoints aren't needed
    # by the mobile app and shouldn't be exposed publicly.
    location ~ ^/route/v1/driving/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 30s;
        # Cap body size — route requests are tiny.
        client_max_body_size 4k;
    }

    location / {
        return 404;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/osrm /etc/nginx/sites-enabled/osrm
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

echo ">>> Issuing Let's Encrypt certificate..."
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect

echo ">>> Installing weekly refresh cron..."
install -m 0755 "$(dirname "$0")/refresh-osrm.sh" /opt/osrm/refresh-osrm.sh
cat > /etc/cron.d/osrm-refresh <<CRON
# Refresh OSM map data weekly (Sunday 03:00 UTC).
0 3 * * 0 root REGION_URL='$REGION_URL' DATA_DIR='$DATA_DIR' /opt/osrm/refresh-osrm.sh >> /var/log/osrm-refresh.log 2>&1
CRON

echo ""
echo ">>> Done. Test with:"
echo "    curl 'https://$DOMAIN/route/v1/driving/35.895,31.886;35.890,31.882?overview=full&geometries=geojson'"
echo ""
echo "Then in route_provider.dart change the URL to:"
echo "    https://$DOMAIN/route/v1/driving/..."
