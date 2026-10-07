FROM alpine:3.19

# نصب پیش‌نیازها
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    openssl \
    ca-certificates \
    tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime

# نصب sing-box (هسته اصلی)
RUN curl -L https://github.com/SagerNet/sing-box/releases/download/v1.10.1/sing-box-1.10.1-linux-amd64.tar.gz \
    -o /tmp/sing-box.tar.gz \
    && tar -xzf /tmp/sing-box.tar.gz -C /tmp/ \
    && mv /tmp/sing-box-1.10.1-linux-amd64/sing-box /usr/local/bin/ \
    && chmod +x /usr/local/bin/sing-box \
    && rm -rf /tmp/sing-box*

# نصب cloudflared برای تونل (اختیاری)
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    -o /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

# کپی فایل‌ها
COPY config.json /etc/sing-box/config.json
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]