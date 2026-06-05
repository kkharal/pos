# Formulas Used in POS System

## Weighted Average Cost (WAC)

Used when receiving stock from a Purchase Order. The system calculates the new cost price by blending the existing inventory cost with the incoming purchase cost, weighted by quantity.

### Formula

```
New Cost = (Old Stock × Old Cost + New Qty × PO Cost) / (Old Stock + New Qty)
```

### Example

**Product:** Jackets (JAC-005)

| | Qty | Unit Cost |
|---|---|---|
| Existing stock | 40 | $200.00 |
| PO received | 5 | $210.00 |

**Calculation:**

```
New Cost = (40 × 200 + 5 × 210) / (40 + 5)
         = (8000 + 1050) / 45
         = 9050 / 45
         = $201.11
```

**Result:** The product's cost price updates from $200.00 → $201.11

### Why Weighted Average?

- Reflects the true average cost of all inventory on hand
- Industry standard (used by Shopify, QuickBooks, Zoho, etc.)
- Smooths out price fluctuations from different suppliers/batches
- Simple to implement and audit
