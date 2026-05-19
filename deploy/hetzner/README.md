# Deploying TilmezBus to a Hetzner Cloud VPS

Single-domain layout: **`tilmezbus.com`** serves the public landing page,
the admin UI, and the API on one host. Path-based routing in nginx splits
traffic between the Web and API containers.

| Path                | Container | Purpose                                       |
|---------------------|-----------|-----------------------------------------------|
| `/`                 | Web       | Public landing + admin login + SuperAdmin UI  |
| `/SuperAdmin/...`   | Web       | SuperAdmin pages                              |
| `/api/translations` | Web       | Admin i18n JSON used by `wwwroot/js`          |
| `/api-proxy/...`    | Web       | Admin's server-side API relay                 |
| `/api/v1/...`       | API       | The REST API consumed by mobile + admin       |
| `/hubs/...`         | API       | SignalR (WebSocket)                           |
| `/hangfire`         | API       | Job dashboard (IP-allowlisted)                |
| `/health`           | API       | Uptime probe                                  |

Target: Hetzner Cloud **CPX31** (4 vCPU, 8 GB RAM), **Ubuntu 24.04 LTS**.

OSRM is **not** included — the mobile app keeps using the public demo. Add
it later on a separate small VPS via `deploy/osrm/setup-osrm.sh` and point
the app via `--dart-define=OSRM_BASE_URL=…`.

---

## 0. Prerequisites (one-time, on the server)

```bash
ssh root@91.98.42.151

apt update && apt -y upgrade
apt -y install ca-certificates curl gnupg ufw certbot jq git

# Docker install
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list
apt update
apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Firewall
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

## 1. DNS

In your registrar for `tilmezbus.com`, create two A records pointing at
**91.98.42.151**:

| Host  | Type | Value           | TTL |
|-------|------|-----------------|-----|
| `@`   | A    | `91.98.42.151`  | 300 |
| `www` | A    | `91.98.42.151`  | 300 |

(`@` means the apex, i.e. `tilmezbus.com` itself.)

Verify from your laptop before continuing — certbot fails if DNS hasn't
propagated:

```bash
dig +short tilmezbus.com
dig +short www.tilmezbus.com
# Both should print 91.98.42.151
```

## 2. Clone the repo and configure secrets

```bash
cd /opt
git clone https://github.com/OsamaAbuNijem/smart-bus.git tilmezbus
cd tilmezbus/deploy/hetzner

cp .env.example .env
nano .env
```

In `.env`:

- `DOMAIN=tilmezbus.com` (no `https://`, no trailing slash)
- `POSTGRES_PASSWORD` → strong password (e.g. `openssl rand -base64 24`)
- `JWT_KEY` → run `openssl rand -base64 64` and paste the entire output
- `FIREBASE_CREDENTIALS_JSON` → the service-account JSON as a single line:

  ```bash
  # On your laptop:
  jq -c . firbase/smart-bus-firebase-firebase-adminsdk-fbsvc-XXX.json
  ```

  Paste the resulting one-liner as the value (no surrounding quotes).

```bash
chmod 600 .env
```

## 3. Issue the TLS certificate

Both subdomains share one cert. Port 80 must be free at this moment:

```bash
systemctl stop nginx apache2 2>/dev/null
mkdir -p /var/www/certbot

certbot certonly --standalone \
  -d tilmezbus.com \
  -d www.tilmezbus.com \
  --email you@example.com --agree-tos --no-eff-email
```

