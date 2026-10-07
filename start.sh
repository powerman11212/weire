#!/bin/bash
set -e

echo "🚀 Starting WireGuard with udp2raw obfuscation..."

# ==================== متغیرها ====================
export WG_PORT=${WG_PORT:-51820}
export UDP2RAW_PORT=${PORT:-8443}
export UDP2RAW_KEY=${UDP2RAW_KEY:-ChangeMeToAStrongPassword12345678}

echo "🔧 Configuration:"
echo "   WG internal port   = $WG_PORT (UDP)"
echo "   udp2raw public port = $UDP2RAW_PORT (TCP)"
echo "   obfuscation key    = (hidden)"

# ==================== فعال‌سازی forwarding ====================
echo "🔧 Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1 || true
sysctl -w net.ipv4.conf.all.src_valid_mark=1 || true

# ==================== راه‌اندازی WireGuard ====================
echo "▶️  Starting WireGuard (wg0)..."
wg-quick up wg0

# ==================== اجرای udp2raw ====================
echo "▶️  Starting udp2raw on port $UDP2RAW_PORT (TCP) -> $WG_PORT (UDP)..."
udp2raw -s \
    -l0.0.0.0:$UDP2RAW_PORT \
    -r127.0.0.1:$WG_PORT \
    --raw-mode faketcp \
    -a \
    -k "$UDP2RAW_KEY" &

sleep 2

# ==================== بررسی وضعیت ====================
echo ""
echo "✅ Services status:"
echo "   WireGuard:  $(wg show wg0 2>/dev/null | head -1 || echo 'check failed')"
echo "   udp2raw:    running on TCP $UDP2RAW_PORT"
echo ""

# ==================== نگه داشتن کانتینر ====================
echo "🎉 All services started. Container is running."
wait