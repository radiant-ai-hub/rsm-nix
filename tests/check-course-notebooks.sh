#!/usr/bin/env bash
set -euo pipefail
analytics_dir="${RSM_ANALYTICS_DIR:-../rsm-podman/files/scalable_analytics}"
test_dir="$(realpath "$analytics_dir/test")"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$test_dir/check-pyspark.ipynb" ] || { echo "Course notebooks not found" >&2; exit 2; }
export RSM_HDFS_STATE="$(mktemp -d /tmp/rsm-hdfs-notebooks.XXXXXX)"
export RSM_HDFS_PORT_BASE="$((32000 + $$ % 1500 * 10))"
export RSMBASE="$RSM_HDFS_STATE/rsm-state"
export JUPYTER_PATH="$RSMBASE/jupyter${JUPYTER_PATH:+:$JUPYTER_PATH}"
export HADOOP_CONF_DIR="$RSM_HDFS_STATE/conf"
export HADOOP_LOG_DIR="$RSM_HDFS_STATE/logs"
export HADOOP_PID_DIR="$RSM_HDFS_STATE/pids"
cleanup() {
  rsm-hdfs stop >/dev/null 2>&1 || true
  if [ "${keep_hdfs_test_state:-0}" = 1 ]; then
    echo "Kept HDFS test state at $RSM_HDFS_STATE"
  else
    rm -rf -- "$RSM_HDFS_STATE"
  fi
}
trap cleanup EXIT
rsm-hdfs init
rsm-spark-kernel-install
python "$script_dir/run-course-notebooks.py" "$test_dir"
