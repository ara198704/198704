#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

# اگر پلتفرم $PORT تزریق کرد از آن استفاده کن، وگرنه 8080
export NGINX_PORT=${PORT:-8080}

cd /usr/local/x-ui

mkdir -p /usr/local/x-ui/bin /tmp/client_body /tmp/proxy /tmp/fastcgi /tmp/uwsgi /tmp/scgi

echo "🔧 Applying panel settings via x-ui CLI..."
./x-ui setting -port 2053 -webBasePath /managepanel/ || true

echo "🔧 Building nginx.conf for port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf

echo "▶️  Starting x-ui in background..."
./x-ui &

echo "⏳ Waiting for x-ui to be ready..."
sleep 8

echo "🔍 Test 3x-ui on 127.0.0.1:2053:"
curl -sS -o /dev/null -w "HTTP code: %{http_code}\n" http://127.0.0.1:2053/managepanel/ || true

echo "▶️  Starting nginx in foreground on port $NGINX_PORT..."
nginx -t -c /tmp/nginx.conf
exec nginx -e /tmp/nginx-error.log -g "daemon off;" -c /tmp/nginx.conf
