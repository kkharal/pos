#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Nginx Reverse Proxy + SSL Setup for POS System
# ─────────────────────────────────────────────────────────────────────────────
# This script installs Nginx, configures it as a reverse proxy for the Flask/
# Gunicorn app running on 127.0.0.1:5000, and obtains a free SSL certificate
# from Let's Encrypt using Certbot.
#
# Usage:
#   sudo ./setup-nginx.sh yourdomain.com
#   sudo ./setup-nginx.sh yourdomain.com your@email.com
#
# Requirements:
#   - Ubuntu/Debian server
#   - Root or sudo access
#   - Domain name pointed to this server's IP (A record)
#   - Port 80 and 443 open in firewall
# ─────────────────────────────────────────────────────────────────────────────

set -e

# ── Validate arguments ────────────────────────────────────────────────────────

DOMAIN="$1"
EMAIL="${2:-}"

if [ -z "$DOMAIN" ]; then
    echo "❌ Usage: sudo $0 <domain> [email]"
    echo ""
    echo "  Examples:"
    echo "    sudo $0 myshop.example.com"
    echo "    sudo $0 myshop.example.com admin@example.com"
    echo ""
    echo "  The domain must already point to this server's IP address."
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)."
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Nginx + SSL Setup for: $DOMAIN"
echo "════════════════════════════════════════════════════════════════"
echo ""

# ── Step 1: Install Nginx & Certbot ──────────────────────────────────────────

echo "[1/5] Installing Nginx and Certbot..."

apt update -qq
apt install -y nginx certbot python3-certbot-nginx > /dev/null 2>&1

echo "  ✓ Nginx and Certbot installed"

# ── Step 2: Configure firewall (UFW) ─────────────────────────────────────────

echo "[2/5] Configuring firewall..."

if command -v ufw &>/dev/null; then
    ufw allow 'Nginx Full' > /dev/null 2>&1 || true
    ufw allow OpenSSH > /dev/null 2>&1 || true

    # Block common attack ports outbound (prevent abuse if compromised)
    ufw deny out 23/tcp > /dev/null 2>&1 || true   # Telnet
    ufw deny out 8080/tcp > /dev/null 2>&1 || true # HTTP-proxy scanning

    # Enable UFW if not already active
    if ! ufw status | grep -q "Status: active"; then
        echo "y" | ufw enable > /dev/null 2>&1
    fi

    echo "  ✓ UFW configured (HTTP, HTTPS, SSH allowed; outbound 23,8080 blocked)"
else
    echo "  ⚠ UFW not found, skipping firewall config"
fi

# ── Step 3: Create Nginx site config ─────────────────────────────────────────

echo "[3/5] Creating Nginx configuration..."

NGINX_CONF="/etc/nginx/sites-available/pos"

cat > "$NGINX_CONF" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Max upload size (for database restore)
    client_max_body_size 200M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 120s;
    }

    # Cache static files
    location /static/ {
        proxy_pass http://127.0.0.1:5000/static/;
        expires 7d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable the site
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/pos
rm -f /etc/nginx/sites-enabled/default

# Test config
if ! nginx -t 2>/dev/null; then
    echo "❌ Nginx configuration test failed!"
    nginx -t
    exit 1
fi

systemctl restart nginx
echo "  ✓ Nginx configured and running"

# ── Step 4: Obtain SSL certificate ───────────────────────────────────────────

echo "[4/5] Obtaining SSL certificate from Let's Encrypt..."

CERTBOT_ARGS="--nginx -d ${DOMAIN} --non-interactive --agree-tos"

if [ -n "$EMAIL" ]; then
    CERTBOT_ARGS="$CERTBOT_ARGS --email ${EMAIL}"
else
    CERTBOT_ARGS="$CERTBOT_ARGS --register-unsafely-without-email"
fi

if certbot $CERTBOT_ARGS; then
    echo "  ✓ SSL certificate obtained and configured"
else
    echo ""
    echo "  ⚠ SSL certificate failed. Common reasons:"
    echo "    - Domain '$DOMAIN' does not point to this server's IP"
    echo "    - Port 80 is blocked by hosting provider's network firewall"
    echo ""
    echo "  The app is still accessible via http://${DOMAIN}"
    echo ""
    echo "  To fix, try one of these:"
    echo "    1. Open port 80/443 in your hosting provider's firewall panel, then:"
    echo "       sudo certbot --nginx -d ${DOMAIN}"
    echo ""
    echo "    2. Use DNS validation (works even if port 80 is blocked):"
    echo "       sudo certbot certonly --manual --preferred-challenges dns -d ${DOMAIN}"
    echo "       (Add the TXT record it shows to your DNS, verify with dig, then press Enter)"
    echo "       Then install into Nginx:"
    echo "       sudo certbot install --nginx -d ${DOMAIN}"
fi

# ── Step 5: Set up auto-renewal ──────────────────────────────────────────────

echo "[5/5] Setting up certificate auto-renewal..."

# Certbot auto-renewal is installed by default via systemd timer
systemctl enable certbot.timer 2>/dev/null || true
systemctl start certbot.timer 2>/dev/null || true

echo "  ✓ Auto-renewal configured (checks twice daily)"

# ── Done ─────────────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  ✓ Setup Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  Your POS system is now accessible at:"
echo ""
echo "    🔒 https://${DOMAIN}"
echo ""
echo "  Architecture:"
echo "    User → HTTPS (443) → Nginx → HTTP (127.0.0.1:5000) → Gunicorn"
echo ""
echo "  Make sure the app is running:"
echo "    cd $(pwd) && ./start.sh"
echo ""
echo "  Useful commands:"
echo "    sudo systemctl status nginx      # Check Nginx status"
echo "    sudo nginx -t && sudo systemctl reload nginx  # Reload config"
echo "    sudo certbot renew --dry-run     # Test cert renewal"
echo "    sudo tail -f /var/log/nginx/error.log  # Nginx errors"
echo ""
echo "════════════════════════════════════════════════════════════════"
