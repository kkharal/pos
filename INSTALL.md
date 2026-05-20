# Installation Guide for New Machines

This guide helps you install the POS system on a fresh Linux/macOS machine.

## Step 1: Install Python 3

### Ubuntu/Debian (including WSL)

```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

### Fedora/RHEL/CentOS

```bash
sudo dnf install python3 python3-pip
```

### macOS

Install Homebrew first (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then install Python:
```bash
brew install python3
```

### Windows

1. Download Python from: https://www.python.org/downloads/
2. Run the installer
3. **IMPORTANT:** Check "Add Python to PATH" during installation
4. Click "Install Now"

## Step 2: Verify Python Installation

```bash
python3 --version
```

You should see something like: `Python 3.x.x`

## Step 3: Download/Clone the Project

If you have the project folder already, navigate to it:
```bash
cd /path/to/simple-web-app
```

If you're cloning from git:
```bash
git clone <repository-url>
cd simple-web-app
```

## Step 4: Run the Application

### On Linux/macOS:

```bash
# Make the start script executable
chmod +x start.sh

# Run the application
./start.sh
```

### On Windows:

```cmd
start.bat
```

## Step 5: Access the Application

Open your web browser and go to:
```
http://localhost:5000
```

**Default Login:**
- Username: `admin`
- Password: `admin123`

**⚠️ IMPORTANT:** Change the default password immediately after first login!

## What the Start Script Does

The `start.sh` (or `start.bat`) script automatically handles:

1. ✅ Checks if Python 3 is installed
2. ✅ Creates a virtual environment (isolated Python environment)
3. ✅ Installs all required packages (Flask, APScheduler, ReportLab, etc.)
4. ✅ Initializes the database
5. ✅ Starts the web application

**No manual steps needed!** Just run the script.

## Troubleshooting

### Error: "python3: command not found"

**Solution:** Python is not installed. Go back to Step 1.

### Error: "pip: command not found" or "python3-venv not found"

**Solution (Ubuntu/Debian):**
```bash
sudo apt install python3-pip python3-venv
```

**Solution (Fedora/RHEL):**
```bash
sudo dnf install python3-pip
```

### Error: "Permission denied" when running ./start.sh

**Solution:**
```bash
chmod +x start.sh
./start.sh
```

### Error: "Port 5000 is already in use"

**Solution:** Another application is using port 5000.

**Option 1 - Stop the other application:**
```bash
# Find what's using port 5000
lsof -ti:5000

# Kill it (macOS/Linux)
lsof -ti:5000 | xargs kill -9
```

**Option 2 - Change the port:**
Edit `app.py` and change the last line:
```python
app.run(debug=True, host='0.0.0.0', port=5001)  # Changed from 5000 to 5001
```

### Dependencies fail to install

**Solution 1 - Install build tools:**

Ubuntu/Debian:
```bash
sudo apt install build-essential python3-dev
```

Fedora/RHEL:
```bash
sudo dnf install gcc python3-devel
```

**Solution 2 - Check internet connection:**
Make sure you're connected to the internet and can access PyPI.

**Solution 3 - Update pip:**
```bash
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt
```

### Virtual environment corrupted

**Solution:**
```bash
# Delete the virtual environment
rm -rf venv

# Run start.sh again - it will recreate it
./start.sh
```

## Next Steps

After successful installation:

1. **Change default password:**
   - Login as admin
   - Click on your profile icon → Change Password

2. **Configure settings:**
   - Go to Settings
   - Set your shop name
   - Choose your currency
   - Configure session timeout

3. **Set up email alerts (optional):**
   - Go to Settings → Email Configuration
   - Enter your SMTP details
   - Go to Settings → Low Stock Alerts & Scheduler
   - Set threshold and schedule

4. **Add products:**
   - Go to Products
   - Click "Add New Product"
   - Fill in details and save

5. **Create users:**
   - Go to Users
   - Add users for your staff
   - Assign appropriate roles (Admin or User)

6. **Start selling:**
   - Go to Point of Sale
   - Search for products
   - Add to cart and complete sales

## Keeping the Application Running

### Run in background (Linux/macOS):

```bash
nohup ./venv/bin/python app.py > /tmp/pos.log 2>&1 &
```

To stop it:
```bash
pkill -f "python.*app.py"
```

### Run on system startup (systemd on Linux):

Create a systemd service file:
```bash
sudo nano /etc/systemd/system/pos.service
```

Add this content (replace paths with your actual paths):
```ini
[Unit]
Description=Clothing Shop POS System
After=network.target

[Service]
Type=simple
User=your-username
WorkingDirectory=/path/to/simple-web-app
ExecStart=/path/to/simple-web-app/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable pos.service
sudo systemctl start pos.service
```

Check status:
```bash
sudo systemctl status pos.service
```

## Getting Help

If you encounter issues not covered in this guide:

1. Check the main [README.md](README.md) for more details
2. Review the logs: `tail -50 /tmp/flask_output.log`
3. Create an issue in the repository with:
   - Your operating system
   - Python version (`python3 --version`)
   - Full error message
   - Steps you've tried

## Security Checklist

Before using in production:

- [ ] Changed default admin password
- [ ] Created individual user accounts for staff
- [ ] Configured session timeout appropriately
- [ ] Set up regular database backups
- [ ] Restricted network access (if needed)
- [ ] Configured firewall rules (if applicable)
- [ ] Using strong passwords for all accounts
