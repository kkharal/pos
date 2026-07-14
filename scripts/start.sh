#!/bin/bash
# Resolve repo root regardless of where the script is called from
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
cd "$ROOT_DIR"

echo "Starting Clothing Shop POS System..."
echo ""

# ── Detect OS ────────────────────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/debian_version ]]; then
    OS="debian"
elif [[ -f /etc/redhat-release ]]; then
    OS="redhat"
else
    OS="linux"
fi

# ── Install Python 3 if missing ──────────────────────────────────────────────
if ! command -v python3 &> /dev/null; then
    echo "Python 3 not found. Installing..."
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install python3
        else
            echo "❌ Error: Homebrew not found. Install it first: https://brew.sh"
            exit 1
        fi
    elif [[ "$OS" == "debian" ]]; then
        sudo apt-get update -qq
        sudo apt-get install -y python3 python3-pip python3-venv python3-full
    elif [[ "$OS" == "redhat" ]]; then
        sudo dnf install -y python3 python3-pip
    else
        echo "❌ Error: Cannot auto-install Python 3 on this OS."
        echo "Please install Python 3 manually and rerun this script."
        exit 1
    fi

    if ! command -v python3 &> /dev/null; then
        echo "❌ Error: Python 3 installation failed."
        exit 1
    fi
fi

echo "✓ Python 3 found: $(python3 --version)"

# ── Ensure venv+ensurepip are available ──────────────────────────────────────
# On Ubuntu 24.04+ python3-pip/python3-venv may not be in the apt repo.
# Fall back to bootstrapping pip via get-pip.py + virtualenv.
_ensure_venv_tool() {
    # If we can already create a venv or virtualenv is available, nothing to do
    if python3 -c "import ensurepip" &>/dev/null 2>&1; then
        return 0
    fi
    if python3 -m virtualenv --version &>/dev/null 2>&1; then
        return 0
    fi

    if [[ "$OS" == "debian" ]]; then
        PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        MINOR="${PY_VER##*.}"
        echo "Installing Python venv support (python3.${MINOR}-venv / python3-full)..."
        sudo apt-get update -qq
        sudo apt-get install -y "python3.${MINOR}-venv" 2>/dev/null || \
            sudo apt-get install -y python3-full 2>/dev/null || true
    elif [[ "$OS" == "redhat" ]]; then
        sudo dnf install -y python3-venv 2>/dev/null || sudo dnf install -y python3-virtualenv || true
    fi

    # If ensurepip still missing, bootstrap pip + virtualenv via get-pip.py
    if ! python3 -c "import ensurepip" &>/dev/null 2>&1; then
        if ! python3 -m virtualenv --version &>/dev/null 2>&1; then
            echo "Bootstrapping pip via get-pip.py (apt packages unavailable)..."
            if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
                if [[ "$OS" == "debian" ]]; then sudo apt-get install -y curl; fi
            fi
            if command -v curl &>/dev/null; then
                curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
            else
                wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
            fi
            python3 /tmp/get-pip.py --break-system-packages --quiet
            python3 -m pip install --break-system-packages --quiet virtualenv
            rm -f /tmp/get-pip.py
        fi
        # Confirm virtualenv is now available
        if ! python3 -m virtualenv --version &>/dev/null 2>&1; then
            echo "❌ Error: Could not set up a Python venv tool. Please install python3-full manually."
            exit 1
        fi
        echo "✓ pip + virtualenv bootstrapped successfully"
    fi
}
_ensure_venv_tool

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "MySQL not found."

    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing MySQL using Homebrew..."
            brew install mysql
        else
            echo "❌ Error: Homebrew not found!"
            echo ""
            echo "Please install Homebrew first:"
            echo "  https://brew.sh"
            echo ""
            exit 1
        fi
    elif [[ "$OS" == "debian" ]]; then
        echo "Installing MySQL using apt..."
        sudo apt update && sudo apt install -y mysql-server mysql-client
    elif [[ "$OS" == "redhat" ]]; then
        echo "Installing MySQL using dnf..."
        sudo dnf install -y mysql-server mysql
    else
        echo "❌ Error: Could not detect package manager to install MySQL."
        echo ""
        echo "Please install MySQL manually:"
        echo "  Ubuntu/Debian: sudo apt install mysql-server mysql-client"
        echo "  Fedora/RHEL:   sudo dnf install mysql-server"
        echo "  macOS:         brew install mysql"
        echo ""
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to install MySQL!"
        exit 1
    fi

    echo "✓ MySQL installed successfully"
else
    echo "✓ MySQL already installed"
fi

