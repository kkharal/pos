# Project Structure - Clean & Organized ✅

## Directory Overview

```
simple-web-app/
├── app.py                      # Main Flask application (~3000+ lines)
├── database.py                 # MySQL database initialization & connection adapter
├── add_user.py                 # CLI utility to add users
├── requirements.txt            # Python dependencies
├── start.sh                    # Easy startup script (macOS/Linux)
├── start.bat                   # Easy startup script (Windows)
├── check_low_stock.sh          # Manual low stock checker (backup)
├── README.md                   # Main documentation
├── PROJECT_STRUCTURE.md        # This file
├── INSTALL.md                  # Installation guide
│
├── templates/                  # HTML templates
│   ├── login.html             # Login page
│   ├── index.html             # Dashboard with charts & analytics
│   ├── products.html          # Product management (CRUD, CSV, audit log)
│   ├── pos.html               # Point of Sale (cart, payments, refunds)
│   ├── sales.html             # Sales history (filters, grouping, export)
│   ├── reports.html           # Reports & analytics (charts, PDF/Excel)
│   ├── suppliers.html         # Supplier management (CRUD, search)
│   ├── purchase_orders.html   # Purchase orders (create, receive, track)
│   ├── users.html             # User management (create, roles)
│   └── settings.html          # Settings (shop name, email, scheduler)
│
├── static/                     # Static assets
│   ├── css/
│   │   └── style.css          # Main stylesheet (variables, responsive)
│   └── js/
│       ├── currency.js        # Currency formatting utilities
│       ├── session.js         # Session timeout management
│       └── ui.js              # Shared UI components (toast, navbar)
│
├── docs/                       # Documentation
│   ├── QUICKSTART.md          # Quick start guide
│   ├── USER_GUIDE.md          # Detailed user guide
│   ├── BUGFIXES.md            # Bug fix history
│   └── SALES_STAFF_PERMISSIONS.md  # Role permissions reference
│
├── tests/                      # Testing files
│   ├── simple_test.py         # Basic tests
│   ├── test_dashboard.py      # Dashboard tests
│   ├── test_email_alert.py    # Email alert tests
│   ├── test_gmail_simple.py   # Gmail SMTP tests
│   ├── test_inventory_report.py # Inventory report tests
│   ├── test_login_shopname.py # Login & shop name tests
│   ├── test_shopname.py       # Shop name tests
│   ├── test_smtp_direct.py    # SMTP direct tests
│   └── test_system.py         # E2E test suite
│
├── venv/                       # Virtual environment (auto-generated)
└── venv/                       # Virtual environment (auto-generated)
```

---

## File Descriptions

### Core Application Files

**app.py** (~3000+ lines)
- Main Flask application with all routes and API endpoints
- Authentication logic with role-based access control (admin/user)
- Product CRUD, stock management, CSV import/export
- POS sales, cart, payments, discounts, refunds
- Supplier management and purchase order system
- Weighted average cost calculation on PO receive
- Stock history with cost price enrichment
- Reports generation (sales, inventory) with PDF/Excel export
- Email alerts with APScheduler for low stock notifications
- Dashboard analytics and chart data APIs
- Settings management (shop name, currency, session timeout)

**database.py**
- MySQL-backed drop-in adapter with SQLite-compatible API (RowCompat, CursorCompat)
- Translates `?` placeholders to `%s` and `INSERT OR REPLACE` to MySQL `ON DUPLICATE KEY UPDATE`
- Initializes all tables with `CREATE TABLE IF NOT EXISTS` (safe to re-run)
- Reads connection settings from environment variables: `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`

**requirements.txt**
- Python package dependencies:
  - Flask 3.0.0 — Web framework
  - Flask-CORS 4.0.0 — Cross-origin resource sharing
  - ReportLab 4.0.7 — PDF generation
  - OpenPyXL 3.1.2 — Excel file generation
  - APScheduler 3.10.4 — Background task scheduling
  - mysql-connector-python 8.2.0 — MySQL driver

