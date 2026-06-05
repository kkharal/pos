# Clothing Shop POS System

A full-featured Point of Sale (POS) web application for managing one or multiple retail and wholesale shops with comprehensive inventory management, sales tracking, profit analysis, expense management, wholesale customer credit management, and automated alerts.

## Key Features

- ✅ **Multi-shop / multi-tenant** architecture — full data isolation per shop
- ✅ **Four-tier role system** — Super Admin, Shop Owner, Admin, Sales Staff
- ✅ **Multi-user with role-based access** (Super Admin, Shop Owner, Admin & Sales Staff)
- ✅ **Profit tracking** (cost vs. sell price)
- ✅ **Automated email alerts** for low stock with **configurable schedule**
- ✅ **Analytics reports** (Shopify-style panels: Overview, Sales, Inventory, Customers, Finance)
- ✅ **Orders page** (operational ledger: search, filter, view, print, refund — no analytics)
- ✅ **Sales filters** (date range, search, staff, payment method, customer, status pills)
- ✅ **Discount management** at point of sale
- ✅ **Receipt printing** with custom branding
- ✅ **Session timeout** for security
- ✅ **Per-shop name, icon & currency**
- ✅ **Shopify-style dashboard** with focused KPIs, trend chart, and activity feed
- ✅ **Background scheduler** for automated tasks
- ✅ **Advanced POS** with category tabs, held carts, refunds, keyboard shortcuts
- ✅ **Product management** with master-detail layout, variant grouping, and price overrides
- ✅ **CSV import/export** for products
- ✅ **Audit log** tracking all product changes
- ✅ **Per-product reorder levels** with stock movement charts
- ✅ **Supplier management** with contact details and order tracking
- ✅ **Purchase orders** with partial receiving and auto stock updates
- ✅ **Wholesale customer management** with credit limits and balance tracking
- ✅ **Credit & partial payment** support at POS with invoice tracking
- ✅ **Cash flow tracking** dashboard and reports with aging analysis
- ✅ **Receivables reporting** with PDF/Excel export
- ✅ **Expense management** with categories, recurring expenses, and receipt tracking
- ✅ **Profit & Loss report** with net profit, gross margin, and expense breakdown

## Tech Stack

- **Backend**: Python 3.8+ with Flask 3.0.0
- **Database**: MySQL 9.x (via `mysql-connector-python`) — with full multi-shop/multi-tenant support
- **Frontend**: HTML, CSS, JavaScript, Chart.js
- **Reports**: ReportLab (PDF), OpenPyXL (Excel)
- **Alerts**: SMTP email integration with APScheduler for automation
- **Scheduler**: APScheduler 3.10.4 for background tasks

## Features

### 🔐 User Authentication & Roles

The system has **four roles**, each with distinct permissions:

| Role | Access |
|------|--------|
| **Super Admin** | Manages all shops, creates/switches between shops, sees cross-shop reports, manages backup & restore. No shop assignment — operates across all shops or switches into a specific one. |
| **Shop Owner** | Admin-level access across multiple assigned shops. Can switch between assigned shops, manage products, stock, settings, and create admin/sales staff users. Cannot create or delete shops. |
| **Admin** | Full access within their assigned shop — products, sales, reports, suppliers, customers, users, settings. Can see cost prices and profit margins. |
| **User (Sales Staff)** | Access to POS only within their assigned shop. Cannot see cost prices or profits. |

- **Login System**: Secure authentication with role-based permissions
- **Session Timeout**: Automatic logout after configurable inactivity period (default: 30 minutes)
- **Password Management**: Self-service password change for all users
- **Shop switcher**: Super Admin and Shop Owner see a dropdown in the topbar to switch between shops (Super Admin: all shops; Shop Owner: assigned shops only)

### 🏪 Multi-Shop Management (Super Admin Only)
- **Create & manage shops**: Add shops with name, icon (emoji picker), currency, low stock threshold, address, and phone
- **Shop switcher**: Dropdown in the topbar — switch to a specific shop or "All Shops" mode for cross-shop reporting
- **Shop Owner role**: Assign multiple shops to a Shop Owner during user creation; they get admin-level access scoped to those shops
- **Data isolation**: Every table is scoped by `shop_id` — products, sales, customers, suppliers, and all history are fully isolated per shop
- **Per-shop branding**: Each shop has its own icon (shown in the sidebar), name, and currency symbol
- **SKU uniqueness per shop**: Same SKU can exist in multiple shops independently
- **User assignment**: Each admin and sales-staff user belongs to exactly one shop; Shop Owners can be assigned multiple shops
- **Backup & restore**: Database backup/restore is restricted to Super Admin only


- **Cost Price vs Sell Price**: Track buying and selling prices separately
- **Profit Margins**: Automatic calculation of profit per product and per sale
- **Profit Dashboard**: Real-time profit metrics visible to admins only
- **Sales Attribution**: Track which user made each sale

### 📦 Product Management (Admin Only)
- **Master-detail layout**: Clean product list with side drawer for details
- **Product grouping**: Variants (same name, different size/color) are grouped into a single row
- **5-column product list**: Product, Variants count, Stock, Price, Status
- **Side drawer**: Click a product to open a detail panel showing:
  - Summary stats (Total Stock, Sell Price, Profit/Unit)
  - Variant detail panel (SKU, Stock, Price with override badge)
  - Variants table with size/color/stock breakdown
- **Product-level editing**: "Edit Product" changes name, category, cost, price, and description across ALL variants at once
- **Variant-level actions**: Click a variant row to select it, then use Adjust Stock, History, or Delete for that specific variant
- **Price override system**: Set custom price per variant (e.g., XXL costs more) — group edits preserve overrides
  - "Override Price" button in variant detail panel
  - "Reset to Product Price" to revert to group default
  - Yellow "Override" badge shows which variants have custom pricing
- **Variant creation**: Bulk-create variants by selecting sizes and colors (creates all combinations)
- **Auto-generated SKU**: Leave blank to auto-generate (e.g., SHR-001)
- **CSV Export**: Download all products as a CSV file
- **CSV Import**: Upload a CSV to bulk-add or update products (matches by SKU)
- **Duplicate product**: Clone a product with one click (creates copy with 0 stock)
- **Per-product reorder level**: Set custom low stock threshold per variant (overrides global default)
- **Audit log**: Track who changed what, when — see old vs new values
- **Search**: Search by name, SKU, size, color, or category
- **Stock status dots**: Green (in stock), Orange (low/some out), Red (all out of stock)
- **Summary cards**: Products count, Units in Stock, Low Stock alerts
- **Stock history**: View import/export history per variant with timestamps
- **Custom Categories**: Create your own product categories