# Start MySQL service
if [[ "$OS" == "macos" ]]; then
    if command -v brew &> /dev/null; then
        MYSQL_STATUS=$(brew services list | grep mysql | awk '{print $2}')

        if [ "$MYSQL_STATUS" != "started" ]; then
            echo "Starting MySQL service..."
            brew services start mysql
        else
            echo "✓ MySQL already running"
        fi
    fi
elif [[ "$OS" == "debian" || "$OS" == "redhat" || "$OS" == "linux" ]]; then
    if ! mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; then
        echo "Starting MySQL service..."
        sudo systemctl start mysql 2>/dev/null || sudo systemctl start mysqld 2>/dev/null || sudo service mysql start 2>/dev/null
    else
        echo "✓ MySQL already running"
    fi
fi

# Wait until MySQL is actually accepting connections (up to 30s)
echo "Waiting for MySQL to be ready..."
for i in $(seq 1 30); do
    if mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; then
        break
    fi
    sleep 1
done

if mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; then
    echo "✓ MySQL service started"
else
    echo "❌ Error: MySQL failed to start within 30 seconds"
    exit 1
fi

# Configure MySQL root user for TCP access (Ubuntu uses auth_socket by default)
if [[ "$OS" == "debian" || "$OS" == "redhat" || "$OS" == "linux" ]]; then
    # Check if root can connect via TCP without password
    if ! mysql -h 127.0.0.1 -u root -e "SELECT 1" &>/dev/null; then
        echo "Configuring MySQL root user for TCP access..."
        sudo mysql <<'SQL'
CREATE USER IF NOT EXISTS 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
ALTER USER 'root'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '';
FLUSH PRIVILEGES;
SQL
        if mysql -h 127.0.0.1 -u root -e "SELECT 1" &>/dev/null; then
            echo "✓ MySQL root configured for TCP access"
        else
            echo "⚠ Could not configure MySQL root user. You may need to set DB credentials in .env"
        fi
    fi
fi

# ── Provision the application DB user from .env ──────────────────────────────
# Read DB credentials (may not be exported yet if .env hasn't been sourced)
_DB_USER=$(grep -E '^DB_USER=' .env 2>/dev/null | cut -d= -f2- | tr -d '[:space:]')
_DB_PASS=$(grep -E '^DB_PASSWORD=' .env 2>/dev/null | cut -d= -f2- | tr -d '[:space:]')
_DB_NAME=$(grep -E '^DB_NAME=' .env 2>/dev/null | cut -d= -f2- | tr -d '[:space:]')
_DB_USER="${_DB_USER:-root}"
_DB_PASS="${_DB_PASS:-}"
_DB_NAME="${_DB_NAME:-pos_mysql_app}"

if [[ "$_DB_USER" != "root" ]]; then
    if ! sudo mysql -e "SELECT 1 FROM mysql.user WHERE User='${_DB_USER}'" 2>/dev/null | grep -q 1; then
        echo "Creating MySQL application user '${_DB_USER}'..."
        sudo mysql <<SQL
