#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

# مسیرهای قابل نوشتن
NGINX_TMP_DIR="/tmp/nginx"
X_UI_DB_DIR="/tmp/x-ui-db"

mkdir -p "$NGINX_TMP_DIR" "$X_UI_DB_DIR" /var/log/x-ui /var/log/nginx

# nginx همیشه روی پورت ثابت 3000 گوش می‌دهد (Dockfly این پورت را expose می‌کند)
export NGINX_PORT=3000

cd /usr/local/x-ui

echo "🔧 Applying panel settings via x-ui CLI..."
# تنظیم مسیر دیتابیس 3x-ui به مسیر قابل نوشتن
./x-ui setting -port 2053 -webBasePath /managepanel/ -dbPath "$X_UI_DB_DIR/x-ui.db" || true

echo "🔧 Building nginx.conf for fixed port: $NGINX_PORT"
# نوشتن کانفیگ nginx در مسیر قابل نوشتن
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > "$NGINX_TMP_DIR/nginx.conf"

# اصلاح مسیرهای لاگ و pid در کانفیگ nginx (چون فایل اصلی read-only است)
sed -i "s|/var/log/nginx/error.log|$NGINX_TMP_DIR/error.log|g" "$NGINX_TMP_DIR/nginx.conf"
sed -i "s|/var/log/nginx/access.log|$NGINX_TMP_DIR/access.log|g" "$NGINX_TMP_DIR/nginx.conf"
sed -i "s|/var/run/nginx.pid|$NGINX_TMP_DIR/nginx.pid|g" "$NGINX_TMP_DIR/nginx.conf"

echo "▶️  Starting x-ui in background..."
./x-ui &
X_UI_PID=$!

sleep 3

echo "▶️  Starting nginx in foreground on port $NGINX_PORT..."
# استفاده از کانفیگ سفارشی در مسیر قابل نوشتن
nginx -t -c "$NGINX_TMP_DIR/nginx.conf"
exec nginx -g "daemon off;" -c "$NGINX_TMP_DIR/nginx.conf"
