FROM alpine:3.19

RUN apk add --no-cache \
    curl \
    bash \
    ca-certificates \
    socat \
    tzdata \
    sqlite \
    nginx \
    gettext \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime

# دانلود و نصب 3x-ui
RUN curl -L https://github.com/mhsanaei/3x-ui/releases/download/v3.5.0/x-ui-linux-amd64.tar.gz -o /tmp/x-ui.tar.gz \
    && tar -xzf /tmp/x-ui.tar.gz -C /usr/local/ \
    && rm /tmp/x-ui.tar.gz \
    && chmod +x /usr/local/x-ui/x-ui

# انتقال پوشه bin به /tmp و ساخت symlink (برای رفع خطای read-only در xray)
RUN mv /usr/local/x-ui/bin /tmp/x-ui-bin \
    && ln -s /tmp/x-ui-bin /usr/local/x-ui/bin \
    && chmod -R 777 /tmp/x-ui-bin

# ایجاد مسیرهای قابل نوشتن برای دیتابیس و لاگ‌های 3x-ui و nginx
RUN mkdir -p /etc/x-ui /var/log/x-ui /var/lib/nginx/tmp /var/lib/nginx/logs /var/log/nginx \
    && chmod -R 777 /etc/x-ui /var/log/x-ui /var/lib/nginx /var/log/nginx

# کپی فایل‌های پروژه
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

# فیلتر envsubst تا فقط ${NGINX_PORT} جایگزین شود
ENV NGINX_ENVSUBST_FILTER='^(NGINX_PORT)$'

# تعریف volume برای مسیرهای قابل نوشتن
VOLUME ["/etc/x-ui", "/var/log/x-ui", "/var/lib/nginx", "/var/log/nginx"]

CMD ["/start.sh"]