CREATE USER IF NOT EXISTS '${_DB_USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${_DB_PASS}';
CREATE USER IF NOT EXISTS '${_DB_USER}'@'127.0.0.1' IDENTIFIED WITH mysql_native_password BY '${_DB_PASS}';
CREATE DATABASE IF NOT EXISTS \`${_DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON \`${_DB_NAME}\`.* TO '${_DB_USER}'@'localhost';
GRANT ALL PRIVILEGES ON \`${_DB_NAME}\`.* TO '${_DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL
        if [ $? -eq 0 ]; then
            echo "✓ MySQL user '${_DB_USER}' created with access to '${_DB_NAME}'"
        else
            echo "❌ Error: Failed to create MySQL user '${_DB_USER}'. Check that root has the necessary privileges."
            exit 1
        fi
    else
        echo "✓ MySQL user '${_DB_USER}' already exists"
    fi
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Creating one..."
    if ! python3 -m venv venv 2>/dev/null; then
        # ensurepip not available — use virtualenv if present
        if python3 -m virtualenv --version &>/dev/null 2>&1; then
            echo "Using virtualenv to create environment..."
            python3 -m virtualenv venv
        else
            if [[ "$OS" == "debian" ]]; then
                echo "Installing python3-full / python3.X-venv package..."
                PY_VER=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
                MINOR="${PY_VER##*.}"
                sudo apt-get update -qq
                sudo apt-get install -y "python3.${MINOR}-venv" 2>/dev/null || \
                    sudo apt-get install -y python3-full
            elif [[ "$OS" == "redhat" ]]; then
                echo "Installing python3-venv package..."
                sudo dnf install -y python3-venv || sudo dnf install -y python3-virtualenv
            fi
            python3 -m venv venv
        fi
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to create virtual environment!"
        echo ""
        echo "Please install python3-venv manually and rerun the script:"
        echo "  Ubuntu/Debian: sudo apt install python3-venv"
        echo "  Fedora/RHEL:   sudo dnf install python3-venv"
        echo ""
        exit 1
    fi

    echo "✓ Virtual environment created"
fi

# Use virtual environment binaries directly
PYTHON="./venv/bin/python"
PIP="./venv/bin/pip"

# Check if venv binaries exist
if [ ! -x "$PYTHON" ]; then
    echo "❌ Error: Virtual environment seems corrupted. Deleting and recreating..."
    rm -rf venv
    if python3 -m virtualenv --version &>/dev/null 2>&1; then
        python3 -m virtualenv venv
    else
        python3 -m venv venv
    fi
fi

# Bootstrapping pip if needed
if [ ! -x "$PIP" ]; then
    echo "pip is missing from the virtual environment. Bootstrapping pip..."
    if ! $PYTHON -m ensurepip --upgrade >/dev/null 2>&1; then
        if [[ "$OS" == "debian" ]]; then
            sudo apt update && sudo apt install -y python3-pip python3.12-venv
        elif [[ "$OS" == "redhat" ]]; then
            sudo dnf install -y python3-pip
        fi
    fi

    if [ ! -x "$PIP" ]; then
        $PYTHON -m pip install --upgrade pip setuptools wheel >/dev/null 2>&1 || true
    fi

    if [ ! -x "$PIP" ]; then
        echo "Trying virtualenv fallback..."
        python3 -m pip install --user virtualenv >/dev/null 2>&1 || true
        python3 -m virtualenv --clear venv >/dev/null 2>&1 || true
        PYTHON="./venv/bin/python"
        PIP="./venv/bin/pip"
    fi
fi

if [ ! -x "$PIP" ]; then
    echo "❌ Error: Virtual environment pip is still unavailable."
    echo "Please install python3-venv and python3-pip and rerun the script."
    exit 1
fi

# Check if dependencies are installed
if ! $PYTHON -c "import flask" 2>/dev/null; then
    echo "Installing dependencies..."

    $PIP install --upgrade pip
    $PIP install -r requirements.txt

    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to install dependencies!"
        echo "Please check your internet connection and try again."
        exit 1
    fi

    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi

# Initialize MySQL database schema (safe to run repeatedly)
echo "Initializing MySQL database schema..."

$PYTHON database.py

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to initialize database!"
    exit 1
fi

echo "✓ Database initialized"

# ── Environment & Security Setup ─────────────────────────────────────────────

# Load .env file if present
if [ -f ".env" ]; then
    echo "✓ Loading .env file"
    set -a
    source .env
    set +a
else
    echo "⚠ No .env file found. Creating from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "  Please edit .env and set SECRET_KEY before running in production."
    fi
fi

# Ensure SECRET_KEY is set
if [ -z "$SECRET_KEY" ]; then
    echo ""
    echo "⚠ SECRET_KEY not set. Generating a secure one..."
    GENERATED_KEY=$($PYTHON -c "import secrets; print(secrets.token_hex(32))")
    if [ -f ".env" ]; then
        # Replace empty SECRET_KEY= line or append
        if grep -q "^SECRET_KEY=" .env; then
            sed -i.bak "s|^SECRET_KEY=.*|SECRET_KEY=${GENERATED_KEY}|" .env
            rm -f .env.bak
        else
            echo "SECRET_KEY=${GENERATED_KEY}" >> .env
        fi
    else
        echo "SECRET_KEY=${GENERATED_KEY}" > .env
    fi
    export SECRET_KEY="$GENERATED_KEY"
    echo "✓ SECRET_KEY generated and saved to .env"
fi

# Determine run mode
MODE="${RUN_MODE:-production}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-5000}"
WORKERS="${GUNICORN_WORKERS:-3}"
SERVICE_NAME="${SERVICE_NAME:-pos.service}"

# Create logs directory if it doesn't exist
mkdir -p logs

LOG_FILE="logs/app.log"

# Run a quick syntax smoke check before starting the server
if [ -x "./scripts/smoke_check.sh" ]; then
    echo "Running pre-start smoke check..."
    if ! ./scripts/smoke_check.sh; then
        echo "❌ Smoke check failed. Server startup aborted."
        echo "Fix the reported Python error(s), then rerun ./start.sh"
        exit 1
    fi
    echo "✓ Smoke check passed"
fi

# Start the application
echo ""
echo "=========================================="
echo "  Starting Clothing Shop POS System"
echo "=========================================="
echo ""

if [ "$MODE" = "development" ]; then
    echo "  ⚠ Mode: DEVELOPMENT (debug enabled)"
    echo "  🌐 Access at: http://${HOST}:${PORT}"
    echo ""
    echo "  Default Login:"
    echo "    Username: admin"
    echo "    Password: admin123"
    echo ""
    echo "  Logs: $LOG_FILE"
    echo "  Stop: kill \$(cat logs/app.pid)"
    echo ""
    echo "=========================================="
    echo ""

    export FLASK_DEBUG=1
    nohup $PYTHON app.py >> "$LOG_FILE" 2>&1 &
    echo $! > logs/app.pid
    echo "✓ Development server started (PID: $!)"
else
    echo "  🔒 Mode: PRODUCTION (gunicorn)"
    echo "  🌐 Listening on: http://${HOST}:${PORT}"
    echo "  👷 Workers: ${WORKERS}"
    echo ""
    echo "  ⚡ Use Nginx as reverse proxy for HTTPS on port 443"
    echo ""
    echo "  Default Login:"
    echo "    Username: admin"
    echo "    Password: admin123"
    echo ""
    echo "  Logs: $LOG_FILE"
    echo "  Stop: kill \$(cat logs/app.pid)"
    echo ""
    echo "=========================================="
    echo ""

    # Ensure gunicorn is installed
    if ! ./venv/bin/gunicorn --version &>/dev/null; then
        echo "Installing gunicorn..."
        $PIP install gunicorn
    fi

    # ── macOS: no systemd, just run gunicorn directly ─────────────────────
    if [[ "$OS" == "macos" ]]; then
        nohup ./venv/bin/gunicorn \
            --workers "$WORKERS" \
            --bind "${HOST}:${PORT}" \
            --access-logfile logs/access.log \
            --error-logfile logs/error.log \
            --timeout 120 \
            app:app >> "$LOG_FILE" 2>&1 &
        echo $! > logs/app.pid
        echo "✓ Gunicorn started (PID: $!)"
        echo "  Stop: kill \$(cat logs/app.pid)"

    # ── Linux: create/update systemd service ─────────────────────────────
    else
        APP_DIR="$(pwd)"
        APP_USER="$(whoami)"
        SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"

        EXPECTED_EXEC="${APP_DIR}/venv/bin/gunicorn"
        CURRENT_EXEC=$(grep "^ExecStart=" "$SERVICE_FILE" 2>/dev/null | cut -d= -f2- | awk '{print $1}')

        if [ ! -f "$SERVICE_FILE" ] || [ "$CURRENT_EXEC" != "$EXPECTED_EXEC" ]; then
            echo "Creating systemd service: $SERVICE_FILE"
            sudo tee "$SERVICE_FILE" > /dev/null <<UNIT
[Unit]
Description=Clothing Shop POS Gunicorn Service
After=network.target mysql.service

[Service]
Type=simple
User=${APP_USER}
WorkingDirectory=${APP_DIR}
Environment=PYTHONUNBUFFERED=1
EnvironmentFile=-${APP_DIR}/.env
ExecStart=${APP_DIR}/venv/bin/gunicorn --workers ${WORKERS} --bind ${HOST}:${PORT} app:app --access-logfile ${APP_DIR}/logs/access.log --error-logfile ${APP_DIR}/logs/error.log --timeout 120
Restart=always
RestartSec=5
StandardOutput=append:${APP_DIR}/logs/app.log
StandardError=append:${APP_DIR}/logs/error.log
KillMode=mixed
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
UNIT
            sudo systemctl daemon-reload
            sudo systemctl enable "$SERVICE_NAME"
            echo "✓ Systemd service created and enabled (auto-starts on boot)"
        fi

        sudo systemctl restart "$SERVICE_NAME"
        sleep 1

        if systemctl is-active --quiet "$SERVICE_NAME"; then
            PID=$(systemctl show -p MainPID --value "$SERVICE_NAME" 2>/dev/null || echo "?")
            echo $PID > logs/app.pid 2>/dev/null || true
            echo "✓ Service started via systemd (PID: $PID)"
        else
            echo "❌ Service failed to start. Check logs:"
            sudo journalctl -u "$SERVICE_NAME" --no-pager -n 20
            exit 1
        fi
    fi
fi

echo "  View logs: tail -f $LOG_FILE"