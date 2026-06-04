#!/bin/bash

echo "Starting Clothing Shop POS System..."
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed!"
    echo ""
    echo "Please install Python 3 first:"
    echo "  Ubuntu/Debian: sudo apt update && sudo apt install python3 python3-pip python3-venv"
    echo "  Fedora/RHEL:   sudo dnf install python3 python3-pip"
    echo "  macOS:         brew install python3"
    echo ""
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ -f /etc/debian_version ]]; then
    OS="debian"
elif [[ -f /etc/redhat-release ]]; then
    OS="redhat"
else
    OS="linux"
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

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Creating one..."
    if ! python3 -m venv venv; then
        if [[ "$OS" == "debian" ]]; then
            echo "Installing python3-venv package..."
            sudo apt update && sudo apt install -y python3-venv
            python3 -m venv venv
        elif [[ "$OS" == "redhat" ]]; then
            echo "Installing python3-venv package..."
            sudo dnf install -y python3-venv || sudo dnf install -y python3-virtualenv
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
if [ ! -f "$PYTHON" ]; then
    echo "❌ Error: Virtual environment seems corrupted. Deleting and recreating..."

    rm -rf venv
    python3 -m venv venv

    echo "✓ Virtual environment recreated"
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
WORKERS="${GUNICORN_WORKERS:-4}"

# Create logs directory if it doesn't exist
mkdir -p logs

LOG_FILE="logs/app.log"

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

echo "  View logs: tail -f $LOG_FILE"