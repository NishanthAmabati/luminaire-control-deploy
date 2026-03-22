#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$BASE_DIR/scenes"

echo "starting services for luminaire control..."
sudo docker compose -f "$BASE_DIR/compose.yaml" up -d
echo "services started sucessfuly."
