#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PYTHON="./venv/bin/python"
if [ ! -x "$PYTHON" ]; then
    PYTHON="python3"
fi

echo "Smoke check: Python syntax validation"

# Compile key entry-point files first for faster feedback.
"$PYTHON" -m py_compile app.py database.py

# Compile all Python files in top-level and templates/helpers folders if any.
while IFS= read -r -d '' pyfile; do
    "$PYTHON" -m py_compile "$pyfile"
done < <(find . -maxdepth 3 -type f -name "*.py" ! -path "./venv/*" -print0)

echo "Smoke check passed"