### 📊 Inventory Control
- Import and export stock with history tracking
- **Automatic Email Alerts**: Scheduled low stock notifications with **configurable check times** (admin sets custom schedule)
- **Manual Check**: Trigger low stock check anytime from Settings
- **Configurable Thresholds**: Set global low stock threshold (products inherit this value)
- Complete stock history with user attribution
- **Inventory Reports**: Comprehensive stock movement reports with PDF/Excel export

### 📦 Suppliers & Purchase Orders (Admin Only)
- **Supplier Management**: Add, edit, delete suppliers with contact details (name, email, phone, address, notes)
- **Supplier Search**: Real-time search across supplier name, contact, email, and phone
- **Create Purchase Orders**: Select supplier → add products with quantity and unit cost → submit
- **Auto-fill Cost**: Product cost price auto-populates when adding items to a PO
- **Receive Stock**: Full or partial receiving with quantity tracking per item
- **Partial Receiving**: Receive part of an order now, come back later for the rest (ordered → partial → received)
- **Auto Stock Update**: Receiving a PO automatically increases product inventory and logs to stock history
- **Cost Price Tracking**: Receiving uses **weighted average cost** — `(old_qty × old_cost + new_qty × new_cost) / total_qty` — for accurate profit tracking
- **Quick PO from Supplier**: One-click "+ PO" button on each supplier row
- **PO Status Tracking**: Visual badges for Ordered (blue), Partial (orange), Received (green)
- **Status Filtering**: Filter purchase orders by status
- **PO Detail View**: See ordered vs received quantities with completion percentages
- **Delete Protection**: Cannot delete suppliers with existing purchase orders, or received POs

### � Wholesale Customer Management (Admin Only)
- **Customer CRUD**: Add, edit, delete wholesale customers with name, phone, email, address
- **Credit limits**: Set credit limit per customer with balance tracking
- **Customer search**: Real-time search by name, phone, or email
- **Customer ledger**: View all invoices and payment history per customer
- **Record payments**: Accept payments against outstanding invoices (auto-applies to oldest first)
- **Aging report**: View overdue receivables broken down by 0-30, 31-60, 61-90, 90+ days
- **Summary cards**: Total customers, total credit given, total outstanding, customers with balance

### � Expense Management (Admin Only)
- **Expense CRUD**: Add, edit, delete expenses with amount, date, category, description, payment method, and receipt reference
- **Expense categories**: Pre-seeded categories (Rent, Utilities, Salaries, Transport, Supplies, Marketing, Maintenance, Miscellaneous) with custom icons
- **Custom categories**: Create, edit, delete your own expense categories
- **Recurring expenses**: Set up auto-recurring expenses (daily, weekly, monthly, yearly) with next-due-date tracking
- **Recurring auto-creation**: Background scheduler automatically creates expense entries when recurring expenses are due
- **Manual trigger**: Process recurring expenses on-demand from Settings
- **Expense filters**: Filter by category, date range, or search by description/receipt reference
- **Summary cards**: Today's total, this month's total, recurring monthly commitment, top category
- **Multi-shop isolation**: All expenses scoped per shop

### 📋 Profit & Loss Report (Admin Only)
- **Full P&L statement**: Revenue, refunds, net revenue, COGS, gross profit, operating expenses, net profit
- **Gross & net margins**: Percentage calculations for both gross and net profit
- **Expense breakdown**: Per-category expense table with percentage bars
- **Period comparison**: Current vs previous period with % change indicators
- **Daily/Monthly breakdown**: Detailed P&L table auto-switching based on date range length
- **Profit trend chart**: Line chart showing revenue, gross profit, expenses, and net profit over time
- **Expense pie chart**: Doughnut chart of expense distribution by category
- **P&L waterfall chart**: Visual bar chart showing the flow from revenue to net profit
- **Quick date ranges**: This Month, This Quarter, This Year, Last Month, Last Quarter
- **PDF/Excel export**: Download the full P&L statement in either format

### �🛒 Point of Sale (All Users)
- **Customer type toggle**: Walk-in (cash only) or Wholesale (credit/partial)
- **Searchable customer selector**: Autocomplete search for wholesale customers by name, phone, or email
- **Credit info display**: Shows customer credit limit, current balance, and available credit on selection
- **Payment methods**: Cash, Card, Transfer for walk-in; plus On Credit and Partial Payment for wholesale
- **Due date field**: Set payment due date for credit/partial sales
- **Credit limit validation**: Prevents exceeding customer's available credit
- **Invoice auto-creation**: Credit/partial sales automatically create invoices and update customer balance
- **Receipt shows credit info**: Amount paid, balance due, and due date displayed on credit sale receipts
- **Category filter tabs** with product counts and dedicated "Out of Stock" tab
- **Product search** by name, SKU, or category with keyboard shortcut (`/`)
- Cart management with **inline quantity input**, Discount, and Remove buttons per item
- **Cart count badge** on the cart header
- **Cart-level discount**: Apply percentage or fixed amount discount to entire cart
- **Payment modal**: Choose Cash, Card, or Transfer with quick cash buttons and change calculator
- **Customer name** field on transactions
- **Hold/resume cart**: Save cart to localStorage and resume later
- **Cart persistence**: Cart survives page refresh
- **Refund/return flow**: Look up sale by ID, see remaining quantities, process partial refunds
- **Reprint last receipt**: Reprint the most recent transaction receipt
- **Low stock warning**: Alert before checkout if items have low stock
- **Keyboard shortcuts**: `/` to focus search, `Escape` to close modals, `Enter` to confirm sale
- **Receipt generation** with payment method, amount received, change, customer name, shop branding
- Out-of-stock products greyed out with badge in a separate tab
- Automatic stock deduction on sale
- Sales staff cannot see cost prices

### � Orders (Operational Ledger)
- **Transactions Table**:
  - Invoice numbers (`INV-123`) with blue clickable links
  - Filter by date range (Today, Yesterday, This Week, This Month, Custom)
  - Search by invoice #, product name, or customer name
  - Filter by staff member, payment method, status
  - Status pill badges: Completed, Unpaid, Partially Paid, Refunded, Partial Refund
  - Day-grouped rows with daily subtotals
  - Inline actions: Print (🖨) and View Refunds (↩) per row
  - Click row to open detail drawer
- **Summary Tab** (light KPIs only):
  - Transaction count, Revenue, Avg Order, Discounts, Refunds, Outstanding
  - Payment methods breakdown (Cash, Card, Transfer, Credit, Partial)
  - ❌ No charts, no profit, no analytics (belongs in Reports)
- **Detail Drawer**: Invoice #, customer, payment, items table, totals, Print/Refund actions
- **Export CSV**: Download filtered sales data
- **URL state persistence**: Filters, tab, and status survive page refresh

