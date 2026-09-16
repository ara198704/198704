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

# ایجاد مسیرهای قابل نوشتن در /tmp
RUN mkdir -p /tmp/x-ui-db /tmp/x-ui-log /tmp/nginx \
    && chmod -R 777 /tmp

# کپی فایل‌های پروژه
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

# فیلتر envsubst تا فقط ${NGINX_PORT} جایگزین شود
ENV NGINX_ENVSUBST_FILTER='^(NGINX_PORT)$'

# هیچ VOLUME تعریف نکنید تا فایل‌سیستم دست‌نخورده بماند
CMD ["/start.sh"]
