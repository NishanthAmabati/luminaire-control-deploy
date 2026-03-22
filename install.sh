#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

echo "[1/5] Uupdating package index..."
sudo apt update

echo "[2/5] installing required packages..."
sudo apt install -y ca-certificates curl gnupg

echo "[3/5] installing Docker ..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
  sudo sh /tmp/get-docker.sh
fi

echo "[4/5] enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[5/5] starting application..."
mkdir -p ~/.local/share/icons
cp SSS.png "/home/$USER/.local/share/icons/SSS.png"
cp luminaire-control.desktop "/home/$USER/Desktop/luminaire-control.desktop"
mkdir -p "$BASE_DIR/scenes"
sudo docker compose -f "$BASE_DIR/compose.yaml" up -d --remove-orphans

echo "Done."
