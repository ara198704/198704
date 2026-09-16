#!/bin/bash
set -e

echo "🚀 Starting X-UI + nginx reverse proxy..."

export NGINX_PORT=8080

cd /usr/local/x-ui

mkdir -p /usr/local/x-ui/bin /tmp/client_body /tmp/proxy /tmp/fastcgi /tmp/uwsgi /tmp/scgi

echo "🔧 Applying panel settings via x-ui CLI..."
./x-ui setting -port 2053 -webBasePath /managepanel/ || true

echo "🔧 Building nginx.conf for fixed port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /tmp/nginx.conf

echo "▶️  Starting x-ui in background..."
./x-ui &
X_UI_PID=$!

echo "⏳ Waiting for x-ui to be ready..."
sleep 8

echo "🔍 === DIAGNOSTICS ==="
echo "--- Listening ports (netstat) ---"
netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null || echo "netstat/ss not available"

echo "--- Test: 3x-ui via 127.0.0.1:2053 ---"
curl -sS -o /dev/null -w "HTTP code: %{http_code}\n" http://127.0.0.1:2053/managepanel/ || echo "FAILED: 127.0.0.1:2053"

echo "--- Test: 3x-ui via [::1]:2053 ---"
curl -sS -o /dev/null -w "HTTP code: %{http_code}\n" "http://[::1]:2053/managepanel/" || echo "FAILED: [::1]:2053"

echo "=== END DIAGNOSTICS ==="

echo "▶️  Starting nginx in foreground on port $NGINX_PORT..."
nginx -t -c /tmp/nginx.conf

# اجرای nginx در پس‌زمینه برای تست
nginx -e /tmp/nginx-error.log -c /tmp/nginx.conf

sleep 3

echo "--- Test: nginx on 127.0.0.1:8080 ---"
curl -sS -o /dev/null -w "HTTP code: %{http_code}\n" http://127.0.0.1:8080/managepanel/ || echo "FAILED: nginx 127.0.0.1:8080"

echo "--- Test: nginx on [::1]:8080 ---"
curl -sS -o /dev/null -w "HTTP code: %{http_code}\n" "http://[::1]:8080/managepanel/" || echo "FAILED: nginx [::1]:8080"

echo "✅ All checks done. Keeping nginx in foreground..."
# برگرداندن nginx به foreground
nginx -s stop 2>/dev/null || true
sleep 1
exec nginx -e /tmp/nginx-error.log -g "daemon off;" -c /tmp/nginx.conf
