#!/usr/bin/env bash
set -euo pipefail

# Edit before running. Docs: docs/DEPLOYMENT.md (Phase B)
DOMAIN="faucet.your-domain.com"     # YOUR_DOMAIN
EMAIL="admin@your-domain.com"       # Let's Encrypt email
# ──────────────────────────────────────────────────────────────────────────────

NGINX_CONF="/etc/nginx/sites-available/faucet"
WEBROOT="/var/www/faucet"

echo "[1/5] Встановлення пакетів..."
apt-get update -q
apt-get install -y -q nginx certbot python3-certbot-nginx

echo "[2/5] Налаштування firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 26656/tcp   # OPN P2P
ufw --force enable

echo "[3/5] Створення webroot..."
mkdir -p "$WEBROOT"
chown -R www-data:www-data "$WEBROOT"

echo "[4/5] Запис nginx конфігу..."
cat > "$NGINX_CONF" << NGINXCONF
server {
    listen 80;
    server_name ${DOMAIN};

    root ${WEBROOT};
    index index.html;

    # React SPA
    location / {
        try_files \$uri \$uri/ /index.html;
        add_header Cache-Control "no-cache";
    }

    # Статичні ассети — довгий кеш
    location ~* \.(js|css|png|ico|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Проксі до власного OPN RPC вузла
    location /rpc {
        proxy_pass          http://127.0.0.1:8545;
        proxy_http_version  1.1;
        proxy_set_header    Host \$host;
        proxy_set_header    X-Real-IP \$remote_addr;
        proxy_read_timeout  30s;

        # CORS
        add_header Access-Control-Allow-Origin  "*" always;
        add_header Access-Control-Allow-Methods "POST, GET, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;

        if (\$request_method = OPTIONS) { return 204; }
    }

    # Security headers
    add_header X-Frame-Options        "SAMEORIGIN"  always;
    add_header X-Content-Type-Options "nosniff"     always;
    add_header Referrer-Policy        "no-referrer" always;
}
NGINXCONF

ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/faucet
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl reload nginx

echo "[5/5] Отримання SSL-сертифіката..."
certbot --nginx \
    -d "$DOMAIN" \
    --non-interactive \
    --agree-tos \
    -m "$EMAIL" \
    --redirect

echo ""
echo "✓ Готово."
echo "  URL:     https://${DOMAIN}"
echo "  Webroot: ${WEBROOT}"
echo "  RPC:     https://${DOMAIN}/rpc → http://127.0.0.1:8545"
echo ""
echo "Наступний крок: завантажте фронтенд у ${WEBROOT}/"
