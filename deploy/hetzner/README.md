# Deploying TilmezBus to a Hetzner Cloud VPS

Target: **CPX31** (4 vCPU, 8 GB RAM), **Ubuntu 24.04 LTS**, with `api.tilmezbus.com`
and `admin.tilmezbus.com` resolving to the box.

This stack runs entirely via Docker Compose: API + Web + Postgres + Redis +
Seq + nginx. TLS certificates are issued on the host with certbot and bind-mounted
into the nginx container.

OSRM (street routing) is **not** included here — the mobile app keeps using the
public demo for now. Add it later via `deploy/osrm/setup-osrm.sh` on a separate
small VPS, then point the app via `--dart-define=OSRM_BASE_URL=…`.

---

## 0. Prerequisites (one-time, on the server)

```bash
# SSH in as root
ssh root@<vps-ip>

# Update + install Docker, Compose, certbot, nginx tools
apt update && apt -y upgrade
apt -y install ca-certificates curl gnupg ufw certbot jq git

# Docker official install (https://docs.docker.com/engine/install/ubuntu/)
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

In your registrar's DNS panel, create two **A records** pointing at the VPS IP:

| Host                  | Type | Value          |
|-----------------------|------|----------------|
| `api.tilmezbus.com`   | A    | <your-vps-ip>  |
| `admin.tilmezbus.com` | A    | <your-vps-ip>  |

TTL 300 is fine. Wait until `dig +short api.tilmezbus.com` returns the right
IP before continuing — certbot will fail if DNS hasn't propagated.

## 2. Clone the repo and configure secrets

```bash
cd /opt
git clone https://github.com/OsamaAbuNijem/smart-bus.git tilmezbus
cd tilmezbus/deploy/hetzner

# Copy and edit secrets
cp .env.example .env
nano .env
```

In `.env`:

- `DOMAIN=tilmezbus.com` (no `https://`, no slashes)
- `POSTGRES_PASSWORD` → strong password
- `JWT_KEY` → run `openssl rand -base64 64` and paste the output
- `FIREBASE_CREDENTIALS_JSON` → upload the service-account JSON to the box first,
  then paste its single-line form:

  ```bash
  # On your laptop, encode the file as a single line:
  jq -c . firbase/smart-bus-firebase-firebase-adminsdk-fbsvc-XXX.json
  # Copy the entire output, paste it as the value of FIREBASE_CREDENTIALS_JSON.
  ```

Verify the file is not world-readable: `chmod 600 .env`.

## 3. Issue TLS certificates (one-time)

Certbot needs port 80 free. Use the **standalone** plugin for the first
issue, then renewal happens via the webroot mounted into nginx.

```bash
# Get certs for both subdomains
certbot certonly --standalone \
  -d api.tilmezbus.com \
  -d admin.tilmezbus.com \
  --email you@example.com --agree-tos --no-eff-email

# Auto-renewal: certbot installs a systemd timer that runs twice a day.
# Renewals will use webroot (no downtime) because we'll bind-mount
# /var/www/certbot into nginx in the next step.
mkdir -p /var/www/certbot
```

> If `certbot` says "another instance running" or "port 80 in use", make sure
> no nginx/apache is already running: `systemctl stop nginx apache2 2>/dev/null`.

## 4. Set your Hangfire IP allowlist

```bash
# Find the WAN IP you'll administer from (your home/office):
curl ifconfig.me   # run on YOUR LAPTOP, not the server

# Then on the server, edit nginx/tilmezbus.conf and replace 1.2.3.4
# with that IP. Save the file.
nano /opt/tilmezbus/deploy/hetzner/nginx/tilmezbus.conf
```

## 5. Bring it up

```bash
cd /opt/tilmezbus
docker compose -f deploy/hetzner/docker-compose.yml --env-file deploy/hetzner/.env up -d --build
```

First build takes ~3 minutes (pulling SDK image + restoring NuGet packages).
The API container does `db.Database.MigrateAsync()` on startup, so the
Postgres schema is created automatically on first run.

Check the state:

```bash
docker compose -f deploy/hetzner/docker-compose.yml ps
docker compose -f deploy/hetzner/docker-compose.yml logs -f api
```

Healthy looks like:

```
NAME          STATUS                     PORTS
tilmezbus-api-1     Up (healthy)
tilmezbus-postgres-1 Up (healthy)
tilmezbus-redis-1    Up (healthy)
tilmezbus-nginx-1    Up                  0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
tilmezbus-seq-1      Up
tilmezbus-web-1      Up
```

## 6. Verify

```bash
curl -fsS https://api.tilmezbus.com/health
# Expect:  Healthy

curl -fsS -o /dev/null -w "%{http_code}\n" https://admin.tilmezbus.com/
# Expect:  200 (admin login page)
```

If you get `502 Bad Gateway`, the API container probably failed health checks.
`docker compose logs api` will show why (usually wrong DB password or missing
Firebase JSON).

## 7. Point the mobile app

In your Flutter run command (or build args for a release APK/IPA):

```bash
flutter run --dart-define=API_BASE_URL=https://api.tilmezbus.com
# Or, for a release build:
flutter build apk --release --dart-define=API_BASE_URL=https://api.tilmezbus.com
```

## 8. Day-2 operations

### Updates

```bash
cd /opt/tilmezbus
git pull
docker compose -f deploy/hetzner/docker-compose.yml --env-file deploy/hetzner/.env up -d --build
```

EF migrations run automatically on every API boot (idempotent).

### Logs

```bash
# Tail one service
docker compose -f deploy/hetzner/docker-compose.yml logs -f api

# Structured logs (Seq) — not exposed publicly; SSH tunnel to view:
ssh -L 5341:localhost:5341 root@<vps-ip>
# Then open http://localhost:5341 on your laptop
```

### Database

```bash
# Connect with psql
docker compose -f deploy/hetzner/docker-compose.yml exec postgres \
  psql -U tilmezbus -d tilmezbus

# Backup (run daily via cron)
docker compose -f deploy/hetzner/docker-compose.yml exec -T postgres \
  pg_dump -U tilmezbus tilmezbus | gzip > /opt/tilmezbus-backups/db-$(date +%F).sql.gz
```

### TLS renewal

Certbot's systemd timer renews automatically. After a renewal, nginx needs
a reload to pick up the new cert:

```bash
# Add to root's crontab (`crontab -e`):
0 3 * * * docker compose -f /opt/tilmezbus/deploy/hetzner/docker-compose.yml exec nginx nginx -s reload >/dev/null 2>&1
```

## Common gotchas

- **502 Bad Gateway on api.tilmezbus.com** → API container down or unhealthy.
  Check `docker compose logs api` for "Unable to connect to Postgres" (wrong
  password) or "Could not load Firebase credentials".
- **WebSocket disconnects on the mobile app** → SignalR can't upgrade.
  Verify the `/hubs/` block in nginx exists (it does in `tilmezbus.conf`)
  and that Hetzner Cloud Firewall (if you enabled one in the UI) allows
  inbound 443.
- **OTP comes back as the *demo* code 1234** → only the mobile app's
  `DEMO_MODE=true` override does that. In Production, the real 4-digit code
  is logged to Seq under "OTP] Phone:".
- **Hangfire dashboard 403** → your office IP rotates (DHCP). Update the
  `allow` line in `nginx/tilmezbus.conf` and `docker compose exec nginx nginx -s reload`.
