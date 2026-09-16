#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

# پورت ثابت Dockfly
export NGINX_PORT=8080

# مهم: مسیرهای 3x-ui را به /tmp منتقل می‌کنیم
export XUI_DB_FOLDER=/tmp/x-ui-db
export XUI_LOG_FOLDER=/tmp/x-ui-log

mkdir -p "$XUI_DB_FOLDER" "$XUI_LOG_FOLDER"
chmod -R 777 /tmp

cd /usr/local/x-ui

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
exec nginx -e /tmp/error.log -g "daemon off;" -c /tmp/nginx.conf
