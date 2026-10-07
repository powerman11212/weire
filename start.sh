#!/bin/bash
set -e

echo "🚀 Starting WireGuard with udp2raw obfuscation..."

# فعال‌سازی IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.src_valid_mark=1

# راه‌اندازی WireGuard
echo "▶️  Starting WireGuard interface wg0..."
wg-quick up wg0

# اجرای udp2raw برای مبهم‌سازی ترافیک
# ترافیک UDP وایرگارد (پورت 51820) را در بسته‌های TCP (پورت 8443) بسته‌بندی می‌کند
echo "▶️  Starting udp2raw on port 8443 (TCP) -> 51820 (UDP)..."
udp2raw -s -l0.0.0.0:8443 -r127.0.0.1:51820 --raw-mode faketcp -a -k "YourSecretKey" &

echo "✅ WireGuard + udp2raw is running."
echo "   - WireGuard UDP port: 51820 (internal)"
echo "   - udp2raw TCP port: 8443 (external)"

# نگه داشتن کانتینر در حال اجرا
wait