### 📊 Reports & Analytics (Shopify-style Panels)
- **Two-panel layout**: Left nav (5 panels) + focused content area
- **Overview Panel** (auto-loads this month):
  - Revenue, Profit, Orders, Avg Order KPI cards with trend indicators
  - Revenue trend chart (line)
  - Top 5 products list
- **Sales Panel**: Revenue trend, transactions trend, hourly breakdown, discount/refund summaries
- **Inventory Panel**: Stock levels, movements, slow movers, reorder alerts
- **Customers Panel**: Top customers, repeat rate, lifetime value
- **Finance Panel**: P&L statement, cash flow, expense breakdown, margins
- **Per-panel features**:
  - Own date bar with quick-chips (Today, Week, Month, Quarter, Year)
  - Export dropdown (PDF/Excel)
  - Period comparison with % change indicators
- **Advanced Analytics**:
  - Staff performance tables
  - Revenue by category
  - Profit margin trends
  - Receivables aging report
  - Cash flow trend charts
- **Shopify-style Dashboard** (focused signals, not full reports):
  - 6 KPI cards with vs-yesterday change indicators
  - 7-day sales trend chart (clean line)
  - Top products list (simple name + sold count)
  - Recent activity feed (last 8 transactions)
  - Alert banner for low stock (dismissible)
  - Quick action buttons (New Sale, Add Product, Reports, Orders)
- **Shopify-style UI/UX** (consistent across all pages):
  - **Design system**: `#f8fafc` backgrounds, 12px radius cards, `#e2e8f0` borders, `#3b82f6` primary blue
  - **Left sidebar navigation** with collapsible icon-only mode and grouped sections
  - **Orders page**: Clean table with INV-# links, pill badges, inline print/refund actions, slide-out drawer
  - **Reports page**: Two-panel layout (left nav + focused content panels), auto-loading overview
  - **Settings page**: Categorized navigation (Shop, Inventory, Notifications, Security, Backup)
  - **Dashboard**: Signal-focused with KPI cards, trend chart, activity feed
  - Sticky topbar with shop switcher, user dropdown
  - Toast notifications, loading overlays, mobile-responsive sidebar
  - Smooth animations and transitions throughout
  - **Clean separation**: Orders = operations (DO), Reports = analytics (UNDERSTAND)

## Installation

### 🚀 Quick Start (Recommended)

**Prerequisites:**
- Python 3.8 or higher
- MySQL 8.x or 9.x server

