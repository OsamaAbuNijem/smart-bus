# Self-hosted OSRM routing for SmartBus

One-time setup of an OSRM routing server that the Flutter app calls to draw
street-following polylines between the bus and each parent's home.

## What you need
- A VPS running Ubuntu 22.04 or newer (Hetzner CPX21, ~€5/month, is plenty
  for 10K+ students in Jordan).
- A domain or subdomain with an A-record pointing at the VPS IP (e.g.
  `routing.smartbus.app`).
- An email address for Let's Encrypt registration.

## Install

```bash
scp deploy/osrm/*.sh root@<vps-ip>:/root/
ssh root@<vps-ip>
sudo bash /root/setup-osrm.sh routing.smartbus.app you@example.com
```

The script installs Docker, downloads the Jordan OSM extract, preprocesses it
for OSRM, runs the routing container behind nginx with HTTPS, and installs a
weekly cron that refreshes the map data.

First run takes ~10–15 minutes (mostly OSM preprocessing).

## Test
```bash
curl 'https://routing.smartbus.app/route/v1/driving/35.895,31.886;35.890,31.882?overview=full&geometries=geojson'
```

## Wire up the mobile app
In `src/SmartBus.Mobile/lib/features/parent/presentation/providers/route_provider.dart`,
change the OSRM URL from `router.project-osrm.org` to your domain:

```dart
final url = 'https://routing.smartbus.app/route/v1/driving/'
    '$fromLng,$fromLat;$toLng,$toLat'
    '?overview=full&geometries=geojson';
```

## Use a different country/region
Browse https://download.geofabrik.de/ for the right `.osm.pbf` file, then pass
its URL as the third argument to `setup-osrm.sh`:

```bash
sudo bash setup-osrm.sh routing.smartbus.app you@example.com \
  http://download.geofabrik.de/asia/saudi-arabia-latest.osm.pbf
```

The same URL is used by the weekly refresh cron.

## Operational notes
- nginx exposes only `/route/v1/driving/...`. Other OSRM endpoints (table,
  match, trip, nearest) are blocked at the proxy.
- The refresh cron does an atomic swap, so live traffic sees ~5s of restart
  downtime once a week.
- Logs: `/var/log/osrm-refresh.log` and `docker logs osrm`.