Cert lands in `/etc/letsencrypt/live/tilmezbus.com/`. Renewal happens
automatically every ~60 days via the certbot systemd timer (no downtime
because we use the webroot path that's mounted into the nginx container).

## 4. Set your Hangfire IP allowlist

```bash
# Find the WAN IP you'll administer from (run on YOUR LAPTOP):
curl ifconfig.me

# Then on the server, replace 1.2.3.4 in the nginx config:
nano /opt/tilmezbus/deploy/hetzner/nginx/tilmezbus.conf
# Edit the `allow 1.2.3.4;` line, save.
```

## 5. Bring it up

```bash
cd /opt/tilmezbus
docker compose -f deploy/hetzner/docker-compose.yml --env-file deploy/hetzner/.env up -d --build
```

First build takes ~3 minutes. The API container runs
`db.Database.MigrateAsync()` on boot, so the empty Postgres gets the schema
on the first start. Re-running is idempotent.

Check state:

```bash
docker compose -f deploy/hetzner/docker-compose.yml ps
docker compose -f deploy/hetzner/docker-compose.yml logs -f api
```

## 6. Verify

```bash
curl -fsS https://tilmezbus.com/health
# Expect:  Healthy

curl -fsS -o /dev/null -w "%{http_code}\n" https://tilmezbus.com/
# Expect:  200 (public landing page)

curl -fsS -o /dev/null -w "%{http_code}\n" https://tilmezbus.com/api/v1/auth/otp/request \
  -X POST -H "Content-Type: application/json" -d '{"phoneNumber":"+962793333333"}'
# Expect:  200 (OTP request)

curl -I https://www.tilmezbus.com/
# Expect:  HTTP/2 301, location: https://tilmezbus.com/
```

If you get `502 Bad Gateway`, the API container probably failed health checks.
`docker compose logs api` will show why.

## 7. Point the mobile app

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://tilmezbus.com
# Or for live testing:
flutter run --dart-define=API_BASE_URL=https://tilmezbus.com
```

## 8. Day-2 operations

### Updates

```bash
cd /opt/tilmezbus
git pull
docker compose -f deploy/hetzner/docker-compose.yml --env-file deploy/hetzner/.env up -d --build
```

EF migrations run automatically on every API boot.

### Logs

```bash
# Tail one service
docker compose -f deploy/hetzner/docker-compose.yml logs -f api

# Seq UI (not exposed publicly): SSH tunnel
ssh -L 5341:localhost:5341 root@91.98.42.151
# Then open http://localhost:5341 on your laptop
```

### Database

```bash
# Connect with psql inside the container
docker compose -f deploy/hetzner/docker-compose.yml exec postgres \
  psql -U tilmezbus -d tilmezbus

# Daily backup (add to root's crontab)
mkdir -p /opt/tilmezbus-backups
docker compose -f /opt/tilmezbus/deploy/hetzner/docker-compose.yml exec -T postgres \
  pg_dump -U tilmezbus tilmezbus | gzip > /opt/tilmezbus-backups/db-$(date +%F).sql.gz
```

### Cert renewal nginx reload

Certbot's systemd timer renews automatically but nginx needs a reload
to load the new cert. Add to root's crontab (`crontab -e`):

```cron
0 3 * * * docker compose -f /opt/tilmezbus/deploy/hetzner/docker-compose.yml exec nginx nginx -s reload >/dev/null 2>&1
```

## Common gotchas

- **502 Bad Gateway** → an upstream container is down or unhealthy.
  `docker compose logs api` / `docker compose logs web` will show why
  (wrong DB password, missing Firebase JSON, port collision).
- **Admin's /api-proxy 500s but mobile /api/v1 works** → nginx may have
  matched `/api/` too broadly. The config here uses `location /api/v1/`
  exactly so `/api/translations` and `/api-proxy/` stay on the Web container.
  Don't change that prefix.
- **WebSockets disconnect** → check the `/hubs/` block stays first; check
  the Hetzner Cloud Firewall (in the Hetzner Console UI) allows inbound 443.
- **OTP shows `1234` works** → only when the mobile app builds with
  `DEMO_MODE=true`. In production, the real 4-digit code is logged to Seq
  under `[OTP] Phone: +962… — Code: ####`.
- **Hangfire 403** → your office IP changed. Edit `nginx/tilmezbus.conf`
  and run `docker compose exec nginx nginx -s reload`.
