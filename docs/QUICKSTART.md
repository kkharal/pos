# Quick Start Guide

## Easiest Way to Run (macOS/Linux)

Simply run the startup script:

```bash
./start.sh
```

This will automatically:
- Create virtual environment if needed
- Install dependencies if needed
- Initialize database if needed
- Start the application

Then open your browser to: **http://localhost:8080**

## Manual Start (All Platforms)

1. Activate virtual environment:
   ```bash
   source venv/bin/activate  # macOS/Linux
   venv\Scripts\activate     # Windows
   ```

2. Run the app:
   ```bash
   python app.py
   ```

3. Open browser to: **http://localhost:8080**

## First Time Setup

### Add Your First Products

1. Go to **Products** page
2. Click **Add New Product**
3. Fill in:
   - Name: e.g., "Blue T-Shirt"
   - Category: e.g., "Shirts"
   - Cost Price: e.g., "10.00" (what you paid)
   - Sell Price: e.g., "19.99" (what customers pay)
   - Stock: e.g., "50"
4. Click **Add Product**

### Add Sales Staff

1. Go to **Users** page (in navigation)
2. Click **Add New User**
3. Fill in:
   - Username: e.g., "sarah"
   - Password: e.g., "sarah123"
   - Full Name: e.g., "Sarah Johnson"
   - Role: Select "User (Sales Staff Only)"
4. Click **Create User**

Now Sarah can login and make sales without seeing your cost prices!

### Make Your First Sale

1. Go to **Point of Sale** page
2. Click on products to add them to cart
3. Adjust quantities with +/- buttons
4. Click **Complete Sale**

### Manage Inventory

1. Go to **Products** page
2. Click **Stock** button on any product
3. Choose:
   - **Import Stock**: Add new inventory (e.g., +20 items)
   - **Export Stock**: Remove inventory (e.g., -5 items)
4. Add a note for tracking (optional)

### View Sales

1. Go to **Sales History** page
2. See all transactions
3. Click **View Details** to see individual sale items

## Tips

- Products with stock below 5 appear in red (low stock warning)
- All inventory changes are logged in stock history
- Dashboard shows today's sales and key metrics
- The database file `pos_database.db` contains all your data

## Backup Your Data

To backup your shop data, simply copy the file:
```bash
cp pos_database.db pos_database_backup_$(date +%Y%m%d).db
```

## Troubleshooting

**App won't start?**
- Make sure Python 3.8+ is installed: `python3 --version`
- Activate virtual environment first
- Check if dependencies are installed: `pip list`

**Can't access the app?**
- Make sure you're going to: http://localhost:8080
- Check if port 8080 is already in use
- Look for errors in the terminal

**Database errors?**
- Delete `pos_database.db` and run `python database.py` again
- This will create a fresh database (data will be lost)