**start.sh / start.bat**
- Easy startup scripts for macOS/Linux and Windows
- Auto-creates virtual environment, installs dependencies
- Initializes database, starts Flask server

---

### Templates (HTML Files)

**login.html**
- User login page with form validation
- Shows default credentials hint

**index.html** (Dashboard)
- Statistics cards (revenue, profit, products, low/out of stock, avg transaction, discounts)
- Clickable stat cards linking to filtered product views
- Sales trend chart (last 7 days) with Chart.js
- Today vs Yesterday comparison
- Best sellers widget, recent sales activity
- Time-based greeting

**products.html**
- Product management with toolbar-based actions (edit, stock, delete, history, audit, duplicate, reorder level)
- Inline quick-edit (double-click cells), keyboard navigation
- Search, category filter tabs, sortable columns, pagination (25/50/100/All)
- Stock status badges, row highlighting (out-of-stock, low stock, selected)
- CSV import/export, bulk stock update, duplicate product
- Stock history modal with SVG line chart and cost price column
- Audit log modal, per-product reorder level
- URL state persistence (search, category, stock filter, sort, page)

**pos.html** (Point of Sale)
- Category filter tabs with product counts and Out of Stock tab
- Product search by name, SKU, or category
- Cart with inline quantity, discount, remove per item
- Cart-level discount (percentage/fixed), customer name
- Payment modal (Cash/Card/Transfer) with quick cash buttons, change calculator
- Hold/resume cart (localStorage), cart persistence across refresh
- Refund/return flow with partial refund support
- Receipt generation and reprint
- Keyboard shortcuts, low stock warning before checkout
- URL state persistence (search, category)

**sales.html**
- Sales history with date range, search, staff, and payment method filters
- Sales summary bar (revenue, avg sale, discounts, profit, refunds, payment breakdown)
- Daily grouping with per-day subtotals
- Expandable rows with inline items, timeline, cash tendered/change
- Refund status badges, refund details modal
- Receipt reprint, CSV export
- URL state persistence (dates, user, payment, search)

**reports.html**
- Sales reports: trend chart, payment doughnut, category pie, hourly heatmap, profit margin trend
- Discount summary, refund summary, staff performance, customer insights
- Period comparison with % change indicators
- Inventory reports: stock levels, movements, slow-moving stock, low stock alerts
- Quick range buttons (Today/Week/Month/Quarter/Year)
- PDF and Excel export
- Auto-loads last 7 days on page open
- URL state persistence (tab, date ranges)

**suppliers.html**
- Supplier CRUD with contact details (name, email, phone, address, notes)
- Real-time search across all fields
- Quick "+ PO" button per supplier for direct PO creation
- Order count per supplier
- Delete protection for suppliers with existing purchase orders
- URL state persistence (search)

**purchase_orders.html**
- Create PO: select supplier, add products with quantity and unit cost (auto-fill from product cost)
- PO status tracking: Ordered (blue), Partial (orange), Received (green)
- Full and partial receiving with quantity tracking per item
- Auto stock update and weighted average cost calculation on receive
- PO detail modal with ordered vs received percentages
- Status filtering, delete protection for received POs
- URL state persistence (status filter)

**users.html**
- User management: create, delete users
- Role assignment (admin/user)

**settings.html**
- Store settings: shop name, shop icon picker (40 emoji options), currency (20+ options + custom)
- Security: session timeout configuration
- Email configuration: SMTP settings, test email
- Low stock alerts: threshold, custom check schedule (add/remove times), manual trigger
- Section dividers for organized layout

---

### Static Assets

**static/css/style.css**
- CSS variables for theming
- Responsive design with mobile hamburger menu
- Sticky navbar, toast notifications, modal overlays
- Report table scroll (`.report-table-scroll`), settings section labels
- Status badges, row highlighting, loading overlay

**static/js/currency.js**
- Currency formatting utilities
- Reads currency symbol from settings

