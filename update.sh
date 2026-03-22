#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "pulling latest images..."
sudo docker compose -f "$BASE_DIR/compose.yaml" pull

echo "applying updates and removing orphans..."
sudo docker compose -f "$BASE_DIR/compose.yaml" up -d --remove-orphans

echo "cleaning up old image layers..."
sudo docker image prune -f

echo "update complete."
