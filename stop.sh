#!/bin/bash

PID_FILE="logs/app.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "❌ PID file not found. Is the application running?"
    exit 1
fi

PID=$(cat "$PID_FILE")

if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    rm -f "$PID_FILE"
    echo "✓ Application stopped (PID: $PID)"
else
    rm -f "$PID_FILE"
    echo "⚠ Process $PID not running. Cleaned up stale PID file."
fi

# Stop MySQL service
echo ""
read -p "Stop MySQL service too? [y/N]: " STOP_MYSQL
if [[ "$STOP_MYSQL" =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
        brew services stop mysql
    else
        sudo systemctl stop mysql 2>/dev/null || sudo systemctl stop mysqld 2>/dev/null || sudo service mysql stop 2>/dev/null
    fi
    echo "✓ MySQL service stopped"
else
    echo "  MySQL is still running."
fi
