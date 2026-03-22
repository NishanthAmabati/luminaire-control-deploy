#!/usr/bin/env bash
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$BASE_DIR/compose.yaml" ]]; then
    echo "error: compose.yaml not found in $BASE_DIR" >&2
    exit 1
fi
sudo docker compose -f "$BASE_DIR/compose.yaml" down
