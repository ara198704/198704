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

# ایجاد مسیرهای قابل نوشتن و تنظیم مجوز
RUN mkdir -p /etc/x-ui /var/log/x-ui /var/lib/nginx/tmp /var/lib/nginx/logs /var/log/nginx \
    && chmod -R 777 /usr/local/x-ui /etc/x-ui /var/log/x-ui /var/lib/nginx /var/log/nginx

# کپی فایل‌های پروژه
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV NGINX_ENVSUBST_FILTER='^(NGINX_PORT)$'

# مهم: /usr/local/x-ui هم volume می‌شود تا bin/ و فایل‌های xray قابل نوشتن باشند
VOLUME ["/usr/local/x-ui", "/etc/x-ui", "/var/log/x-ui", "/var/lib/nginx", "/var/log/nginx"]

CMD ["/start.sh"]
