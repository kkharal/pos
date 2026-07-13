# POS System — Server Migration Guide

> Target OS: **Ubuntu 24.04 LTS** (same as current server)
> 
> This guide migrates the full stack from the current server to a fresh Ubuntu machine.

---

## Current Server Summary

| Component   | Detail                                              |
|-------------|-----------------------------------------------------|
| OS          | Ubuntu 24.04.4 LTS                                  |
| Python      | 3.12.3                                              |
| MySQL       | 8.0.46                                              |
| App path    | `/root/work/pos`                                    |
| DB name     | `pos_mysql_app`                                     |
| DB user     | `pos_app`                                           |
| Gunicorn    | 3 workers, bound to `127.0.0.1:5000`                |
| Nginx       | Reverse proxy + SSL (Let's Encrypt)                 |
| Domain      | `tradesync.shop` (update to new domain if changing) |
| Service     | `pos.service` (systemd, auto-starts on boot)        |

---

## Part 1 — On the CURRENT server: Export data

### 1.1 Dump the database

```bash
cd /root/work/pos

# Replace YOUR_POS_APP_PASSWORD with the actual DB password from .env
mysqldump -u pos_app -p pos_mysql_app > backups/migration_$(date +%Y%m%d_%H%M%S).sql
```

### 1.2 Copy the .env file somewhere safe

```bash
cat /root/work/pos/.env
```

Write down / copy all values — you will need them on the new server.

### 1.3 Transfer files to new server

```bash
# Option A — rsync (preferred, runs from new server or current)
rsync -avz --exclude 'venv/' --exclude '__pycache__/' \
  /root/work/pos/ root@NEW_SERVER_IP:/root/work/pos/

# Option B — scp of a tarball (run on current server)
tar --exclude='./venv' --exclude='./__pycache__' \
    -czf /tmp/pos_app.tar.gz -C /root/work pos
scp /tmp/pos_app.tar.gz root@NEW_SERVER_IP:/tmp/
```

---

## Part 2 — On the NEW server: Base system setup

### 2.1 Update and install system packages

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
    python3 python3-pip python3-venv python3.12-venv \
    mysql-server mysql-client \
    nginx \
    certbot python3-certbot-nginx \
    ufw \
    git curl wget
```

### 2.2 Start and secure MySQL

```bash
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure the installation (set root password, remove test DB)
sudo mysql_secure_installation
```

### 2.3 Create the database and app user

```bash
sudo mysql
```

Inside MySQL shell:

```sql
CREATE DATABASE pos_mysql_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'pos_app'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY 'YOUR_STRONG_PASSWORD';
CREATE USER 'pos_app'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YOUR_STRONG_PASSWORD';

GRANT ALL PRIVILEGES ON pos_mysql_app.* TO 'pos_app'@'127.0.0.1';
GRANT ALL PRIVILEGES ON pos_mysql_app.* TO 'pos_app'@'localhost';

FLUSH PRIVILEGES;
EXIT;
```

> Use the **same password** that is in the current `.env` file, or pick a new strong one and update `.env` after copying.

---

## Part 3 — On the NEW server: Deploy the app

### 3.1 Extract / place the app files

```bash
# If you used rsync, the files are already in /root/work/pos
# If you used a tarball:
mkdir -p /root/work
tar -xzf /tmp/pos_app.tar.gz -C /root/work
```

### 3.2 Create the .env file

```bash
cd /root/work/pos
cp .env .env.bak 2>/dev/null || true
nano .env
```

Set these values (use your current `.env` as reference):

```env
# Database
DB_TYPE=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=pos_app
DB_PASSWORD=YOUR_STRONG_PASSWORD
DB_NAME=pos_mysql_app

# Flask
SECRET_KEY=<generate new: python3 -c "import secrets; print(secrets.token_hex(32))">
SESSION_TIMEOUT=1800
FLASK_DEBUG=0
HOST=127.0.0.1
PORT=5000

# CORS — update with your new domain
ALLOWED_ORIGINS=https://yourdomain.com

# Multi-shop
ENABLE_MULTI_SHOP=true
DEFAULT_SHOP_ID=1
```

Generate a fresh SECRET_KEY:

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### 3.3 Create required directories

```bash
mkdir -p /root/work/pos/logs
mkdir -p /root/work/pos/backups
```

### 3.4 Set up Python virtual environment

```bash
cd /root/work/pos
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt
```

### 3.5 Import the database

```bash
# Copy the dump from old server if not already present
# scp root@OLD_SERVER_IP:/root/work/pos/backups/migration_YYYYMMDD_HHMMSS.sql /root/work/pos/backups/

mysql -u pos_app -p pos_mysql_app < /root/work/pos/backups/migration_YYYYMMDD_HHMMSS.sql
```

Verify the import:

```bash
mysql -u pos_app -p -e "USE pos_mysql_app; SHOW TABLES; SELECT COUNT(*) FROM users;"
```

---

## Part 4 — On the NEW server: Systemd service

### 4.1 Create the systemd service file

```bash
sudo nano /etc/systemd/system/pos.service
```

Paste this content:

```ini
[Unit]
Description=Clothing Shop POS Gunicorn Service
After=network.target mysql.service

[Service]
Type=simple
User=root
WorkingDirectory=/root/work/pos
Environment=PYTHONUNBUFFERED=1
EnvironmentFile=-/root/work/pos/.env
ExecStart=/root/work/pos/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app --access-logfile /root/work/pos/logs/access.log --error-logfile /root/work/pos/logs/error.log --timeout 120
Restart=always
RestartSec=5
StandardOutput=append:/root/work/pos/logs/app.log
StandardError=append:/root/work/pos/logs/error.log
KillMode=mixed
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
```

### 4.2 Enable and start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable pos
sudo systemctl start pos
sudo systemctl status pos
```

Expected: `Active: active (running)`

Check logs if there's an error:

```bash
sudo journalctl -u pos -n 50 --no-pager
tail -f /root/work/pos/logs/error.log
```

---

## Part 5 — On the NEW server: Nginx + SSL

### 5.1 Point your domain DNS to the new server

Before running Certbot, the domain **must** have an A record pointing to the new server IP. Wait for DNS to propagate (use `dig yourdomain.com` to confirm).

### 5.2 Run the setup-nginx.sh script

```bash
cd /root/work/pos
sudo bash setup-nginx.sh yourdomain.com your@email.com
```

This script automatically:
- Installs Nginx + Certbot
- Configures the reverse proxy with rate limiting and security headers
- Obtains and installs the SSL certificate from Let's Encrypt
- Sets up UFW firewall rules
- Enables Certbot auto-renewal

### 5.3 Verify Nginx

```bash
sudo nginx -t
sudo systemctl status nginx
```

---

## Part 6 — Firewall (UFW)

The `setup-nginx.sh` script handles UFW, but verify the rules match what the current server has:

```bash
sudo ufw status
```

Expected rules:

```
OpenSSH          ALLOW IN
Nginx Full       ALLOW IN   (ports 80 + 443)
23/tcp           DENY OUT   (Telnet)
25/tcp           DENY OUT   (SMTP)
3389/tcp         DENY OUT   (RDP)
```

If MySQL remote access is needed from a specific IP:

```bash
sudo ufw allow from YOUR_ADMIN_IP to any port 3306
```

---

## Part 7 — Post-migration verification

Run these checks on the new server:

```bash
# All three services running?
systemctl is-active nginx mysql pos

# App responding?
curl -sk https://yourdomain.com/api/public/shop-name | python3 -m json.tool

# SSL certificate valid?
certbot certificates

# Ports open?
ss -tlnp | grep -E ':80|:443|:5000|:3306'

# Gunicorn workers up?
ps aux | grep gunicorn | grep -v grep
```

### Smoke test

```bash
# HTTP redirects to HTTPS
curl -I http://yourdomain.com

# Login page loads
curl -sk https://yourdomain.com/login | grep -o '<title>[^<]*</title>'
```

---

## Part 8 — Cutover checklist

- [ ] DNS A record updated to new server IP
- [ ] DNS propagated (`dig yourdomain.com` shows new IP)
- [ ] Database imported and verified
- [ ] `.env` file correct (DB password, SECRET_KEY, ALLOWED_ORIGINS)
- [ ] `pos.service` active and running
- [ ] Nginx active, SSL certificate valid
- [ ] Login works at `https://yourdomain.com`
- [ ] Old server kept on for at least 24 h as fallback

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `502 Bad Gateway` | Gunicorn not running or crashed | `systemctl restart pos`, check `logs/error.log` |
| `500` on `/login` | DB auth failure | Verify `.env` `DB_USER`/`DB_PASSWORD`, check MySQL user exists |
| SSL cert fails | Port 80 blocked or DNS not propagated | Check DNS with `dig`, open port 80, re-run `certbot` |
| `1698 Access denied` | Wrong MySQL auth plugin | Recreate user with `mysql_native_password` (see Part 2.3) |
| Nginx config test fails | Duplicate directives | Ensure only `pos` file is in `/etc/nginx/sites-enabled/`, no backup files |
| `upstream connect refused` | Gunicorn bound to wrong address | Confirm `--bind 127.0.0.1:5000` in service, `proxy_pass http://127.0.0.1:5000` in Nginx |

---

## Key file locations (new server)

| File | Path |
|------|------|
| App code | `/root/work/pos/` |
| Environment config | `/root/work/pos/.env` |
| Gunicorn access log | `/root/work/pos/logs/access.log` |
| Gunicorn error log | `/root/work/pos/logs/error.log` |
| Systemd service | `/etc/systemd/system/pos.service` |
| Nginx site config | `/etc/nginx/sites-available/pos` |
| Nginx access log | `/var/log/nginx/pos_access.log` |
| Nginx error log | `/var/log/nginx/pos_error.log` |
| SSL certificates | `/etc/letsencrypt/live/yourdomain.com/` |
| DB backups | `/root/work/pos/backups/` |
