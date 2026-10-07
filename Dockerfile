FROM alpine:3.19

# نصب پیش‌نیازها
RUN apk add --no-cache \
    wireguard-tools \
    iproute2 \
    iptables \
    bash \
    curl \
    tar \
    && rm -rf /var/cache/apk/*

# دانلود و نصب udp2raw
RUN curl -L https://github.com/wangyu-/udp2raw-tunnel/releases/download/20200818.0/udp2raw_binaries.tar.gz \
    -o /tmp/udp2raw.tar.gz \
    && tar -xzf /tmp/udp2raw.tar.gz -C /tmp/ \
    && ls -la /tmp/ \
    && find /tmp -name "udp2raw_amd64" -exec mv {} /usr/local/bin/udp2raw \; \
    && chmod +x /usr/local/bin/udp2raw \
    && rm -rf /tmp/udp2raw*

# کپی فایل‌های کانفیگ و اسکریپت اجرا
COPY wg0.conf /etc/wireguard/wg0.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# اجرای اسکریپت
CMD ["/start.sh"]