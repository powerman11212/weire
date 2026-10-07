# WireGuard + udp2raw روی Railway

پروژه اجرای WireGuard مبهم‌شده روی Railway برای عبور از DPI ایران.

## ساخت کلیدها

```bash
# نصب wireguard-tools
apk add --no-cache wireguard-tools

# کلیدهای سرور
wg genkey | tee server_private.key | wg pubkey > server_public.key

# کلیدهای کلاینت
wg genkey | tee client_private.key | wg pubkey > client_public.key
