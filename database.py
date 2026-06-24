import hashlib
import json
import os
import re
from collections.abc import Mapping
from decimal import Decimal
from datetime import datetime, date, timezone, timedelta

from dotenv import load_dotenv
import mysql.connector

# Load .env from the repository root, regardless of the current working directory.
# override=True prevents stale service-level env vars from masking updated .env credentials.
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"), override=True)

DB_NAME = os.getenv("DB_NAME", "pos_mysql_app")
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": DB_NAME,
    "port": int(os.getenv("DB_PORT", "3306")),
    "autocommit": False,
}


class RowCompat(Mapping):
    """SQLite Row-like wrapper for MySQL dict rows."""

    def __init__(self, data):
        self._data = data
        self._keys = list(data.keys())

    def __getitem__(self, key):
        if isinstance(key, int):
            val = self._data[self._keys[key]]
        else:
            val = self._data[key]
        # Convert MySQL-specific types to plain Python types
        if isinstance(val, Decimal):
            return float(val)
        if isinstance(val, datetime):
            return val.strftime('%Y-%m-%d %H:%M:%S')
        if isinstance(val, date):
            return val.strftime('%Y-%m-%d')
        return val

    def __iter__(self):
        return iter(self._keys)

    def __len__(self):
        return len(self._keys)

    def get(self, key, default=None):
        val = self._data.get(key, default)
        if isinstance(val, Decimal):
            return float(val)
        if isinstance(val, datetime):
            return val.strftime('%Y-%m-%d %H:%M:%S')
        if isinstance(val, date):
            return val.strftime('%Y-%m-%d')
        return val


def _translate_query(query):
    q = query

    # SQLite-style placeholders -> MySQL placeholders
    q = q.replace("?", "%s")

    # `key` is reserved in MySQL; normalize settings queries.
    if "settings" in q.lower():
        q = re.sub(r"(?<!`)\bkey\b(?!`)", "`key`", q)

    # SQLite upsert syntax used in app.py
    if "insert or replace into settings" in q.lower():
        q = re.sub(r"(?i)insert\s+or\s+replace\s+into\s+settings", "INSERT INTO settings", q)
        q = re.sub(r"(?i)\(\s*key\s*,\s*value\s*,\s*updated_at\s*\)", "(`key`, value, updated_at)", q)
        q += " ON DUPLICATE KEY UPDATE value=VALUES(value), updated_at=VALUES(updated_at)"

    return q


class CursorCompat:
    def __init__(self, cursor):
        self._cursor = cursor

    @property
    def lastrowid(self):
        return self._cursor.lastrowid

    @property
    def rowcount(self):
        return self._cursor.rowcount

    def execute(self, query, params=None):
        translated = _translate_query(query)
        self._cursor.execute(translated, params or ())
        return self

    def fetchone(self):
        row = self._cursor.fetchone()
        if row is None:
            return None
        return RowCompat(row)

    def fetchall(self):
        rows = self._cursor.fetchall()
        return [RowCompat(r) for r in rows]

    def close(self):
        self._cursor.close()


class ConnectionCompat:
    def __init__(self, conn):
        self._conn = conn

    def cursor(self):
        return CursorCompat(self._conn.cursor(dictionary=True, buffered=True))

    def execute(self, query, params=None):
        cur = self.cursor()
        cur.execute(query, params)
        return cur

    def commit(self):
        self._conn.commit()

    def rollback(self):
        self._conn.rollback()

    def close(self):
        self._conn.close()


def hash_password(password):
    """Hash a password using SHA256."""
    return hashlib.sha256(password.encode()).hexdigest()


def _create_database_if_missing():
    bootstrap = mysql.connector.connect(
        host=DB_CONFIG["host"],
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"],
        port=DB_CONFIG["port"],
        autocommit=True,
    )
    try:
        cur = bootstrap.cursor()
        cur.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cur.close()
    finally:
        bootstrap.close()


def _column_exists(cursor, table_name, column_name):
    cursor.execute(
        """
        SELECT COUNT(*) as cnt
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = %s
          AND TABLE_NAME = %s
          AND COLUMN_NAME = %s
        """,
        (DB_NAME, table_name, column_name),
    )
    return cursor.fetchone()[0] > 0


