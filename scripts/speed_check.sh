#!/bin/bash

set -euo pipefail

APP_URL="${APP_URL:-http://127.0.0.1:5000/}"
PUBLIC_URL="${PUBLIC_URL:-http://127.0.0.1/}"
REQUESTS="${REQUESTS:-3}"

if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required but not installed." >&2
    exit 1
fi

measure_url() {
    local label="$1"
    local url="$2"
    local total=0
    local status=""

    echo "[$label] $url"
    for i in $(seq 1 "$REQUESTS"); do
        status=$(curl -o /dev/null -s -w '%{http_code}' "$url")
        total=$(curl -o /dev/null -s -w '%{time_total}' "$url")
        printf '  request %s -> status=%s time_total=%.6fs\n' "$i" "$status" "$total"
    done
    echo
}

measure_url "app" "$APP_URL"
measure_url "nginx" "$PUBLIC_URL"
