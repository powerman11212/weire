# TUIC over WebSocket + Cloudflare Tunnel روی Railway

این پروژه TUIC را با استفاده از sing-box و تونل Cloudflare روی Railway اجرا می‌کند.

## متغیرهای محیطی

| متغیر | توضیح | پیش‌فرض |
| ------- | ------- | --------- |
| `TUIC_UUID` | UUID کاربر | خودکار تولید می‌شود |
| `TUIC_PASSWORD` | رمز عبور | خودکار تولید می‌شود |
| `WS_PATH` | مسیر WebSocket | `/tuic-ws` |
| `ARGO_TOKEN` | توکن Cloudflare Tunnel | اختیاری |

```json
{
  "TUIC_UUID": "7f3e8a1b-4c2d-4e5f-9a8b-1c2d3e4f5a6b",
  "TUIC_PASSWORD": "MyStr0ngP@ssw0rd!2026_Random123",
  "WS_PATH": "/tuic-ws",
  "ARGO_TOKEN": "",
  "TZ": "Asia/Tehran"
}

## مراحل استقرار

1. این ۴ فایل را در یک ریپوی گیت‌هاب بگذارید
2. در Railway: **New Project → Deploy from GitHub repo**
3. در **Variables**، متغیرهای بالا را ست کنید
4. در **Settings → Networking**، روی **Generate Domain** بزنید
5. (اختیاری) یک **Volume** به مسیر `/etc/sing-box` وصل کنید

## کانفیگ کلاینت

### برای sing-box (کلاینت)

```json
{
  "outbounds": [
    {
      "type": "tuic",
      "tag": "tuic-out",
      "server": "your-app.up.railway.app",
      "server_port": 443,
      "uuid": "YOUR_UUID",
      "password": "YOUR_PASSWORD",
      "congestion_control": "bbr",
      "udp_relay_mode": "native",
      "tls": {
        "enabled": true,
        "server_name": "www.microsoft.com",
        "alpn": ["h3"],
        "insecure": true
      }
    }
  ]
}



