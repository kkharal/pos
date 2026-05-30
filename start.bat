@echo off
echo Starting Clothing Shop POS System...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed or not in PATH!
    echo.
    echo Please install Python 3.8 or higher from: https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo [OK] Python found:
python --version
echo.

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo [ERROR] Failed to create virtual environment!
        echo.
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created
)

REM Use virtual environment binaries directly
set PYTHON=venv\Scripts\python.exe
set PIP=venv\Scripts\pip.exe

REM Check if venv binaries exist
if not exist "%PYTHON%" (
    echo [ERROR] Virtual environment seems corrupted. Recreating...
    rmdir /s /q venv
    python -m venv venv
    echo [OK] Virtual environment recreated
)

REM Check if dependencies are installed
%PYTHON% -c "import flask" 2>nul
if errorlevel 1 (
    echo Installing dependencies...
    %PIP% install --upgrade pip
    %PIP% install -r requirements.txt
    if errorlevel 1 (
        echo [ERROR] Failed to install dependencies!
        echo Please check your internet connection and try again.
        pause
        exit /b 1
    )
    echo [OK] Dependencies installed
) else (
    echo [OK] Dependencies already installed
)

REM Initialize MySQL database schema (safe to run repeatedly)
echo Initializing MySQL database schema...
%PYTHON% database.py
if errorlevel 1 (
    echo [ERROR] Failed to initialize database!
    pause
    exit /b 1
)
echo [OK] Database initialized

REM Start the application
echo.
echo ==========================================
echo   Starting Clothing Shop POS System
echo ==========================================
echo.
echo   Access at: http://localhost:443
echo.
echo   Default Login:
echo     Username: admin
echo     Password: admin123
echo.
echo   Press Ctrl+C to stop the server
echo.
echo ==========================================
echo.

%PYTHON% app.py

pause
