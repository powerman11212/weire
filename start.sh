#!/bin/bash
set -e

echo "🚀 Starting TUIC over WebSocket + Cloudflare Tunnel..."

# ==================== متغیرها ====================
export TUIC_UUID=${TUIC_UUID:-$(cat /proc/sys/kernel/random/uuid)}
export TUIC_PASSWORD=${TUIC_PASSWORD:-$(openssl rand -base64 24)}
export WS_PATH=${WS_PATH:-/tuic-ws}
export PORT=${PORT:-8080}

echo "==========================================="
echo "🔧 Configuration:"
echo "   UUID       = $TUIC_UUID"
echo "   Password   = $TUIC_PASSWORD"
echo "   WS Path    = $WS_PATH"
echo "   Port       = $PORT"
echo "==========================================="

# ==================== ساخت config.json ====================
cat > /etc/sing-box/config.json << EOF
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "tuic",
      "tag": "tuic-in",
      "listen": "0.0.0.0",
      "listen_port": 8443,
      "users": [
        {
          "uuid": "$TUIC_UUID",
          "password": "$TUIC_PASSWORD"
        }
      ],
      "congestion_control": "bbr",
      "auth_timeout": "3s",
      "zero_rtt_handshake": true,
      "heartbeat": "10s",
      "tls": {
        "enabled": true,
        "server_name": "www.microsoft.com",
        "alpn": ["h3"],
        "certificate_path": "/etc/sing-box/cert.pem",
        "key_path": "/etc/sing-box/key.pem"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

# ==================== ساخت گواهی خودامضا ====================
echo "🔐 Generating self-signed certificate..."
openssl req -x509 -newkey rsa:2048 -keyout /etc/sing-box/key.pem -out /etc/sing-box/cert.pem \
    -days 3650 -nodes -subj "/CN=www.microsoft.com" 2>/dev/null

# ==================== شروع sing-box ====================
echo "▶️  Starting sing-box..."
sing-box run -c /etc/sing-box/config.json &

sleep 3

# ==================== شروع تونل Cloudflare (اختیاری) ====================
if [ -n "$ARGO_TOKEN" ]; then
    echo "▶️  Starting Cloudflare Tunnel..."
    cloudflared tunnel --no-autoupdate run --token "$ARGO_TOKEN" &
fi

echo ""
echo "✅ TUIC server is running."
echo "   TUIC UDP port: 8443 (internal)"
echo "   WebSocket path: $WS_PATH"
echo ""

# نگه داشتن کانتینر
wait