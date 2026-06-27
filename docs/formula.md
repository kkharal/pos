# Formulas Used in POS System

This file documents how key report metrics are calculated in the current implementation.

## Finance Report (P&L)

- Gross Revenue:
    `SUM(sales.total_amount)`
- Total Refunds:
    `SUM(sale_returns.refund_amount)`
- **Net Sales (primary):**
    `Gross Revenue - Total Refunds`
- COGS:
    `SUM(sales.total_cost)`
- Refunded COGS:
    `SUM(LEAST(refund_amount, total_amount) * (total_cost / total_amount))` per refund
- Net COGS:
    `COGS - Refunded COGS`
- Gross Profit:
    `Net Sales - Net COGS`
- Expenses:
    `SUM(expenses.amount)`
- Net Profit:
    `Gross Profit - Expenses`
- Gross Margin (%):
    `(Gross Profit / Net Sales) * 100` (0 if Net Sales is 0)
- Net Margin (%):
    `(Net Profit / Net Sales) * 100` (0 if Net Sales is 0)

## Sales Report

- Gross Sales:
    `SUM(sales.total_amount)` (shown as supporting KPI)
- Refunds:
    `SUM(sale_returns.refund_amount)` for `return_date` in selected range
- **Net Sales (primary KPI):**
    `Gross Sales - Refunds`
- Transactions:
    `COUNT(sales.id)`
- Avg Order Value (AOV):
    `AVG(sales.total_amount)`
- Gross Sales Discounts:
    `SUM(sales.discount_amount)`
- Refunded Discount (proportional):
    `SUM(LEAST(refund_amount, total_amount) / total_amount × discount_amount)` per refund
- **Net Discounts:**
    `Gross Discounts - Refunded Discount`
- Daily Net Sales (per row):
    `daily gross sales - refunds processed on that date`
- Daily Gross Profit (per row, admin view):
    `daily gross profit - daily refunds + daily refunded COGS`

Refund date rule: refunds are subtracted on the date the return is **processed**, not the original sale date.

Notes:
- Discounts shown are `SUM(discount_amount)`.
- Refunds card still shown separately alongside Net Sales for full transparency.
- Previous-period comparison also uses net sales for both current and prior periods.

## Customer Report

- Top customer table values are grouped by `customer_name` from sales.
- Avg Spend (per customer row):
    `AVG(total_amount)` for that customer.
- Avg Spend KPI (current UI behavior):
    Average of `total_spent` across the displayed top customers list.

## Inventory Report

- Total Variants:
    Count of active product rows (SKU/size/color variants) returned by inventory query.
- Total Stock:
    `SUM(products.stock_quantity)` across active products.
- Stock Value (admin view):
    `SUM(stock_quantity * cost_price)` across active products.
- Potential Revenue (admin view):
    `SUM(stock_quantity * price)`
- Potential Profit (admin view):
    `SUM(stock_quantity * (price - cost_price))`

## Overview Report

Overview combines values from Sales and P&L endpoints for the month:

- **Net Sales (primary KPI):**
    From Sales summary `total_sales` (= Gross Sales − Refunds).
- Gross Profit:
    From Sales summary `total_profit` (net of refunded COGS, before expenses).
- Expenses:
    From P&L summary `total_expenses`.
- Transactions:
    From Sales summary `transaction_count`.

## Inventory Costing Method

### Weighted Average Cost (WAC)

Used when receiving stock from a Purchase Order. The system calculates the new cost price by blending existing inventory cost with incoming purchase cost, weighted by quantity.

Formula:

`New Cost = (Old Stock × Old Cost + New Qty × PO Cost) / (Old Stock + New Qty)`

Example:

`(40 × 200 + 5 × 210) / (40 + 5) = 201.11`

Result: product cost price updates from `200.00` to `201.11`.

## POS Checkout Formulas

- Item Subtotal:
    `item.price * item.quantity`
- Item Discount (percent):
    `item_subtotal * (item.discount / 100)`
- Item Discount (fixed):
    `item.discount`
- Subtotal:
    `SUM(item_subtotal)`
- Total Item Discount:
    `SUM(all item discount amounts)`
- After Item Discount:
    `Subtotal - Total Item Discount`
- Cart Discount (percent):
    `After Item Discount * (cart_discount_percent / 100)`
- Cart Discount (fixed):
    `MIN(cart_discount_value, After Item Discount)`
- Total Discount:
    `Total Item Discount + Cart Discount`
- Final Total:
    `Subtotal - Total Discount`

Validation rules used in POS:
- Percentage discount cannot exceed `100`.
- Fixed item discount cannot exceed the item subtotal.
- Quantity cannot exceed available stock.

## Credit and Payment Formulas

- Available Credit (customer card in POS):
    `credit_limit - balance`
- Credit Needed (credit sale check):
    `total_amount - amount_paid`
- Remaining Credit on partial payment:
    `total_amount - partial_amount`

## Cashflow Report Formulas

- Walk-in Cash Collected:
    Sum of `sales.total_amount` for sales not linked to invoices.
- Payments Collected:
    `SUM(payments.amount)` in date range.
- Refunds:
    `SUM(sale_returns.refund_amount)` for `return_date` in selected range.
- Net Cash In:
    `walkin_cash + payments_collected - refunds`
- Credit Given:
    `SUM(invoices.total_amount - invoices.paid_amount)` in date range.
- Net Cash Flow:
    `net_cash_in - credit_given`
- Total Outstanding:
    `SUM(customers.balance)` where balance > 0.
- Overdue Amount:
    Sum of `(invoice.total_amount - invoice.paid_amount)` for unpaid invoices with past due date.

Refund date rule for cash flow:
- Refunds are deducted on the date the return is **processed**, not the original sale date.

## Finance Ledger Formulas (Available Funds)

Purpose:
- Track real cash liquidity (money available to spend), separate from accounting profit.

Opening Balance:
- Per-shop starting cash baseline.
- Default value is `0` until set.
- Normally set once when starting ledger tracking for a shop.
- Does not auto-reset monthly.

Available Funds:
- `Opening Balance + Money In - Money Out`

Ledger source of truth:
- Available Funds is calculated from `finance_transactions` totals (plus opening balance), not directly from the `expenses` table.
- Formula used by API: `opening_balance + SUM(IN amounts) - SUM(OUT amounts)`.

Money In:
- Cash sales
- QR/bank sales
- Customer invoice payments (credit invoices paid)
- Owner investments

Money Out:
- Expenses
- Purchase order payments (when PO is marked paid)
- Refunds
- Owner withdrawals

Expense-to-ledger synchronization rules:
- On expense create: insert one OUT ledger row (`transaction_type = expense_payment`).
- On expense update: update the linked OUT ledger row amount/date/notes so Available Funds stays accurate.
- On expense delete: delete the linked OUT ledger row so Available Funds increases back by the deleted expense amount.

Not counted until cash movement happens:
- Unpaid credit sales
- Outstanding invoices
- Inventory valuation
- Net profit

Monthly interpretation:
- Month Opening = previous period Closing
- Month Closing = Month Opening + monthly inflows - monthly outflows

## Aging Bucket Logic (Cashflow)

Outstanding invoice balances are grouped by invoice age:

- Current (0–30 days):
    `DATEDIFF(NOW(), created_at) <= 30`
- 31–60 days:
    `DATEDIFF(NOW(), created_at) > 30 AND <= 60`
- 61–90 days:
    `DATEDIFF(NOW(), created_at) > 60 AND <= 90`
- 90+ days:
    `DATEDIFF(NOW(), created_at) > 90`
