#!/bin/bash
set -e

echo "[warp] container starting..."

mkdir -p /var/lib/cloudflare-warp

if [ ! -c /dev/net/tun ]; then
  echo "[warp] ERROR: /dev/net/tun is missing"
  exit 1
fi

echo "[warp] starting warp-svc..."
warp-svc &
svc_pid=$!

sleep 8

echo "[warp] warp-cli version:"
warp-cli --version || true

echo "[warp] checking registration..."
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
  echo "[warp] first time register..."

  if warp-cli --accept-tos registration new; then
    echo "[warp] registration success via 'registration new'"
  else
    echo "[warp] 'registration new' failed, trying legacy 'register'..."
    warp-cli --accept-tos register
  fi
else
  echo "[warp] already registered"
fi

echo "[warp] current status:"
warp-cli --accept-tos status || true

wait $svc_pid