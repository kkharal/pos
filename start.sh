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

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "MySQL not found."

    if command -v brew &> /dev/null; then
        echo "Installing MySQL using Homebrew..."
        brew install mysql

        if [ $? -ne 0 ]; then
            echo "❌ Error: Failed to install MySQL!"
            exit 1
        fi

        echo "✓ MySQL installed successfully"
    else
        echo "❌ Error: Homebrew not found!"
        echo ""
        echo "Please install Homebrew first:"
        echo "  https://brew.sh"
        echo ""
        exit 1
    fi
else
    echo "✓ MySQL already installed"
fi

# Start MySQL service (macOS Homebrew)
if command -v brew &> /dev/null; then
    MYSQL_STATUS=$(brew services list | grep mysql | awk '{print $2}')

    if [ "$MYSQL_STATUS" != "started" ]; then
        echo "Starting MySQL service..."
        brew services start mysql

        # Wait until MySQL is actually accepting connections (up to 30s)
        echo "Waiting for MySQL to be ready..."

        for i in $(seq 1 30); do
            if mysqladmin ping -h 127.0.0.1 --silent 2>/dev/null; then
                break
            fi
            sleep 1
        done

        echo "✓ MySQL service started"
    else
        echo "✓ MySQL already running"
    fi
else
    echo "⚠ Homebrew not found — skipping MySQL auto-start. Ensure MySQL is running."
fi

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Creating one..."
    python3 -m venv venv

    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to create virtual environment!"
        echo ""
        echo "Please install python3-venv:"
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

# Create logs directory if it doesn't exist
mkdir -p logs

LOG_FILE="logs/app.log"

# Start the application in background
echo ""
echo "=========================================="
echo "  Starting Clothing Shop POS System"
echo "=========================================="
echo ""
echo "  🌐 Access at: http://localhost:5001"
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

nohup $PYTHON app.py >> "$LOG_FILE" 2>&1 &

echo $! > logs/app.pid

echo "✓ Application started in background (PID: $!)"
echo "  View logs: tail -f $LOG_FILE"