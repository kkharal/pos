#!/bin/bash

echo "Starting Clothing Shop POS System..."
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed!"
    echo ""
    echo "Please install Python 3 first:"
    echo "  Ubuntu/Debian:      sudo apt update && sudo apt install python3 python3-pip python3-venv"
    echo "  Amazon Linux 2023:  sudo dnf install python3 python3-pip"
    echo "  Amazon Linux 2:     sudo yum install python3 python3-pip"
    echo "  Fedora/RHEL:        sudo dnf install python3 python3-pip"
    echo "  macOS:              brew install python3"
    echo ""
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/debian_version ]]; then
    OS="debian"
elif grep -qi 'Amazon Linux' /etc/os-release 2>/dev/null; then
    OS="amazon"
    if grep -q 'VERSION_ID="2023"' /etc/os-release 2>/dev/null; then
        AMAZON_PKG="dnf"
        AMAZON_MYSQL_RPM="https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm"
    else
        AMAZON_PKG="yum"
        AMAZON_MYSQL_RPM="https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm"
    fi
elif [[ -f /etc/redhat-release ]]; then
    OS="redhat"
else
    OS="linux"
fi

# Ensure Python venv support is installed on Debian/Ubuntu
if [[ "$OS" == "debian" ]]; then
    if ! dpkg -s python3-venv python3-pip >/dev/null 2>&1; then
        echo "Installing python3-venv and python3-pip..."
        sudo apt update && sudo apt install -y python3-venv python3-pip python3.12-venv
        if [ $? -ne 0 ]; then
            echo "❌ Error: Failed to install python3-venv/python3-pip."
            echo "Please install them manually: sudo apt install python3-venv python3-pip"
            exit 1
        fi
    fi
fi

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
    elif [[ "$OS" == "amazon" ]]; then
        echo "Installing MySQL Community Edition on Amazon Linux..."
        sudo $AMAZON_PKG install -y "$AMAZON_MYSQL_RPM"
        # Import the current MySQL GPG key (the bundled 2022 key often mismatches packages)
        sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 2>/dev/null || true
        sudo $AMAZON_PKG install -y --nogpgcheck mysql-community-server
    elif [[ "$OS" == "redhat" ]]; then
        echo "Installing MySQL using dnf..."
        sudo dnf install -y mysql-server mysql
    else
        echo "❌ Error: Could not detect package manager to install MySQL."
        echo ""
        echo "Please install MySQL manually:"
        echo "  Ubuntu/Debian:      sudo apt install mysql-server mysql-client"
        echo "  Amazon Linux 2023:  sudo dnf install -y https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm && sudo dnf install -y mysql-community-server"
        echo "  Amazon Linux 2:     sudo yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm && sudo yum install -y mysql-community-server"
        echo "  Fedora/RHEL:        sudo dnf install mysql-server"
        echo "  macOS:              brew install mysql"
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
elif [[ "$OS" == "debian" || "$OS" == "redhat" || "$OS" == "amazon" || "$OS" == "linux" ]]; then
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

# Amazon Linux: MySQL starts with a generated temporary root password
if [[ "$OS" == "amazon" ]]; then
    if ! mysql -h 127.0.0.1 -u root -e "SELECT 1" &>/dev/null; then
        echo "Configuring MySQL root user on Amazon Linux..."
        TEMP_PW=$(sudo grep 'temporary password' /var/log/mysqld.log 2>/dev/null | tail -1 | awk '{print $NF}')
        if [ -n "$TEMP_PW" ]; then
            mysql -h 127.0.0.1 -u root --password="$TEMP_PW" --connect-expired-password \
                -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;" 2>/dev/null
            if mysql -h 127.0.0.1 -u root -e "SELECT 1" &>/dev/null; then
                echo "✓ MySQL root configured (temporary password cleared)"
            else
                echo "⚠ Could not auto-clear temp password. Add this to your .env:"
                echo "  DB_PASSWORD=$TEMP_PW"
            fi
        else
            echo "⚠ No temporary password found in /var/log/mysqld.log. Set DB credentials in .env if needed."
        fi
    fi
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Creating one..."
    if ! python3 -m venv venv; then
        if [[ "$OS" == "debian" ]]; then
            echo "Installing python3-venv package..."
            sudo apt update && sudo apt install -y python3-venv python3.12-venv
        elif [[ "$OS" == "amazon" ]]; then
            # venv is bundled with python3 on Amazon Linux; reinstall python3 if broken
            sudo $AMAZON_PKG install -y python3
        elif [[ "$OS" == "redhat" ]]; then
            echo "Installing python3-venv package..."
            sudo dnf install -y python3-venv || sudo dnf install -y python3-virtualenv
        fi
        python3 -m venv venv
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to create virtual environment!"
        echo ""
        echo "Please install python3-venv manually and rerun the script:"
        echo "  Ubuntu/Debian:  sudo apt install python3-venv"
        echo "  Amazon Linux:   sudo dnf install python3  (venv is bundled)"
        echo "  Fedora/RHEL:    sudo dnf install python3-venv"
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
    python3 -m venv venv
fi

# Bootstrapping pip if needed
if [ ! -x "$PIP" ]; then
    echo "pip is missing from the virtual environment. Bootstrapping pip..."
    if ! $PYTHON -m ensurepip --upgrade >/dev/null 2>&1; then
        if [[ "$OS" == "debian" ]]; then
            sudo apt update && sudo apt install -y python3-pip python3.12-venv
        elif [[ "$OS" == "amazon" ]]; then
            sudo $AMAZON_PKG install -y python3-pip
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

    if systemctl list-unit-files "$SERVICE_NAME" >/dev/null 2>&1; then
        echo "  🔄 Using systemd service: $SERVICE_NAME"
        systemctl daemon-reload >/dev/null 2>&1 || true
        systemctl enable "$SERVICE_NAME" >/dev/null 2>&1 || true
        systemctl restart "$SERVICE_NAME" >/dev/null 2>&1 || true
        echo "✓ Service restarted (systemd)"
    else
        nohup ./venv/bin/gunicorn \
            --workers "$WORKERS" \
            --bind "${HOST}:${PORT}" \
            --access-logfile logs/access.log \
            --error-logfile logs/error.log \
            --timeout 120 \
            app:app >> "$LOG_FILE" 2>&1 &
        echo $! > logs/app.pid
        echo "✓ Gunicorn started (PID: $!)"
    fi
fi

echo "  View logs: tail -f $LOG_FILE"