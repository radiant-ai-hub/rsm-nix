# check-spark-hadoop.sh
#
# Validates the optional Spark/Hadoop profile. Run from the workspace root:
#   nix develop .#spark-hadoop -c bash tests/check-spark-hadoop.sh

set -euo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

echo "== environment =="
for v in JAVA_HOME SPARK_HOME HADOOP_HOME; do
  if [ -n "${!v:-}" ]; then ok "$v=${!v}"; else bad "$v unset (are you in 'nix develop .#spark-hadoop'?)"; fi
done

echo "== hadoop version =="
if hadoop version >/dev/null 2>&1; then ok "hadoop version"; else bad "hadoop version"; fi

echo "== spark-submit --version =="
if spark-submit --version >/dev/null 2>&1; then ok "spark-submit --version"; else bad "spark-submit --version"; fi

echo "== pyspark local session =="
if python3 - <<'PY'
from pyspark.sql import SparkSession
spark = (
    SparkSession.builder.master("local[1]")
    .appName("rsm-check-spark-hadoop")
    .config("spark.ui.enabled", "false")
    .getOrCreate()
)
assert spark.range(5).count() == 5
spark.stop()
print("pyspark ok")
PY
then ok "pyspark local session"; else bad "pyspark local session"; fi

[ "$fail" -eq 0 ] && echo "Spark/Hadoop check passed." || { echo "Spark/Hadoop check FAILED." >&2; exit 1; }