def _index_exists(cursor, table_name, index_name):
    cursor.execute(
        """
        SELECT COUNT(*) as cnt
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = %s
          AND TABLE_NAME = %s
          AND INDEX_NAME = %s
        """,
        (DB_NAME, table_name, index_name),
    )
    return cursor.fetchone()[0] > 0


def init_db():
    """Initialize MySQL database schema (multi-shop)."""
    _create_database_if_missing()
    conn = get_db_connection()
    cursor = conn.cursor()

    # ── 1. Shops table (created before users – users FK to shops) ───────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS shops (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            address TEXT,
            phone VARCHAR(50),
            icon VARCHAR(50) DEFAULT '🛒',
            currency_symbol VARCHAR(10) DEFAULT '$',
            low_stock_threshold INT DEFAULT 5,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 2. Users table ───────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(255) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            role VARCHAR(50) NOT NULL,
            full_name VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 3. Products table ────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            category VARCHAR(100) NOT NULL,
            cost_price DECIMAL(12,2) NOT NULL DEFAULT 0,
            price DECIMAL(12,2) NOT NULL,
            stock_quantity INT NOT NULL DEFAULT 0,
            is_active TINYINT(1) NOT NULL DEFAULT 1,
            sku VARCHAR(255) UNIQUE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 4. Customers ─────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS customers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            phone VARCHAR(50),
            email VARCHAR(255),
            address TEXT,
            customer_type VARCHAR(50) NOT NULL DEFAULT 'walk-in',
            credit_limit DECIMAL(12,2) NOT NULL DEFAULT 0,
            balance DECIMAL(12,2) NOT NULL DEFAULT 0,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 5. Sales table ────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS sales (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            customer_id INT,
            customer_name VARCHAR(255) DEFAULT '',
            total_amount DECIMAL(12,2) NOT NULL,
            total_cost DECIMAL(12,2) NOT NULL DEFAULT 0,
            discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
            payment_method VARCHAR(50) DEFAULT 'cash',
            cash_tendered DECIMAL(12,2) DEFAULT 0,
            items_json LONGTEXT NOT NULL,
            sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id),
            FOREIGN KEY (customer_id) REFERENCES customers (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 6. Sale returns ───────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS sale_returns (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sale_id INT NOT NULL,
            user_id INT,
            items_json LONGTEXT NOT NULL,
            refund_amount DECIMAL(12,2) NOT NULL,
            reason TEXT,
            return_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sale_id) REFERENCES sales(id),
            FOREIGN KEY (user_id) REFERENCES users(id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 7. Stock history ──────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS stock_history (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            quantity_change INT NOT NULL,
            action_type VARCHAR(50) NOT NULL,
            note TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 8. Settings table (global + per-shop) ────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS settings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            `key` VARCHAR(255) NOT NULL,
            value LONGTEXT NOT NULL,
            shop_id INT NULL DEFAULT NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uq_settings_key_shop (`key`, shop_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 9. Product audit log ──────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS product_audit_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            user_id INT,
            username VARCHAR(255),
            action VARCHAR(100) NOT NULL,
            field_name VARCHAR(255),
            old_value LONGTEXT,
            new_value LONGTEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products (id),
            FOREIGN KEY (user_id) REFERENCES users (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 10. Suppliers ─────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS suppliers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            contact_person VARCHAR(255),
            email VARCHAR(255),
            phone VARCHAR(50),
            address TEXT,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 11. Product-Supplier links ───────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS product_suppliers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            supplier_id INT NOT NULL,
            supplier_cost DECIMAL(12,2) NULL,
            supplier_sku VARCHAR(100) NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_product_supplier (product_id, supplier_id),
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
            FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 12. Purchase orders ───────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS purchase_orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            supplier_id INT NOT NULL,
            status VARCHAR(50) NOT NULL DEFAULT 'draft',
            total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
            notes TEXT,
            created_by INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            received_at TIMESTAMP NULL,
            FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
            FOREIGN KEY (created_by) REFERENCES users (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 13. PO items ──────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS po_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            po_id INT NOT NULL,
            product_id INT NOT NULL,
            quantity_ordered INT NOT NULL,
            quantity_received INT NOT NULL DEFAULT 0,
            unit_cost DECIMAL(12,2) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (po_id) REFERENCES purchase_orders (id),
            FOREIGN KEY (product_id) REFERENCES products (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 13. Invoices ──────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS invoices (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sale_id INT NOT NULL,
            customer_id INT NOT NULL,
            total_amount DECIMAL(12,2) NOT NULL,
            paid_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
            status VARCHAR(50) NOT NULL DEFAULT 'unpaid',
            due_date DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sale_id) REFERENCES sales(id),
            FOREIGN KEY (customer_id) REFERENCES customers(id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 14. Payments ──────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS payments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            customer_id INT NOT NULL,
            invoice_id INT,
            amount DECIMAL(12,2) NOT NULL,
            payment_method VARCHAR(50) NOT NULL DEFAULT 'cash',
            received_by INT,
            notes TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (customer_id) REFERENCES customers(id),
            FOREIGN KEY (invoice_id) REFERENCES invoices(id),
            FOREIGN KEY (received_by) REFERENCES users(id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 15. User-shop assignments (for shop_owner role) ─────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS user_shops (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            shop_id INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_user_shop (user_id, shop_id),
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (shop_id) REFERENCES shops (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 16. Expense categories ────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS expense_categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            icon VARCHAR(50) DEFAULT '📝',
            description TEXT,
            shop_id INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 17. Expenses ──────────────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS expenses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            category_id INT NOT NULL,
            amount DECIMAL(12,2) NOT NULL,
            description TEXT,
            expense_date DATE NOT NULL,
            payment_method VARCHAR(50) NOT NULL DEFAULT 'cash',
            receipt_ref VARCHAR(255),
            created_by INT,
            shop_id INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES expense_categories (id),
            FOREIGN KEY (created_by) REFERENCES users (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 18. Recurring expenses ────────────────────────────────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS recurring_expenses (
            id INT AUTO_INCREMENT PRIMARY KEY,
            category_id INT NOT NULL,
            amount DECIMAL(12,2) NOT NULL,
            description TEXT,
            frequency VARCHAR(50) NOT NULL DEFAULT 'monthly',
            next_due_date DATE NOT NULL,
            is_active TINYINT(1) NOT NULL DEFAULT 1,
            shop_id INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES expense_categories (id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── 19. Scheduled alert send log (idempotency guard) ─────────────────────
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS alert_send_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            shop_id INT NOT NULL,
            alert_type VARCHAR(64) NOT NULL,
            slot_date DATE NOT NULL,
            slot_time CHAR(5) NOT NULL,
            timezone_name VARCHAR(64) NOT NULL,
            item_count INT NULL,
            sent_at TIMESTAMP NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_alert_slot (shop_id, alert_type, slot_date, slot_time, timezone_name),
            INDEX idx_alert_shop_created (shop_id, created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    # ── Migration: add columns to existing tables ────────────────────────────

    # Sales: total_cost column (profit tracking)
    if not _column_exists(cursor, "sales", "total_cost"):
        cursor.execute("ALTER TABLE sales ADD COLUMN total_cost DECIMAL(12,2) NOT NULL DEFAULT 0")

    # Backfill total_cost for sales that have 0 (from before column existed)
    zero_cost_sales = cursor.execute(
        "SELECT id, items_json FROM sales WHERE total_cost = 0"
    ).fetchall()
    for sale in zero_cost_sales:
        try:
            items = json.loads(sale['items_json']) if isinstance(sale['items_json'], str) else sale['items_json']
            cost = 0
            for item in items:
                pid = item.get('product_id') or item.get('id')
                qty = item.get('quantity', 1)
                if pid:
                    prod = cursor.execute("SELECT cost_price FROM products WHERE id=?", (pid,)).fetchone()
                    if prod and prod['cost_price']:
                        cost += float(prod['cost_price']) * qty
            if cost > 0:
                cursor.execute("UPDATE sales SET total_cost=? WHERE id=?", (cost, sale['id']))
        except Exception:
            pass

    # Products extras
    if not _column_exists(cursor, "products", "low_stock_threshold"):
        cursor.execute("ALTER TABLE products ADD COLUMN low_stock_threshold INT NULL")
    if not _column_exists(cursor, "products", "size"):
        cursor.execute("ALTER TABLE products ADD COLUMN size VARCHAR(50) NULL")
    if not _column_exists(cursor, "products", "color"):
        cursor.execute("ALTER TABLE products ADD COLUMN color VARCHAR(50) NULL")
    if not _column_exists(cursor, "products", "variant_group"):
        cursor.execute("ALTER TABLE products ADD COLUMN variant_group VARCHAR(100) NULL")
    if not _column_exists(cursor, "products", "is_active"):
        cursor.execute("ALTER TABLE products ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1")

    # Backfill missing variant_group values so manually added variants join the correct family.
    import uuid
    null_variant_rows = cursor.execute(
        '''
        SELECT id, shop_id, name, category, size, color
        FROM products
        WHERE variant_group IS NULL
        ORDER BY shop_id, name, category, id
        '''
    ).fetchall()

    variant_group_updates = []
    grouped_null_rows = {}
    for row in null_variant_rows:
        group_key = (row['shop_id'], row['name'], row['category'])
        grouped_null_rows.setdefault(group_key, []).append(row)

    for (shop_id, name, category), rows in grouped_null_rows.items():
        sibling = cursor.execute(
            '''
            SELECT variant_group
            FROM products
            WHERE shop_id = ? AND name = ? AND variant_group IS NOT NULL
            ORDER BY id
            LIMIT 1
            ''',
            (shop_id, name)
        ).fetchone()

        inherited_group = sibling['variant_group'] if sibling else None
        if not inherited_group:
            has_variant_traits = any(r['size'] or r['color'] for r in rows)
            if len(rows) > 1 or has_variant_traits:
                inherited_group = f"{name[:20].lower().replace(' ', '-')}-{uuid.uuid4().hex[:8]}"

        if inherited_group:
            for row in rows:
                variant_group_updates.append((inherited_group, row['id']))

    for variant_group, product_id in variant_group_updates:
        cursor.execute("UPDATE products SET variant_group = ? WHERE id = ? AND variant_group IS NULL", (variant_group, product_id))

    # Users extras
    if not _column_exists(cursor, "users", "last_login"):
        cursor.execute("ALTER TABLE users ADD COLUMN last_login DATETIME NULL")

    # Settings: migrate from single global key to per-shop key
    if not _column_exists(cursor, "settings", "shop_id"):
        # Drop the old globally-unique constraint on key before adding shop_id
        if _index_exists(cursor, "settings", "key"):
            try:
                cursor.execute("ALTER TABLE settings DROP INDEX `key`")
            except Exception:
                pass
        cursor.execute("ALTER TABLE settings ADD COLUMN shop_id INT NULL DEFAULT NULL")
        if not _index_exists(cursor, "settings", "uq_settings_key_shop"):
            cursor.execute(
                "ALTER TABLE settings ADD UNIQUE KEY uq_settings_key_shop (`key`, shop_id)"
            )

    # shop_id columns (all nullable to allow safe migration of existing rows)
    _shop_tables = [
        "users", "products", "sales", "sale_returns", "stock_history",
        "customers", "suppliers", "purchase_orders", "invoices", "payments",
        "product_audit_log",
    ]

    # Ensure product_suppliers exists for supplier linking in inventory.
    # Older installs may miss this table even though the API expects it.
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS product_suppliers (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            supplier_id INT NOT NULL,
            supplier_cost DECIMAL(12,2) NULL,
            supplier_sku VARCHAR(100) NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_product_supplier (product_id, supplier_id),
            FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
            FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """
    )

    for tbl in _shop_tables:
        if not _column_exists(cursor, tbl, "shop_id"):
            cursor.execute(f"ALTER TABLE {tbl} ADD COLUMN shop_id INT NULL")

    # ── Seed default shop ────────────────────────────────────────────────────
    default_shop_count = cursor.execute("SELECT COUNT(*) FROM shops").fetchone()[0]
    if default_shop_count == 0:
        # Inherit any existing per-shop settings from the legacy settings table
        def _get_setting(key, default):
            row = cursor.execute(
                "SELECT value FROM settings WHERE key = ?", (key,)
            ).fetchone()
            return row["value"] if row else default

        shop_name = _get_setting("shop_name", "Default Shop")
        shop_icon = _get_setting("shop_icon", "🛒")
        currency = _get_setting("currency_symbol", "$")
        threshold = int(_get_setting("low_stock_threshold", "5"))

        cursor.execute(
            "INSERT INTO shops (name, icon, currency_symbol, low_stock_threshold) VALUES (?, ?, ?, ?)",
            (shop_name, shop_icon, currency, threshold),
        )
        default_shop_id = cursor.lastrowid
        print(f"Default shop created: '{shop_name}' (id={default_shop_id})")
    else:
        default_shop_id = cursor.execute(
            "SELECT id FROM shops ORDER BY id LIMIT 1"
        ).fetchone()["id"]

    # ── Migrate existing rows to default shop ────────────────────────────────
    for tbl in ["sales", "sale_returns", "stock_history", "customers",
                "suppliers", "purchase_orders", "invoices", "payments", "product_audit_log"]:
        cursor.execute(
            f"UPDATE {tbl} SET shop_id = ? WHERE shop_id IS NULL", (default_shop_id,)
        )

    # Products: fix duplicate SKUs before assigning shop_id (to avoid unique constraint violation)
    null_shop_products = cursor.execute(
        "SELECT id, sku FROM products WHERE shop_id IS NULL ORDER BY id"
    ).fetchall()
    seen_skus = set()
    # Also gather SKUs already assigned to this shop
    existing_skus = cursor.execute(
        "SELECT sku FROM products WHERE shop_id = ?", (default_shop_id,)
    ).fetchall()
    for row in existing_skus:
        seen_skus.add(row['sku'])
    for prod in null_shop_products:
        sku = prod['sku']
        if sku in seen_skus:
            # Append suffix to make it unique
            suffix = 2
            new_sku = f"{sku}-{suffix}"
            while new_sku in seen_skus:
                suffix += 1
                new_sku = f"{sku}-{suffix}"
            cursor.execute("UPDATE products SET sku = ?, shop_id = ? WHERE id = ?", (new_sku, default_shop_id, prod['id']))
            seen_skus.add(new_sku)
        else:
            cursor.execute("UPDATE products SET shop_id = ? WHERE id = ?", (default_shop_id, prod['id']))
            seen_skus.add(sku)
    # Users: only non-super_admin users are assigned to the default shop
    cursor.execute(
        "UPDATE users SET shop_id = ? WHERE shop_id IS NULL AND role != 'super_admin'",
        (default_shop_id,),
    )

    # ── Fix SKU unique constraint for multi-shop ──────────────────────────────
    # Drop old globally-unique constraint on sku; replace with per-shop uniqueness
    if _index_exists(cursor, "products", "sku"):
        try:
            cursor.execute("ALTER TABLE products DROP INDEX sku")
        except Exception:
            pass
    if not _index_exists(cursor, "products", "uq_product_sku_shop"):
        try:
            cursor.execute(
                "ALTER TABLE products ADD UNIQUE KEY uq_product_sku_shop (sku, shop_id)"
            )
        except Exception:
            pass

    # ── Global settings (shop_id = NULL, non-shop-specific) ──────────────────
    global_settings = [
        ("brand_name", "POS System"),
        ("session_timeout", "1800"),
        ("smtp_server", ""),
        ("smtp_port", "587"),
        ("smtp_username", ""),
        ("smtp_password", ""),
        ("alert_email", ""),
        ("low_stock_threshold", "5"),
        ("scheduler_times", json.dumps(["09:00", "12:00", "18:00"])),
    ]
    for key, value in global_settings:
        existing = cursor.execute(
            "SELECT id FROM settings WHERE `key` = %s AND shop_id IS NULL", (key,)
        ).fetchone()
        if not existing:
            cursor.execute(
                "INSERT INTO settings (`key`, value, shop_id) VALUES (%s, %s, NULL)",
                (key, value),
            )

    # ── Per-shop email settings: seed empty rows for each shop ───────────────
    per_shop_email_keys = [
        ("smtp_server", ""),
        ("smtp_port", "587"),
        ("smtp_username", ""),
        ("smtp_password", ""),
        ("alert_email", ""),
        ("low_stock_threshold", "5"),
    ]
    all_shop_ids = [r[0] for r in cursor.execute("SELECT id FROM shops").fetchall()]
    for sid in all_shop_ids:
        for key, value in per_shop_email_keys:
            cursor.execute(
                """
                INSERT INTO settings (`key`, value, shop_id)
                VALUES (%s, %s, %s)
                ON DUPLICATE KEY UPDATE value = value
                """,
                (key, value, sid),
            )

    # ── Seed users (fresh install only) ──────────────────────────────────────
    existing_users = cursor.execute("SELECT COUNT(*) FROM users").fetchone()[0]
    if existing_users == 0:
        # Super admin – no shop assignment (NULL)
        cursor.execute(
            "INSERT INTO users (username, password, role, full_name, shop_id) VALUES (?, ?, ?, ?, ?)",
            ("superadmin", hash_password("superadmin123"), "super_admin", "Super Administrator", None),
        )
        # Default shop admin
        cursor.execute(
            "INSERT INTO users (username, password, role, full_name, shop_id) VALUES (?, ?, ?, ?, ?)",
            ("admin", hash_password("admin123"), "admin", "Administrator", default_shop_id),
        )
        print("Default users created:")
        print("  Super Admin  – Username: superadmin, Password: superadmin123")
        print("  Shop Admin   – Username: admin,      Password: admin123")

    # ── Seed default expense categories (per shop, only if none exist) ───────
    for sid in all_shop_ids:
        cat_count = cursor.execute(
            "SELECT COUNT(*) as cnt FROM expense_categories WHERE shop_id = ?", (sid,)
        ).fetchone()[0]
        if cat_count == 0:
            default_categories = [
                ('Employee Salary', '👤', 'Staff wages and salaries'),
                ('Shop Rent', '🏠', 'Monthly shop rental'),
                ('Electricity / Utilities', '⚡', 'Electric, water, gas bills'),
                ('Transportation', '🚗', 'Delivery and travel costs'),
                ('Maintenance & Repairs', '🔧', 'Shop repairs and maintenance'),
                ('Packaging & Supplies', '📦', 'Bags, boxes, wrapping'),
                ('Marketing', '📣', 'Advertising and promotions'),
                ('Miscellaneous', '📝', 'Other expenses'),
            ]
            for cat_name, cat_icon, cat_desc in default_categories:
                cursor.execute(
                    "INSERT INTO expense_categories (name, icon, description, shop_id) VALUES (?, ?, ?, ?)",
                    (cat_name, cat_icon, cat_desc, sid),
                )
            print(f"  Default expense categories seeded for shop id={sid}")

    conn.commit()
    conn.close()
    print("Database initialized successfully (MySQL – multi-shop)!")


def _tz_name_to_offset(tz_name):
    """Convert a timezone name like 'Asia/Bangkok' to a MySQL-compatible offset like '+07:00'.
    Falls back to '+00:00' if conversion fails."""
    try:
        import zoneinfo
        tz = zoneinfo.ZoneInfo(tz_name)
        now = datetime.now(tz)
        total_seconds = int(now.utcoffset().total_seconds())
        sign = '+' if total_seconds >= 0 else '-'
        total_seconds = abs(total_seconds)
        hours, remainder = divmod(total_seconds, 3600)
        minutes = remainder // 60
        return f"{sign}{hours:02d}:{minutes:02d}"
    except Exception:
        return '+00:00'


def get_db_connection():
    """Get a MySQL connection wrapped with SQLite-compatible helpers."""
    conn = mysql.connector.connect(**DB_CONFIG)
    # Apply the configured shop timezone so CURDATE()/NOW() align with local time.
    try:
        _cur = conn.cursor(dictionary=True)
        _cur.execute("SELECT value FROM settings WHERE `key` = 'scheduler_timezone' AND shop_id IS NULL LIMIT 1")
        _row = _cur.fetchone()
        _cur.close()
        tz_name = (_row['value'] if _row and _row.get('value') else None) or 'UTC'
        offset = _tz_name_to_offset(tz_name)
        conn.cursor().execute(f"SET time_zone = '{offset}'")
    except Exception:
        conn.cursor().execute("SET time_zone = '+00:00'")
    return ConnectionCompat(conn)

if __name__ == '__main__':
    init_db()
