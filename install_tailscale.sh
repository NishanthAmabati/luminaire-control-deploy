#!/usr/bin/env bash
set -euo pipefail

echo "[1/7] updating package index..."
sudo apt update

echo "[2/7] installing OpenSSH server..."
sudo apt install -y openssh-server curl ca-certificates

echo "[3/7] enabling and starting SSH service..."
sudo systemctl enable ssh
sudo systemctl restart ssh

echo "[4/7] creating/updating 'tails' user..."
if id tails >/dev/null 2>&1; then
  echo "tails user already exists. Updating password..."
else
  sudo useradd -m -s /bin/bash tails
  echo "User 'tails' created."
fi

DEFAULT_PASSWORD="tails@rpi"
PASSWORD_INPUT="${TAILSCALE_USER_PASSWORD:-}"

if [ -z "$PASSWORD_INPUT" ]; then
  echo "Enter password for user 'tails' (press Enter to use default: $DEFAULT_PASSWORD)"
  read -r -s PASSWORD_INPUT
  echo
fi

TAILSCALE_PASSWORD="${PASSWORD_INPUT:-$DEFAULT_PASSWORD}"
echo "tails:$TAILSCALE_PASSWORD" | sudo chpasswd

echo "[5/7] adding tails user to sudo group..."
sudo usermod -aG sudo tails

echo "[6/7] installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "[7/7] bringing Tailscale up..."
echo "A browser-based sign-in step may appear the first time."
sudo tailscale up --ssh || sudo tailscale up

echo "Done."
echo "SSH service is enabled on this Raspberry Pi."
echo "User: tails"
echo "Password: custom value you entered (default was: $DEFAULT_PASSWORD)"
