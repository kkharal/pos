# User Guide - POS System with User Roles

## User Roles & Permissions

### Admin Role
**Full Access** - Can do everything:
- ✅ View Dashboard with profit metrics
- ✅ Manage Products (add, edit, delete)
- ✅ See **Cost Prices** and **Profit Margins**
- ✅ Import/Export Stock
- ✅ Access Point of Sale
- ✅ View Sales History with profit details
- ✅ See who made each sale

### User Role (Sales Member)
**Limited Access** - Sales focused:
- ✅ Access Point of Sale (make sales)
- ❌ Cannot see cost prices (only sell prices)
- ❌ Cannot access admin dashboard
- ❌ Cannot manage products
- ❌ Cannot view sales history or profits
- ❌ Cannot import/export stock

## Login System

### Default Credentials
**Admin Account:**
- Username: `admin`
- Password: `admin123`

**⚠️ IMPORTANT:** Change the admin password after first login!

### First Login
1. Open http://localhost:5000
2. You'll see the login page
3. Enter username and password
4. Click "Login"

## Managing Users

### Adding a Sales Member

**From the Web Interface:**

1. Login as admin
2. Click **Users** in the navigation menu
3. Click **Add New User** button
4. Fill in the form:
   - Username: john
   - Password: john123
   - Full Name: John Doe
   - Role: User (Sales Staff Only)
5. Click **Create User**

Now John can login and make sales, but won't see cost prices or profits!

### Managing Existing Users

On the Users page, you can:
- **View all users** with their roles
- **See when users were created**
- **Delete users** that are no longer needed (cannot delete yourself)

### User Management Tips

**For Admin:**
- Full access to everything
- Can see all financial data
- Manages inventory and products

**For Sales Staff:**
- Create "user" role accounts
- They can only access POS
- Cannot see your profit margins
- Cannot modify inventory

## Product Management (Admin Only)

### Adding Products with Cost & Sell Price

1. Go to **Products** page
2. Click **Add New Product**
3. Fill in:
   - **Name**: Blue T-Shirt
   - **Category**: Shirts
   - **Cost Price**: $10.00 (what you pay)
   - **Sell Price**: $19.99 (what customer pays)
   - **Stock**: 50
4. Click **Add Product**

The system automatically calculates:
- **Profit per unit**: $9.99
- **Profit margin**: 99.9%

### Understanding the Products Table

| Column | What it Shows |
|--------|---------------|
| Cost Price | What you paid for the item |
| Sell Price | What customer pays |
| Profit/Unit | Sell Price - Cost Price (with %) |
| Stock | Current inventory |

**Example:**
- Cost: $10
- Sell: $20
- Profit: $10 (100%)

## Making Sales (All Users)

### As a Sales Member:

1. Login with your user account
2. You'll go directly to **Point of Sale**
3. Search and click products to add to cart
4. You'll see **sell prices only** (not cost prices)
5. Complete the sale

### What Sales Members See:
- Product names and categories
- Sell prices only
- Stock availability
- Shopping cart and total

### What Sales Members DON'T See:
- ❌ Cost prices
- ❌ Profit margins
- ❌ Dashboard statistics
- ❌ Sales history

## Viewing Sales & Profits (Admin Only)

### Dashboard

Shows today's performance:
- **Today's Sales**: Total revenue
- **Today's Profit**: Actual profit made
- **Transactions**: Number of sales

### Sales History

View all transactions with:
- Who made the sale
- Total amount
- Profit made
- Detailed items

**Example Sale:**
```
Sold By: john
Total Sale: $39.98
Total Cost: $20.00
Profit: $19.98
```

## Stock Management (Admin Only)

### Import Stock (Receiving Inventory)

1. Click **Stock** button on a product
2. Select **Import Stock (Add)**
3. Enter quantity (e.g., +50)
4. Add note: "Received from supplier"
5. Click **Update Stock**

### Export Stock (Adjustments)

For damaged goods or returns:
1. Click **Stock** button
2. Select **Export Stock (Remove)**
3. Enter quantity (e.g., 5)
4. Add note: "Damaged items removed"
5. Update

## Security Best Practices

### Protect Your Business Data

1. **Change Default Password**
   ```bash
   python add_user.py
   # Delete the default admin and create new admin
   ```

2. **Use Strong Passwords**
   - Admin: Use complex password (letters, numbers, symbols)
   - Sales Staff: Unique password for each person

3. **Create User Accounts for Staff**
   - Don't share admin password
   - Create individual user accounts
   - Each sale is tracked to the user

4. **Regular Backups**
   ```bash
   cp pos_database.db backups/pos_$(date +%Y%m%d).db
   ```

## Common Workflows

### Opening Store (Admin)
1. Login as admin
2. Check dashboard for low stock alerts
3. Review yesterday's profit
4. Ensure all products are stocked

### During Sales (Sales Member)
1. Login with user credentials
2. Process customer sales in POS
3. Your username is automatically recorded

### Closing Store (Admin)
1. Review today's sales
2. Check profit margins
3. Plan restocking for next day
4. Backup database

## Troubleshooting

### Sales Member Sees Admin Features
- Make sure their role is set to "user" not "admin"
- Check by running: `python add_user.py` and create correct account

### Can't See Profit Data
- You must be logged in as admin
- Regular users cannot see profit information

### Forgot Admin Password
- Delete `pos_database.db`
- Run `python database.py` to recreate with default admin
- ⚠️ This deletes all data! Backup first!

## Example Scenario

### Setting Up for Your Clothing Shop

**Step 1: Login as Default Admin**
- Login with admin/admin123
- Go to Users page

**Step 2: Create Your Own Admin Account**
- Click "Add New User"
- Username: owner
- Password: MySecure123!
- Role: Admin (Full Access)
- Full Name: Shop Owner

**Step 3: Add Sales Staff**
- Click "Add New User" again
- Username: sarah
- Password: sarah2024
- Role: User (Sales Staff Only)
- Full Name: Sarah Johnson

**Step 3: Add Products (as Admin)**
- Blue Jeans: Cost $15, Sell $39.99
- Red Dress: Cost $20, Sell $59.99
- White Shirt: Cost $8, Sell $24.99

**Step 4: Sarah Makes a Sale**
- Sarah logs in
- Customer buys 1 Blue Jeans + 1 White Shirt
- Total: $64.98
- Sarah completes the sale

**Step 5: Owner Reviews (Admin)**
- Views sales: Sarah sold $64.98
- Sees profit: $21.98 (Cost was $23, Sell was $64.98)
- Checks inventory automatically updated

## Quick Reference

### Admin Password
- Default: admin/admin123
- **Change immediately!**

### Adding Sales Staff
```bash
python add_user.py
```

### Starting Application
```bash
./start.sh
```

### Database Backup
```bash
cp pos_database.db backup_$(date +%Y%m%d).db
```

### Access URLs
- Login: http://localhost:5000
- Dashboard (Admin): http://localhost:5000/
- POS (All): http://localhost:5000/pos
