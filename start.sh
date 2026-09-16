#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

NGINX_CONF="/tmp/nginx.conf"

export NGINX_PORT=3000

cd /usr/local/x-ui

echo "🔧 Applying panel settings via x-ui CLI..."
# دیگر از -dbPath استفاده نمی‌کنیم. symlink /etc/x-ui به /tmp/x-ui-db اشاره می‌کند.
./x-ui setting -port 2053 -webBasePath /managepanel/ || true

echo "🔧 Building nginx.conf for fixed port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > "$NGINX_CONF"

echo "▶️  Starting x-ui in background..."
./x-ui &
X_UI_PID=$!

sleep 3

echo "▶️  Starting nginx in foreground on port $NGINX_PORT..."
nginx -t -c "$NGINX_CONF"
exec nginx -g "daemon off;" -c "$NGINX_CONF"
