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

# ایجاد مسیرهای قابل نوشتن برای nginx و دیتابیس 3x-ui
RUN mkdir -p /tmp/nginx /tmp/x-ui-db /var/log/x-ui /var/log/nginx

# معرفی این مسیرها به عنوان volume (برای اطمینان از قابل نوشتن بودن)
VOLUME ["/tmp/nginx", "/tmp/x-ui-db", "/var/log/x-ui", "/var/log/nginx"]

# کپی فایل‌های پروژه
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

# تنظیم فیلتر envsubst تا فقط ${NGINX_PORT} را جایگزین کند
ENV NGINX_ENVSUBST_FILTER='^(NGINX_PORT)$'

# Railway/Dockfly پورت رو از طریق متغیر $PORT تزریق می‌کند
CMD ["/start.sh"]
