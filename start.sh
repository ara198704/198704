#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

export NGINX_PORT=8080

cd /usr/local/x-ui

# اطمینان از وجود پوشه bin (اگر volume خالی بود)
mkdir -p /usr/local/x-ui/bin

echo "🔧 Applying panel settings via x-ui CLI..."
./x-ui setting -port 2053 -webBasePath /managepanel/ || true

echo "🔧 Building nginx.conf for fixed port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf

echo "▶️  Starting x-ui in background..."
./x-ui &
X_UI_PID=$!

sleep 3

echo "▶️  Starting nginx in foreground on port $NGINX_PORT..."
nginx -t -c /tmp/nginx.conf
exec nginx -g "daemon off;" -c /tmp/nginx.conf
