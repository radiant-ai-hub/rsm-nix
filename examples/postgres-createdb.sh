#!/usr/bin/env bash
# postgres-createdb.sh — load two example databases (Northwind and
# WestCoastImporters) into your workspace-local PostgreSQL so you can practice
# SQL. Safe to re-run: databases that already exist are skipped.
#
# Run it from a terminal in ~/rsm-msba (so the nix-uv environment is active and
# PGHOST/PGPORT/PGUSER are set):
#
#     bash examples/postgres-createdb.sh
#
# Afterwards, connect with:
#     rsm-pg-psql -d Northwind          # or: -d WestCoastImporters
#     rsm-pgweb                         # browse in the pgweb UI
#
set -uo pipefail

# 1. Make sure PostgreSQL is running (idempotent; initializes on first run).
if ! command -v rsm-pg-start >/dev/null 2>&1; then
  echo "rsm-pg-start not found. Open a terminal in ~/rsm-msba (you should see" >&2
  echo "(nix-uv) in the prompt), then re-run this script." >&2
  exit 1
fi
rsm-pg-start

if ! pg_isready >/dev/null 2>&1; then
  echo "PostgreSQL is not accepting connections. Try 'rsm-pg-status'." >&2
  exit 1
fi

# 2. The example dumps assign object ownership to a "postgres" role. This
#    cluster's superuser is your own login, so create a "postgres" role once
#    (harmless if it already exists) to keep the load clean. You stay a
#    superuser, so you can fully read/write either database.
psql -d postgres <<'SQL' >/dev/null
DO $do$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'postgres') THEN
    CREATE ROLE postgres SUPERUSER LOGIN;
  END IF;
END
$do$;
SQL

# 3. Download + load each database (into a temp dir that is cleaned up after).
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

load_db() {
  local name="$1" url="$2" dump="$work/$1.sql"
  printf '\n==> %s\n' "$name"

  if psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$name'" 2>/dev/null | grep -q 1; then
    echo "    database '$name' already exists — skipping."
    echo "    (to reload from scratch:  dropdb $name  then re-run this script)"
    return 0
  fi

  echo "    downloading dump..."
  if ! curl -fL --retry 3 -o "$dump" "$url"; then
    echo "    download failed — check your internet connection; skipping $name." >&2
    return 1
  fi

  echo "    creating database '$name' and loading (this can take a moment)..."
  createdb "$name"
  psql -q -d "$name" -f "$dump" >/dev/null

  local n
  n="$(psql -d "$name" -tAc \
        "SELECT count(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null)"
  echo "    done — '$name' has ${n:-?} tables.  Connect:  rsm-pg-psql -d $name"
}

load_db Northwind \
  "https://www.dropbox.com/s/s3bn7mkmpo391s3/Northwind_DB_Dump.sql?dl=1"
load_db WestCoastImporters \
  "https://www.dropbox.com/s/gqnhvhhxyjrslmb/WestCoastImporters_Full_Dump.sql?dl=1"

printf '\nAll set. Your databases:\n'
psql -d postgres -tAc \
  "SELECT '  - ' || datname FROM pg_database WHERE datname IN ('Northwind','WestCoastImporters') ORDER BY datname"
echo
echo "Open one in VS Code's SQL tools, in pgweb (rsm-pgweb), or with:"
echo "    rsm-pg-psql -d Northwind"