**static/js/session.js**
- Session timeout management
- Auto-logout on inactivity

**static/js/ui.js**
- Shared UI components
- Toast notification system
- Navbar initialization, hamburger menu
- Shop name/icon loading

---

### Documentation

**README.md**
- Comprehensive project documentation
- Feature overview, installation (quick start + manual)
- Usage guide for admin and sales staff
- Email alert configuration
- Troubleshooting, security notes
- Future enhancements roadmap

**docs/QUICKSTART.md**
- Quick start guide, step-by-step setup

**docs/USER_GUIDE.md**
- Detailed user guide, role explanations, workflows

**docs/BUGFIXES.md**
- Bug fix history and resolutions

**docs/SALES_STAFF_PERMISSIONS.md**
- Role-based permissions reference

---

### Database Tables

| Table | Purpose |
|-------|---------|
| `users` | User accounts and roles (admin/user) |
| `products` | Products with cost/sell price, stock, SKU, category, reorder level |
| `sales` | Sales transactions with items, payment, customer, discount |
| `sale_returns` | Refund/return records linked to original sales |
| `stock_history` | Complete inventory change log with cost tracking |
| `product_audit_log` | Tracks all product edits (who, what field, old → new) |
| `settings` | System config (shop name, currency, email, timeout, scheduler) |
| `suppliers` | Supplier contact details and notes |
| `purchase_orders` | PO header (supplier, status, dates) |
| `po_items` | PO line items (product, qty ordered/received, unit cost) |

---

### Auto-Generated Files

**venv/**
- Python virtual environment
- Created by: `python3 -m venv venv`
- Not tracked in git

---

## File Count

```
Core Files:        6 files  (app.py, database.py, config.py, etc.)
Templates:         6 files  (HTML pages)
Static:            1 file   (CSS)
Documentation:     3 files  (README + docs/)
Utilities:         2 files  (optional)
Tests:             1 file   (optional)
─────────────────────────────
Total:            18 files  (clean & organized!)
```

---

## Essential vs Optional

### ✅ Essential (Required to Run)
```
app.py
database.py
requirements.txt
start.sh
templates/
static/
```

### 📝 Documentation (Recommended)
```
README.md
docs/QUICKSTART.md
docs/USER_GUIDE.md
```

### 🔧 Utilities (Optional)
```
add_user.py
tests/
```

---

## Quick Commands

**Start Application:**
```bash
./start.sh
```

**Run Tests:**
```bash
source venv/bin/activate
python tests/test_system.py
```

**Add User (CLI):**
```bash
source venv/bin/activate
python add_user.py
```

**Backup Database (MySQL):**
```bash
mysqldump -u root -p pos_mysql_app > backups/pos_$(date +%Y%m%d).sql
```

---

## Size Overview

**Total Project Size:** ~200 KB (excluding venv and database)
- Application Code: ~20 KB
- Templates: ~30 KB
- CSS: ~5 KB
- Documentation: ~15 KB
- Utilities: ~4 KB
- Tests: ~19 KB

**Very lightweight and efficient!**

---

## Production Deployment

For production, you only need:
```
app.py
database.py
requirements.txt
templates/
static/
.gitignore
README.md
```

Everything else is optional!

---

## Backup Strategy

**What to Backup:**
1. MySQL dump: `mysqldump -u root -p pos_mysql_app > backup.sql` (your data — most important!)
2. `.env` file (if you add one for production secrets)
3. Custom modifications to templates/static

**What NOT to Backup:**
- `venv/` folder (can be recreated)
- `__pycache__/` (auto-generated)
- Test outputs

---

## Summary

✅ **Clean Structure** - Only essential files
✅ **Well Organized** - Logical folder layout
✅ **Documented** - Comprehensive guides
✅ **Production Ready** - No clutter
✅ **Easy to Navigate** - Clear file purposes
✅ **Lightweight** - Minimal footprint

**Your project is now clean and production-ready!** 🎉