> **macOS users** — MySQL is not installed by default. See [MySQL Setup](#mysql-setup) below.

**For macOS/Linux:**

```bash
# Make the script executable (first time only)
chmod +x start.sh

# Run the application
./start.sh
```

**For Windows:**

```cmd
start.bat
```

**If you get "python/pip not found" errors:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install python3 python3-pip python3-venv

# Fedora/RHEL
sudo dnf install python3 python3-pip

# macOS (requires Homebrew)
brew install python3
```

The start script will automatically:
- ✓ Check Python installation
- ✓ Create virtual environment
- ✓ Install all dependencies (including MySQL drivers)
- ✓ Initialize MySQL database
- ✓ Generate SECRET_KEY (if not set)
- ✓ Start the application with Gunicorn (production) or Flask (development)

Then open your browser to: **http://localhost:5000**

> **Production deployment?** See [Production Deployment](#-production-deployment-https-with-nginx) for HTTPS setup with Nginx.

**Default Login Credentials:**

| Role | Username | Password | Notes |
|------|----------|----------|-------|
| Super Admin | `superadmin` | `superadmin123` | Manages all shops |
| Admin | `admin` | `admin123` | Assigned to default shop |

**⚠️ IMPORTANT**: Change all default passwords immediately after first login!

---

### Manual Installation (All Platforms)

#### Prerequisites

**Install Python 3 (3.8 or higher) and required packages:**

- **Ubuntu/Debian:**
  ```bash
  sudo apt update
  sudo apt install python3 python3-pip python3-venv
  ```

- **Fedora/RHEL/CentOS:**
  ```bash
  sudo dnf install python3 python3-pip
  ```

- **macOS:**
  ```bash
  brew install python3
  ```

- **Windows:**
  - Download from [python.org](https://www.python.org/downloads/)
  - Make sure to check "Add Python to PATH" during installation

#### Installation Steps

1. **Create a virtual environment**:
  ```bash
  python3 -m venv venv
  ```

2. **Activate the virtual environment**:
  - On macOS/Linux:
    ```bash
    source venv/bin/activate
    ```
  - On Windows:
    ```bash
    venv\Scripts\activate
    ```

3. **Install dependencies**:
  ```bash
  pip install -r requirements.txt
  ```

  This will install:
  - Flask 3.0.0 - Web framework
  - Flask-CORS 4.0.0 - Cross-origin resource sharing
  - ReportLab 4.0.7 - PDF generation
  - OpenPyXL 3.1.2 - Excel file generation
  - APScheduler 3.10.4 - Background task scheduling
  - mysql-connector-python 8.2.0 - MySQL driver
  - PyMySQL 1.1.0 - MySQL compatibility layer

4. **Configure MySQL credentials** via environment variables:
  ```bash
  export DB_HOST=localhost
  export DB_USER=root
  export DB_PASSWORD=''          # Your MySQL root password
  export DB_NAME=pos_mysql_app
  export DB_PORT=3306
  ```
  Or create a `.env` file in the project root with the same keys (loaded automatically on startup).

5. **Create the MySQL database**:
  ```bash
  mysql -u root -p -e "CREATE DATABASE pos_mysql_app CHARACTER SET utf8mb4;"
  ```

6. **Initialize the database schema**:
  ```bash
  ./venv/bin/python database.py
  ```

7. **Run the application**:
  ```bash
  python app.py
  ```

8. **Open your browser** and go to:
  ```
  http://localhost:443
  ```

**Note**: Make sure to activate the virtual environment (step 3) each time you want to run the application.

---

### MySQL Setup

#### macOS (Homebrew)
```bash
# Install MySQL
brew install mysql

# Start MySQL service (auto-starts on login)
brew services start mysql

# Secure the installation (optional but recommended)
mysql_secure_installation

# Connect to MySQL
mysql -u root
```

#### Ubuntu / Debian
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
mysql -u root -p
```

#### Windows
1. Download MySQL Installer from [mysql.com/downloads](https://dev.mysql.com/downloads/installer/)
2. Run installer and choose **MySQL Server** + **MySQL Shell**
3. Set a root password during setup
4. MySQL service starts automatically

---

### Changing the MySQL Server Endpoint

By default the app connects to MySQL on `localhost` using the `root` account with no password.  
To point the app at a **remote MySQL server** (or change any credential), set environment variables **before** starting the app:

#### macOS / Linux
```bash
export DB_HOST=myserver.example.com
export DB_PORT=3306
export DB_USER=posuser
export DB_PASSWORD=secret
export DB_NAME=pos_mysql_app

./start.sh
```

#### Windows (Command Prompt)
```cmd
set DB_HOST=myserver.example.com
set DB_PORT=3306
set DB_USER=posuser
set DB_PASSWORD=secret
set DB_NAME=pos_mysql_app

start.bat
```

#### Using a `.env` file (recommended for production)
Copy `.env.example` to `.env` and fill in your values:
```
DB_HOST=myserver.example.com
DB_PORT=3306
DB_USER=posuser
DB_PASSWORD=secret
DB_NAME=pos_mysql_app
```
> `.env` is loaded automatically when the app starts. Never commit it to version control.

#### Available environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | MySQL server hostname or IP |
| `DB_PORT` | `3306` | MySQL port |
| `DB_USER` | `root` | MySQL username |
| `DB_PASSWORD` | *(empty)* | MySQL password |
| `DB_NAME` | `pos_mysql_app` | Database name |

---

### Multi-Shop / Multi-Tenant Support

The system has full **multi-shop isolation** built into every table:

- Every table (`products`, `sales`, `customers`, `suppliers`, `stock_history`, `purchase_orders`, `invoices`, `payments`, `product_audit_log`, `sale_returns`) has a `shop_id` column
- Data from different shops **never mixes** in any query
- Each admin/user is assigned to exactly one shop at creation time
- SKUs are unique **per shop** (same SKU can exist across shops independently)
- Super Admin can view all shops together or switch into a single shop for scoped views
- Connection pooling handles concurrent shops efficiently

**Managing shops via the web UI (Super Admin):**
1. Log in as `superadmin`
2. Go to **Shops** in the sidebar
3. Click **+ Add New Shop** — choose name, icon (emoji dropdown), currency (26+ options or custom), low stock threshold, address, phone
4. Assign users to shops when creating them in the **Users** page

**Adding a shop via SQL (alternative):**
```sql
INSERT INTO shops (name, icon, currency_symbol, low_stock_threshold)
VALUES ('Branch 2', '🏪', '€', 5);

INSERT INTO users (shop_id, username, password, role, full_name)
VALUES (2, 'branch2admin', SHA2('password', 256), 'admin', 'Branch 2 Admin');
```

---

### Running After First Installation

**With script:**
```bash
./start.sh          # macOS/Linux
```
```cmd
start.bat           # Windows
```

**Manually:**
```bash
# Activate virtual environment first
source venv/bin/activate    # macOS/Linux
# OR
venv\Scripts\activate       # Windows

# Then start the app
python app.py
```

**Stopping the server:**
- Press `Ctrl+C` in the terminal where the app is running
- Or: `kill $(cat logs/app.pid)`

---

### 🚀 Production Deployment (HTTPS with Nginx)

For deploying on a VPS/cloud server (Ubuntu/Debian) with HTTPS:

#### Prerequisites
- A domain name (e.g., `myshop.example.com`)
- Ubuntu/Debian server with root access
- Ports 80 and 443 open in your hosting provider's firewall

#### Step 0: Point your domain to your server

Before running the setup script, create a **DNS A record** in your domain registrar's panel (GoDaddy, Namecheap, Cloudflare, etc.):

| Record Type | Name | Value |
|-------------|------|-------|
| A | `@` or subdomain (e.g. `pos`) | Your server's public IP (e.g. `185.182.x.x`) |

Wait for DNS propagation (1–15 minutes typically), then verify:

```bash
dig yourdomain.com +short
# Should return your server's IP address
```

> **Important:** Certbot needs to reach your server on port 80 to verify domain ownership. The DNS must resolve before running `setup-nginx.sh`.

#### Quick Setup (Automated)

```bash
# 1. Start the app (generates SECRET_KEY, runs gunicorn on 127.0.0.1:5000)
./start.sh

# 2. Set up Nginx reverse proxy + SSL
sudo ./setup-nginx.sh yourdomain.com your@email.com
```

That's it! Your app is now live at `https://yourdomain.com`.

#### What the script does:
1. Installs Nginx and Certbot
2. Configures UFW firewall (allows HTTP/HTTPS/SSH, blocks outbound scanning ports)
3. Creates Nginx reverse proxy config (forwards 443 → 127.0.0.1:5000)
4. Obtains free Let's Encrypt SSL certificate
5. Sets up automatic certificate renewal

#### Architecture

```
Internet → HTTPS (443) → Nginx → HTTP (127.0.0.1:5000) → Gunicorn/Flask
```

Port 5000 is **never exposed** to the internet. Nginx handles SSL termination.

#### Manual Setup (if you prefer)

```bash
# Install Nginx & Certbot
sudo apt update && sudo apt install -y nginx certbot python3-certbot-nginx

# Create Nginx config
sudo nano /etc/nginx/sites-available/pos
```

Paste:
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    client_max_body_size 200M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site and get SSL
sudo ln -s /etc/nginx/sites-available/pos /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
sudo certbot --nginx -d yourdomain.com
```

**If certbot fails (port 80 blocked by hosting provider):**

Use DNS validation instead:
```bash
# 1. Request cert via DNS challenge
sudo certbot certonly --manual --preferred-challenges dns -d yourdomain.com

# 2. Add the TXT record it shows to your domain's DNS:
#    Type: TXT | Name: _acme-challenge | Value: (the string certbot displays)

# 3. Verify propagation before pressing Enter:
dig TXT _acme-challenge.yourdomain.com +short

# 4. Press Enter in certbot once dig shows the value

# 5. Install the cert into Nginx:
sudo certbot install --nginx -d yourdomain.com
```

#### Environment Variables (Production)

| Variable | Default | Description |
|----------|---------|-------------|
| `SECRET_KEY` | *(required)* | Flask session encryption key. Auto-generated by `start.sh` |
| `HOST` | `127.0.0.1` | Bind address (keep as localhost behind Nginx) |
| `PORT` | `5000` | App port |
| `FLASK_DEBUG` | `0` | **Never** set to `1` in production |
| `ALLOWED_ORIGINS` | `http://localhost:5000` | Comma-separated CORS origins |
| `GUNICORN_WORKERS` | `4` | Number of worker processes |
| `RUN_MODE` | `production` | Set to `development` for Flask dev server |

#### Ports & Firewall

After deployment, the following ports are active on the server:

**Inbound (open):**

| Port | Protocol | Purpose | Exposed to Internet? |
|------|----------|---------|---------------------|
| 22 | TCP | SSH (remote access) | Yes |
| 80 | TCP | HTTP (auto-redirects to HTTPS) | Yes |
| 443 | TCP | HTTPS (Nginx serves the app) | Yes |
| 5000 | TCP | Gunicorn/Flask app | **No** — bound to `127.0.0.1` only |
| 3306 | TCP | MySQL database | **No** — localhost only by default |

**Outbound (blocked by UFW):**

| Port | Reason |
|------|--------|
| 23 | Telnet scanning (common abuse vector) |
| 8080 | HTTP-proxy scanning (common abuse vector) |

> Only ports **22, 80, 443** are reachable from the internet. The app and database are never directly exposed.

#### Security Hardening Checklist

- [x] Debug mode disabled in production
- [x] SECRET_KEY required (no fallback)
- [x] App binds to localhost only (not 0.0.0.0)
- [x] Gunicorn as WSGI server (not Flask dev server)
- [x] CORS restricted to allowed origins
- [x] UFW firewall configured
- [x] SSL/HTTPS via Let's Encrypt
- [ ] Change default passwords (`admin`/`superadmin`)
- [ ] Run `mysql_secure_installation`
- [ ] Set up regular database backups (cron)

---

## Default Login

When you first start the application, two accounts are created:

| Role | Username | Password |
|------|----------|----------|
| Super Admin | `superadmin` | `superadmin123` |
| Admin | `admin` | `admin123` |

**⚠️ IMPORTANT**: Change all default passwords immediately after first login!

> **MySQL Note**: The default installation has no root password. Run `mysql_secure_installation` to set one before deploying to production.

## Usage

### First-Time Setup

1. **Login** as `superadmin` / `superadmin123`
2. Go to **Shops** → edit the default shop: set its name, icon, currency, and address
3. Create additional shops if needed (**+ Add New Shop**)
4. Login as `admin` / `admin123` (or create new admin accounts per shop in **Users**)
5. **Add Products** with cost and sell prices in the Products page
6. **Add Sales Staff** from the Users page — assign each to a shop

### For Admin

#### Dashboard
- View today's sales revenue and **profit**
- **Sales trend chart** (last 7 days)
- **Today vs Yesterday** comparison
- **Best sellers** - Top 5 products
- Monitor low stock alerts
- See recent stock activity

#### Products Page
- **Toolbar workflow**: Click a row to select → use toolbar buttons for actions
- Add products with **cost price** and **sell price** (auto-generates SKU)
- View **profit margins** per product
- **Create custom categories**
- **Inline quick-edit**: Double-click a cell to edit name, price, cost, or stock in-place
- **CSV Import/Export**: Bulk manage products via spreadsheet
- **Bulk stock update**: Update stock for multiple products at once
- **Duplicate products**: Clone similar products quickly
- **Per-product reorder levels**: Override global threshold per product
- **Audit log**: View full change history per product
- **Stock history with chart**: Visual stock-over-time graph
- **Pagination & sort**: 25/50/100/All per page, sort by any column
- Delete products with confirmation

#### Sales History
- View all transactions with **profit details** (admin-only profit column)
- **Filter by date range** (Today, Yesterday, Week, Month, Custom)
- **Search by sale ID, product name, or customer name** (real-time)
- **Filter by staff member** and **payment method** (Cash/Card/Transfer)
- **Sales summary bar**: Revenue, avg sale, discounts, profit, refunds, payment breakdown
- **Daily grouping**: Sales organized by date with per-day subtotals
- **Expandable rows**: Click a sale to see inline items, amount received/change, timeline
- **Sale status badges**: See at a glance if a sale is completed, unpaid (credit), partially paid, or refunded
- **View refund details**: Full breakdown of each refund (items, quantities, reason)
- **Reprint receipts**: Print any past sale receipt from history
- **Export to CSV**: Download filtered sales data
- See **who made each sale** and **customer name**
- Track sales performance by staff member

#### Reports & Analytics
- **Sales Reports** (auto-loads last 7 days on page open):
  - **Sales trend chart**: Daily revenue + profit line chart (Chart.js)
  - **Payment method doughnut chart**: Visual Cash/Card/Transfer breakdown
  - **Category revenue pie chart**: Sales by product category
  - **Hourly sales bar chart**: Transaction heatmap by hour of day
  - **Profit margin trend**: Daily margin % over time (admin only)
  - **Discount summary**: Total discounts, discounted count, average discount
  - **Refund summary**: Total refunded, count, rate, top refunded products
  - **Staff performance table**: Revenue, transactions, avg sale, profit, % of revenue bar
  - **Customer insights**: Top customers, repeat customer count, named sale %
  - **Period comparison**: Current vs previous period with % change arrows
  - Daily breakdown, top products, product performance tables
  - Quick ranges: Today, This Week, This Month, This Quarter, This Year
  - **Export to PDF or Excel**
- **Inventory Reports**:
  - Current stock levels, stock movements, most active products
  - **Slow-moving stock**: Products with 0-1 sales (dead inventory)
  - Low stock alerts
  - **Export to PDF or Excel**
- **Cash Flow Reports** (Admin Only):
  - Cash flow summary: Total collected, credit given, net flow, outstanding, overdue
  - Daily cash flow trend chart (collected vs credit)
  - Collection methods breakdown chart
  - Receivables aging analysis (0-30, 31-60, 61-90, 90+ days)
  - Outstanding by customer with credit utilization
  - **Export to PDF or Excel**

#### Settings (Categorized Navigation)
- **🏪 Shop**: Shop name, icon (emoji picker), currency, address, phone
- **📦 Inventory**: Low stock threshold, per-product reorder levels
- **🔔 Notifications**: SMTP email config, low stock alert schedule, test email
- **🔒 Security**: Session timeout (5 min - 24 hours), password policies
- **🗄️ Backup & Restore**: Database backup/restore (Super Admin only)

#### Customers
- **Add wholesale customers** with name, phone, email, address, credit limit
- **Customer ledger**: Click any customer to view their invoices and payment history
- **Record payment**: Accept payments against outstanding invoices (applies to oldest first)
- **Aging report**: View all overdue receivables across customers (0-30, 31-60, 61-90, 90+ days)
- **Summary dashboard**: Total customers, credit given, outstanding balance, customers with balances
- **Search**: Find customers by name, phone, or email

### For Sales Staff (User Role)

#### Point of Sale (Only Page Available)
- Login takes you directly to POS
- Search and select products (see sell prices only)
- Add to cart and adjust quantities
- Complete sales
- **Cannot see cost prices or profits**

## Adding Users

**From the web interface (Recommended):**

1. Login as **super admin** or **admin**
2. Go to **Users** page
3. Click **Add New User**
4. Fill in username, password, and select role:
   - **Admin**: Full access within their shop, sees profits and costs
   - **User (Sales Staff)**: POS access only, cannot see costs or profits
   > **Note**: The `super_admin` role cannot be created via the web interface — it is intentionally restricted to prevent privilege escalation. Super Admin accounts can only be created directly in the database (seeded on first install, or via SQL).
5. **Super Admin** sees a "Assign to Shop" dropdown — select which shop to assign the user to
6. Click **Create User**

## Configuring Email Alerts

To receive automatic low stock notifications:

### Step 1: Configure Email Settings

1. Login as admin
2. Go to **Settings** → **Email Configuration**
3. Configure SMTP settings:
   - **SMTP Server**: Your email provider's server (e.g., `smtp.gmail.com`)
   - **SMTP Port**: Usually `587` (TLS) or `465` (SSL)
   - **Username**: Your email address
   - **Password**: Your email password (without spaces)
     - **For Gmail**: Use an [App Password](https://support.google.com/accounts/answer/185833), not your regular password
   - **Alert Email**: Where to send notifications
4. Click **Send Test Email** to verify configuration

### Step 2: Configure Low Stock Alerts & Schedule

1. Go to **Settings** → **Low Stock Alerts & Scheduler**
2. Set **Low Stock Threshold**: Alert when stock falls below this number (default: 10)
3. **Configure Schedule**: Add/remove/modify check times
   - Default times: 09:00, 12:00, 18:00
   - Click **+ Add Check Time** to add more
   - Use time pickers to set custom times (24-hour format)
   - Remove unwanted times (minimum 1 required)
4. Click **Save Schedule** to update automatic alerts
5. Click **Check Low Stock Now** to manually trigger an alert immediately

### Automatic Scheduled Alerts

Once configured, the system will **automatically** check for low stock at your **custom scheduled times**.

**Default Schedule** (can be customized):
- **09:00 AM** - Morning check
- **12:00 PM** - Noon check
- **06:00 PM** - Evening check

**Customizable Schedule:**
- Add as many check times as you need
- Remove or modify existing times
- Set times in 24-hour format (HH:MM)
- Changes take effect immediately (no restart needed)
- View next scheduled run times in the Settings page

**How it works:**
- Background scheduler runs inside the Flask app
- Checks all products at your configured times
- Sends email only if low stock items are found
- Scheduler automatically updates when you save new times
- No manual intervention needed after setup

**Requirements:**
- Flask app must be running (`./start.sh`)
- VPN must be disconnected (SMTP ports are often blocked by VPNs)
- Email settings must be configured properly

### Popular Email Providers

**Gmail:**
- SMTP Server: `smtp.gmail.com`
- Port: `587`
- Note: Must use App Password (2FA required)

**Outlook/Hotmail:**
- SMTP Server: `smtp-mail.outlook.com`
- Port: `587`

**Yahoo:**
- SMTP Server: `smtp.mail.yahoo.com`
- Port: `587`

**Custom/Office 365:**
- Check with your email administrator for SMTP settings

## Database

The application uses **MySQL** with the following main tables:

- **users**: User accounts, roles, and shop assignment (`shop_id` NULL for super_admin)
- **shops**: Shop registry — name, icon, currency_symbol, low_stock_threshold, address, phone
- **products**: Product information, stock levels, cost/sell prices, per-product reorder levels (scoped by shop_id)
- **sales**: All sales transactions with items, payment method, amount received (cash_tendered column), customer name, customer_id (scoped by shop_id)
- **sale_returns**: Refund/return records linked to original sales (scoped by shop_id)
- **stock_history**: Complete inventory change log (scoped by shop_id)
- **product_audit_log**: Tracks all product edits — who, what field, old value → new value (scoped by shop_id)
- **customers**: Wholesale customer profiles with credit limits and outstanding balances (scoped by shop_id)
- **invoices**: Credit/partial payment invoices linked to sales and customers (scoped by shop_id)
- **payments**: Payment records against invoices (scoped by shop_id)
- **settings**: Global system configuration (SMTP, session timeout, scheduler times — shared across all shops)
- **suppliers**: Supplier contact records (scoped by shop_id)
- **purchase_orders**: Purchase order headers and line items (scoped by shop_id)

Database: MySQL — configured via environment variables or `database.py`.
Default database name: `pos_mysql_app`

## Monitoring Automatic Email Alerts

**Check Scheduler Status:**
1. Go to Settings → Low Stock Alerts & Scheduler
2. Look for the status box at the top
3. Should show: "✅ Automatic Email Alerts Enabled"
4. Displays your configured schedule and next scheduled run times

**View Scheduler Logs:**
```bash
# Watch scheduler activity in real-time
tail -f /tmp/flask_output.log | grep SCHEDULER
```

**Expected log output:**
```
[SCHEDULER] Background scheduler started
[SCHEDULER] Loaded 3 scheduled low stock checks
[SCHEDULER] Added job: 09:00
[SCHEDULER] Added job: 12:00
[SCHEDULER] Added job: 18:00
[SCHEDULER 2026-03-30 09:00:00] Running scheduled low stock check...
[SCHEDULER] ✓ Alert sent successfully for 2 low stock items
```

**If scheduler is not running:**
- Check if Flask app is running: `curl http://localhost:443`
- Restart Flask: `./start.sh`
- Look for APScheduler errors in: `tail -30 /tmp/flask_output.log`

## Product Categories

The system starts with common categories, but you can create custom categories:
- Default categories: Shirts, Pants, Dresses, Jackets, Shoes, Accessories, Other
- **Add Custom Categories**: Simply type a new category name when adding/editing products
- Categories automatically populate from existing products

## Tips

1. **Stock Management**: Import stock when receiving new inventory, export for manual adjustments
2. **Low Stock Alerts**:
   - Configure custom check times in Settings → Low Stock Alerts & Scheduler
   - Default schedule: 09:00, 12:00, 18:00 (fully customizable)
   - Add/remove check times as needed (minimum 1 required)
   - **Important**: Disconnect VPN before scheduled times for emails to send
   - Products below global threshold show in reports and dashboard
   - Manual trigger available anytime in Settings
3. **Backup**: Regularly dump your MySQL database: `mysqldump -u root -p --set-gtid-purged=OFF --single-transaction pos_mysql_app > ./backups/backup_$(date +%Y%m%d).sql`
4. **SKU**: Use SKU codes to uniquely identify products (optional)
5. **Session Security**: Adjust session timeout in Settings based on your security needs
6. **Reports**: Use PDF export for printing, Excel for further analysis
7. **Search**: Use real-time search in Sales History to quickly find transactions
8. **Discounts**: Apply discounts at POS for promotions or special customers
9. **Password Security**: Change default password immediately and use strong passwords
10. **Scheduler**: Keep Flask running for automatic low stock alerts to work (use `./start.sh` on startup)

## System Requirements

- Python 3.8+
- Modern web browser (Chrome, Firefox, Safari, Edge)
- 50MB free disk space
- SMTP server access (for email alerts - optional)
- Internet connection (for email alerts and Chart.js CDN - optional)
- Flask app running continuously (for automatic scheduled email alerts)

## Support

For issues or questions, please check the application logs in the terminal where you ran `python app.py`.

## Documentation

- **README.md**: Overview and installation guide (this file)
- **USER_GUIDE.md**: Detailed guide on user roles, permissions, and workflows
- **QUICKSTART.md**: Quick reference for getting started

## Scripts

- **start.sh**: Easy startup script for macOS/Linux (checks dependencies, creates venv, installs packages, runs app)
- **start.bat**: Easy startup script for Windows (auto-setup and run)
- **add_user.py**: Add new users via command line (admin or sales staff)
- **database.py**: Initialize or reset MySQL database schema
- **check_low_stock.sh**: Manual low stock checker (backup option, not needed with built-in scheduler)
- **test_smtp_direct.py**: Test email configuration without starting Flask
- **test_gmail_simple.py**: Test Gmail SMTP with different port configurations

## Security Notes

1. **Change default passwords** immediately after first login (`superadmin` and `admin`)
2. **Create individual accounts** for each staff member
3. **Use "user" role** for sales staff to hide sensitive pricing data
4. **Backup regularly** (Super Admin only): use Settings → Backup, or: `mysqldump -u root -p --set-gtid-purged=OFF --single-transaction pos_mysql_app > backups/backup_$(date +%Y%m%d).sql`
5. **Never share admin or super admin credentials** with sales staff
6. **Session timeout**: Adjust based on your security needs (shorter = more secure)
7. **Email credentials**: Stored in database — use app passwords, not regular passwords
8. **Super Admin account**: Keep this credential very secure — it has access to all shops and backup/restore

## Troubleshooting

### Installation Issues

**"python: command not found" or "pip: command not found":**
- Install Python 3:
  - Ubuntu/Debian: `sudo apt install python3 python3-pip python3-venv`
  - Fedora/RHEL: `sudo dnf install python3 python3-pip`
  - macOS: `brew install python3`
- Use `python3` and `pip3` commands instead of `python` and `pip`

**"python3-venv not found" error:**
```bash
# Ubuntu/Debian
sudo apt install python3-venv

# Fedora/RHEL
sudo dnf install python3-venv
```

**Virtual environment activation fails:**
- On Linux/macOS, make sure start.sh is executable:
  ```bash
  chmod +x start.sh
  ```
- The updated start.sh now uses direct venv paths and doesn't require activation

**"Permission denied" when running start.sh:**
```bash
chmod +x start.sh
./start.sh
```

**Dependencies fail to install:**
- Make sure you have internet connection
- Try upgrading pip first:
  ```bash
  ./venv/bin/pip install --upgrade pip
  ./venv/bin/pip install -r requirements.txt
  ```
- On some systems you may need build tools:
  - Ubuntu/Debian: `sudo apt install build-essential python3-dev`
  - Fedora/RHEL: `sudo dnf install gcc python3-devel`

**Port 5001 already in use:**
- Another application is using port 5001
- Find and stop it: `lsof -ti:443 | xargs kill -9` (macOS/Linux)
- Or change the port in app.py (last line): `app.run(debug=True, host='0.0.0.0', port=5001)`

### Email Alerts Not Working

**Gmail users:**
- Must enable 2-Factor Authentication
- Create an [App Password](https://support.google.com/accounts/answer/185833)
- Use App Password instead of regular password
- Server: `smtp.gmail.com`, Port: `587`

**"Authentication failed" error:**
- Verify username and password are correct
- Check if your email provider requires app-specific passwords
- Ensure SMTP settings match your provider's requirements

**"Connection refused" error:**
- Check SMTP server address and port
- Verify firewall isn't blocking outgoing SMTP connections
- Try port 465 (SSL) if 587 (TLS) doesn't work

**Test Email button:**
- Use this to verify configuration before relying on automatic alerts
- Check spam/junk folder if test email doesn't arrive

**VPN Blocking SMTP:**
- Most VPNs and corporate networks block SMTP ports (587, 465)
- **Solution**: Disconnect VPN before sending emails
- Automatic scheduler will fail silently if VPN is connected at scheduled times
- Check logs: `tail -f /tmp/flask_output.log | grep SCHEDULER`

**Automatic alerts not sending:**
- Verify Flask app is running (`./start.sh`)
- Check scheduler status in Settings → "Low Stock Alerts & Scheduler"
- Look for green checkmark: "✅ Automatic Email Alerts Enabled"
- Verify next scheduled run times are showing
- Make sure VPN is disconnected at your configured scheduled times
- Review your custom schedule in Settings to confirm check times

### Session Timeout Issues

**Getting logged out too frequently:**
- Go to Settings → Session Timeout
- Increase timeout duration (e.g., 1-2 hours for active use)

**Not logging out automatically:**
- Clear browser cache and cookies
- Check if browser is preventing JavaScript from running

### Database Issues

**MySQL connection refused:**
- Make sure MySQL is running:
  - macOS: `brew services start mysql`
  - Ubuntu/Debian: `sudo systemctl start mysql`
  - Windows: Start **MySQL80** service from Services panel
- Check host/port in `database.py` or your environment variables

**Access denied error:**
- Verify DB_USER and DB_PASSWORD are correct
- Test manually: `mysql -u root -p -h localhost`

**Need to reset the database:**
```bash
# Drop and recreate the active database
mysql -u root -p -e "DROP DATABASE pos_mysql_app; CREATE DATABASE pos_mysql_app CHARACTER SET utf8mb4;"
# Reinitialize schema
./venv/bin/python database.py
```

> If you have an old `pos_system_db` database left over from a previous installation, you can safely remove it:
> ```bash
> mysql -u root -p -e "DROP DATABASE IF EXISTS pos_system_db;"
> ```

**Restore from a backup:**
```bash
# Stop the Flask application first (Ctrl+C)

# Restore from SQL dump
mysql -u root -p pos_mysql_app < backup_20260417.sql

# Restart
python app.py
```

## Recently Added Features ✨

### Point of Sale Enhancements
- ✅ **Category filter tabs** with Out of Stock tab
- ✅ **Cart quantity input** with inline controls (quantity, discount, remove)
- ✅ **Payment modal** with Cash/Card/Transfer, quick cash buttons, change calculator
- ✅ **Customer name** on transactions
- ✅ **Hold/resume cart** (localStorage based)
- ✅ **Cart persistence** across page refresh
- ✅ **Refund/return flow** with partial refund support and remaining quantities
- ✅ **Reprint last receipt**
- ✅ **Low stock warning** before checkout
- ✅ **Keyboard shortcuts** (`/` search, `Escape` close, `Enter` confirm)
- ✅ **Out-of-stock badge** and greyed-out products

### Product Management Enhancements
- ✅ **Toolbar-based actions** (select row → use toolbar) replacing per-row buttons
- ✅ **Double-click to edit** product or individual cell (inline quick-edit)
- ✅ **Keyboard navigation** (Arrow keys, Enter, Delete)
- ✅ **CSV Export** for all products
- ✅ **CSV Import** with case-insensitive headers, BOM handling, SKU matching
- ✅ **Bulk stock update** for multiple products at once
- ✅ **Duplicate product** (clone with 0 stock)
- ✅ **Per-product reorder level** (custom low stock threshold)
- ✅ **Audit log** tracking all product edits (who, what, when)
- ✅ **Stock movement chart** (SVG line chart in history modal)
- ✅ **Pagination** (25/50/100/All per page)
- ✅ **Sortable columns** with sort arrows
- ✅ **Search bar + category filter tabs**
- ✅ **Stock status badges** and row highlighting
- ✅ **Product count summary** (total, low stock, out of stock)
- ✅ **Auto-generated SKU** (e.g., SHR-001)

### Sales History Enhancements
- ✅ **Payment method column + filter** (Cash/Card/Transfer)
- ✅ **Customer name column + search**
- ✅ **Sale status badges** (Completed / Partially Paid / Unpaid / Partial Refund / Refunded)
- ✅ **Receipt reprint** from history
- ✅ **Sales summary bar** with payment breakdown
- ✅ **Expandable rows** with inline items, timeline, amount received
- ✅ **Refund details modal** per sale
- ✅ **Export filtered sales CSV**
- ✅ **Daily grouping** with per-day subtotals
- ✅ **Profit per sale** (admin only)

### Reports & Analytics Enhancements
- ✅ **Sales trend chart** (daily revenue + profit line chart)
- ✅ **Payment method doughnut chart**
- ✅ **Category revenue pie chart**
- ✅ **Hourly sales bar chart** (transaction heatmap)
- ✅ **Profit margin trend chart** (admin only)
- ✅ **Discount summary** (total, count, average)
- ✅ **Refund summary** with top refunded products
- ✅ **Staff performance comparison** with % of revenue bars
- ✅ **Customer insights** (top customers, repeat count)
- ✅ **Period comparison** (current vs previous period with % change)
- ✅ **Slow-moving stock detection** (dead inventory)
- ✅ **Auto-load report on page open** (last 7 days)
- ✅ Quick range buttons (Today/Week/Month/Quarter/Year)

### Previous Features
- ✅ **Configurable automatic email alerts** (admin can set custom check times)
- ✅ **Split email and alert settings** (separate configuration sections)
- ✅ Receipt generation and printing
- ✅ Discount management (percentage and fixed amount)
- ✅ Advanced sales reports and analytics
- ✅ PDF/Excel export for reports
- ✅ Sales history filters (date, search, user)
- ✅ Session timeout configuration
- ✅ Custom shop name and currency
- ✅ Password change functionality
- ✅ Enhanced dashboard with charts
- ✅ Background scheduler for automated tasks

### Supplier & Purchase Order System
- ✅ **Suppliers page** with CRUD, search, and direct PO creation
- ✅ **Purchase Orders page** with create, view, receive, and delete flows
- ✅ **Partial receiving** support (ordered → partial → received status)
- ✅ **Auto stock increment** on receive with stock history logging
- ✅ **Cost price auto-update** using weighted average cost on receive
- ✅ **PO status badges** and status filtering
- ✅ **PO detail modal** with ordered vs received percentages
- ✅ **Delete protection** for suppliers with orders and received POs
- ✅ **Navigation** added to all pages (admin-only)

### Dashboard Enhancements
- ✅ **Clickable stat cards** (Total Products, Low Stock, Out of Stock link to filtered products)
- ✅ **Out of Stock count** card
- ✅ **Average Transaction** and **Discounts Today** cards
- ✅ **Today vs Yesterday comparison** with both values shown
- ✅ **Time-based greeting** (Good morning/afternoon/evening)
- ✅ **Scrollable stock activity** table

## Future Enhancements

Possible features to add:
- Barcode/QR code scanning and printing from SKU
- Product images (thumbnail in table and POS)
- Customer management (customer database, purchase history)
- Email receipts to customers
- Tax calculations and compliance
- Mobile app (iOS/Android)
- Loyalty program management
- Multi-currency transactions

### Multi-Shop / Multi-Tenant Support

The database foundation for multi-shop support is **complete** following the SQLite → MySQL migration. What's already done and what remains to build a full hosted multi-tenant platform:

**✅ Database & Data Isolation (Done)**
- ✅ MySQL server in use — supports concurrent connections and multi-shop access
- ✅ `shops` table exists with `name`, `currency_symbol`
- ✅ `shop_id` foreign key on all data tables (products, sales, returns, stock_history, settings, audit_log, customers, invoices, payments, purchase_orders, suppliers)
- ✅ All queries scoped by `shop_id` — data from different shops never mixes
- ✅ Per-shop settings (currency, SMTP config, session timeout, thresholds)
- ✅ Per-shop scheduler for automated alerts
- ✅ SKUs unique per shop (same SKU can exist across shops)
- ✅ Environment variables for credentials (`.env` support via python-dotenv)

**🔲 Authentication & Authorization (To Do)**
- Shop registration / onboarding flow
- Shop selection screen for users belonging to multiple shops
- Super-admin role for platform-level management (vs shop-level admin)
- Invitation system for shop admins to invite staff by email

**🔲 Frontend (To Do)**
- Shop switcher in the topbar
- Shop onboarding wizard for first-time setup
- Landing page / marketing site separate from the app

**🔲 Infrastructure (To Do)**
- Hosted database (MySQL on RDS, PlanetScale, etc.)
- Production deployment (Gunicorn + Nginx, or Railway/Render)
- HTTPS mandatory for multi-tenant
- File/image storage partitioned by shop (S3 or similar)

**🔲 Billing & Limits — if commercial (To Do)**
- Subscription plans (free tier with limits, paid tiers)
- Usage limits per plan (max products, users, sales)
- Payment integration (Stripe)

**🔲 Data Privacy & Security (To Do)**
- Per-shop backup and restore (from Settings UI)
- GDPR/data deletion support per shop
- Audit trail scoped per shop
