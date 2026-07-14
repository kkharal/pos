#!/bin/bash

set -euo pipefail

PID_FILE="logs/app.pid"
SERVICE_NAME="${SERVICE_NAME:-pos.service}"
STOP_MYSQL="${STOP_MYSQL:-false}"

usage() {
    echo "Usage: $0 [--stop-mysql] [--help]"
    echo "  --stop-mysql   Stop MySQL after stopping the application"
    echo "  --help        Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --stop-mysql)
            STOP_MYSQL="true"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files "$SERVICE_NAME" >/dev/null 2>&1; then
    if systemctl is-active "$SERVICE_NAME" >/dev/null 2>&1; then
        systemctl stop "$SERVICE_NAME" >/dev/null 2>&1 || true
        echo "✓ Stopped systemd service: $SERVICE_NAME"
    else
        echo "⚠ Service $SERVICE_NAME is not active."
    fi
fi

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE" 2>/dev/null || true)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null || true
    fi
    rm -f "$PID_FILE"
fi

if [[ "$STOP_MYSQL" =~ ^[Yy]([Ee][Ss])?$|^true$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
        brew services stop mysql
    else
        sudo systemctl stop mysql 2>/dev/null || sudo systemctl stop mysqld 2>/dev/null || sudo service mysql stop 2>/dev/null
    fi
    echo "✓ MySQL service stopped"
else
    echo "  MySQL left running."
fi
