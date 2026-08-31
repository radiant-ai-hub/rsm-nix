# check-postgres.sh
#
# Exercises the full workspace-local PostgreSQL lifecycle. Run from the
# workspace root inside the dev shell:
#   nix develop -c bash tests/check-postgres.sh

set -euo pipefail

: "${RSM_WORKSPACE:=$PWD}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${PGDATA:=$RSMBASE/postgres/data}"
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

# --- multi-tenant isolation: the whole point on a shared server (sc2) ----------
echo "== security: NO TCP listener (socket-only) =="
if pg_isready -h 127.0.0.1 -p "$PGPORT" >/dev/null 2>&1; then
  echo "  FAIL: reachable over TCP 127.0.0.1:$PGPORT — another user on this host could connect" >&2
  exit 1
fi
echo "  ok: TCP 127.0.0.1:$PGPORT refused (no loopback listener)"

echo "== security: socket dir is private (0700) =="
perms="$(stat -c '%a' "$PGHOST" 2>/dev/null || stat -f '%Lp' "$PGHOST" 2>/dev/null || echo '?')"
[ "$perms" = "700" ] || { echo "  FAIL: $PGHOST is mode $perms, expected 700" >&2; exit 1; }
echo "  ok: $PGHOST is 0700 (only the owner can open the socket)"

echo "== security: pg_hba is socket + peer only (no trust / no host) =="
grep -qE '^[[:space:]]*local[[:space:]]+all[[:space:]]+all[[:space:]]+peer' "$PGDATA/pg_hba.conf" \
  || { echo "  FAIL: pg_hba.conf missing 'local all all peer'" >&2; exit 1; }
if grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$PGDATA/pg_hba.conf" | grep -qiE '(^|[[:space:]])trust([[:space:]]|$)|^[[:space:]]*host'; then
  echo "  FAIL: pg_hba.conf still contains a trust or host line" >&2
  grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$PGDATA/pg_hba.conf" >&2
  exit 1
fi
echo "  ok: pg_hba.conf is socket + peer only"

echo "== rsm-pg-stop =="
rsm-pg-stop

echo "PostgreSQL lifecycle check passed."
