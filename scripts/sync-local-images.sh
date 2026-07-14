#!/usr/bin/env bash
# =============================================================================
# fix-local-images.sh
# Reconciles image files on disk with the local DB.
# For each .webp file in static/uploads/products/, finds the product by ID
# and updates image_path for all variants in that product group.
#
# Run this after manually copying images from live to local.
# Usage: ./scripts/fix-local-images.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env"

# Load .env
if [[ -f "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-pos_mysql_app}"

MYSQL_ARGS="-h$DB_HOST -P$DB_PORT -u$DB_USER"
[[ -n "$DB_PASSWORD" ]] && MYSQL_ARGS="$MYSQL_ARGS -p$DB_PASSWORD"

run_sql() { mysql $MYSQL_ARGS "$DB_NAME" -Bse "$1" 2>/dev/null; }
run_sql_cmd() { mysql $MYSQL_ARGS "$DB_NAME" -e "$1" 2>/dev/null; }

UPLOADS="$ROOT_DIR/static/uploads/products"

echo ""
echo "=== fix-local-images.sh ==="
echo "Uploads folder : $UPLOADS"
echo "Database       : $DB_NAME @ $DB_HOST:$DB_PORT"
echo ""

if [[ ! -d "$UPLOADS" ]]; then
    echo "ERROR: uploads folder not found: $UPLOADS"
    exit 1
fi

UPDATED=0
SKIPPED=0

for FILE in "$UPLOADS"/*.webp; do
    [[ -f "$FILE" ]] || continue
    FILENAME="$(basename "$FILE")"
    ANCHOR_ID="${FILENAME%.webp}"

    # Must be a number (the anchor product ID)
    if ! [[ "$ANCHOR_ID" =~ ^[0-9]+$ ]]; then
        echo "  SKIP $FILENAME — filename is not a numeric product ID"
        ((SKIPPED++)) || true
        continue
    fi

    # Find the product name + shop_id from the anchor ID
    ROW=$(run_sql "SELECT name, shop_id FROM products WHERE id=$ANCHOR_ID AND is_active=1 LIMIT 1;")
    if [[ -z "$ROW" ]]; then
        echo "  SKIP $FILENAME — product ID $ANCHOR_ID not found in local DB"
        ((SKIPPED++)) || true
        continue
    fi

    PROD_NAME=$(echo "$ROW" | awk -F'\t' '{print $1}')
    SHOP_ID=$(echo "$ROW" | awk -F'\t' '{print $2}')

    # Count how many variants will be updated
    VARIANT_COUNT=$(run_sql "SELECT COUNT(*) FROM products WHERE name='${PROD_NAME//\'/\\\'}' AND shop_id=$SHOP_ID AND is_active=1;")

    # Update all variants in this group
    NOW=$(date -u '+%Y-%m-%d %H:%M:%S')
    run_sql_cmd "UPDATE products SET image_path='$FILENAME', image_updated_at='$NOW' WHERE name='${PROD_NAME//\'/\\\'}' AND shop_id=$SHOP_ID AND is_active=1;"

    echo "  OK  $FILENAME  →  \"$PROD_NAME\"  ($VARIANT_COUNT variants updated)"
    ((UPDATED++)) || true
done

echo ""
echo "=== Done ==="
echo "  Files processed : $UPDATED"
echo "  Skipped         : $SKIPPED"
echo ""
echo "Refresh your browser — images should now appear."
