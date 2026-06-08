# Formulas Used in POS System

This file documents how key report metrics are calculated in the current implementation.

## Finance Report (P&L)

- Revenue:
    `SUM(sales.total_amount)`
- COGS:
    `SUM(sales.total_cost)`
- Gross Profit:
    `Revenue - COGS`
- Expenses:
    `SUM(expenses.amount)`
- Net Profit:
    `Gross Profit - Expenses`

Additional finance fields:
- Total Refunds:
    `SUM(sale_returns.refund_amount)`
- Net Revenue:
    `Revenue - Refunds`
- Gross Margin (%):
    `(Gross Profit / Net Revenue) * 100` (0 if Net Revenue is 0)
- Net Margin (%):
    `(Net Profit / Net Revenue) * 100` (0 if Net Revenue is 0)

## Sales Report

- Revenue:
    `SUM(sales.total_amount)`
- Transactions:
    `COUNT(sales.id)`
- Avg Order Value (AOV):
    `AVG(sales.total_amount)`
- Gross Profit (admin view):
    `SUM(sales.total_amount - sales.total_cost)`

Notes:
- Discounts shown in sales report are `SUM(discount_amount)`.
- Refunds shown are from `sale_returns` in selected date range.

## Customer Report

- Top customer table values are grouped by `customer_name` from sales.
- Avg Spend (per customer row):
    `AVG(total_amount)` for that customer.
- Avg Spend KPI (current UI behavior):
    Average of `total_spent` across the displayed top customers list.

## Inventory Report

- Total Products:
    Count of active products returned by inventory query.
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

- Revenue:
    From Sales summary `total_sales`.
- Gross Profit:
    From Sales summary `total_profit` (sales gross profit before expenses).
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
- Total Collected:
    `walkin_cash + payments_collected`
- Credit Given:
    `SUM(invoices.total_amount - invoices.paid_amount)` in date range.
- Net Cash Flow:
    `total_collected - credit_given`
- Total Outstanding:
    `SUM(customers.balance)` where balance > 0.
- Overdue Amount:
    Sum of `(invoice.total_amount - invoice.paid_amount)` for unpaid invoices with past due date.

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
