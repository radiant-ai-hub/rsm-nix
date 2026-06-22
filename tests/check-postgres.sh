# check-postgres.sh
#
# Exercises the full workspace-local PostgreSQL lifecycle. Run from the
# workspace root inside the dev shell:
#   nix develop -c bash tests/check-postgres.sh

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${PGHOST:=$RSMBASE/postgres/socket}"
: "${PGPORT:=8765}"
: "${PGDATABASE:=rsm-msba}"
: "${PGUSER:=$(id -un)}"

echo "== rsm-pg-init =="
rsm-pg-init

echo "== rsm-pg-start =="
rsm-pg-start

echo "== pg_isready =="
pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER"

echo "== SELECT 1 =="
rsm-pg-psql -tA -c "SELECT 1;" | grep -qx 1
echo "  ok"

echo "== round-trip table =="
rsm-pg-psql -v ON_ERROR_STOP=1 <<'SQL'
DROP TABLE IF EXISTS rsm_check;
CREATE TABLE rsm_check (id int, label text);
INSERT INTO rsm_check VALUES (1, 'hello'), (2, 'world');
SQL
count="$(rsm-pg-psql -tA -c "SELECT count(*) FROM rsm_check;")"
test "$count" = "2"
echo "  inserted/read $count rows"
rsm-pg-psql -c "DROP TABLE rsm_check;" >/dev/null

echo "== databases present =="
rsm-pg-psql -tAc "SELECT datname FROM pg_database WHERE datname IN ('$PGUSER','$PGDATABASE');" \
  | sort | tr '\n' ' '
echo

echo "== rsm-pg-stop =="
rsm-pg-stop

echo "PostgreSQL lifecycle check passed."
