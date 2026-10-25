#!/usr/bin/env bash
set -euo pipefail

analytics_dir="${RSM_ANALYTICS_DIR:-../rsm-podman/files/scalable_analytics}"
fixture="$analytics_dir/test/Shakespeare.txt"
[ -f "$fixture" ] || { echo "Missing $fixture" >&2; exit 2; }
command -v rsm-hdfs >/dev/null
command -v hdfs >/dev/null

export RSM_HDFS_STATE="$(mktemp -d)"
export RSM_HDFS_PORT_BASE="$((30000 + $$ % 2000 * 10))"
export HADOOP_CONF_DIR="$RSM_HDFS_STATE/conf"
export HADOOP_LOG_DIR="$RSM_HDFS_STATE/logs"
export HADOOP_PID_DIR="$RSM_HDFS_STATE/pids"
cleanup() {
  rsm-hdfs stop >/dev/null 2>&1 || true
  if [ "${keep_hdfs_test_state:-0}" != 1 ]; then rm -rf -- "$RSM_HDFS_STATE"; fi
}
trap cleanup EXIT

rsm-hdfs init
test -f "$RSM_HDFS_STATE/name/current/VERSION"
rsm-hdfs init # must preserve the filesystem
rsm-hdfs start
for _ in $(seq 1 40); do
  if hdfs dfsadmin -report 2>/dev/null | grep -q 'Live datanodes (1)'; then break; fi
  sleep 1
done
hdfs dfsadmin -report | grep -q 'Live datanodes (1)'
hdfs dfs -mkdir /Demo1-HDFS
hdfs dfs -copyFromLocal "$fixture" /Demo1-HDFS/
hdfs dfs -cat /Demo1-HDFS/Shakespeare.txt > "$RSM_HDFS_STATE/copied.txt"
cmp "$fixture" "$RSM_HDFS_STATE/copied.txt"
hdfs dfs -cp /Demo1-HDFS/Shakespeare.txt /Demo1-HDFS/ShakespeareNew.txt
hdfs dfs -copyToLocal /Demo1-HDFS/ShakespeareNew.txt "$RSM_HDFS_STATE/ShakespeareNew.txt"
cmp "$fixture" "$RSM_HDFS_STATE/ShakespeareNew.txt"
rsm-hdfs stop
rsm-hdfs start
for _ in $(seq 1 40); do
  if hdfs dfsadmin -report 2>/dev/null | grep -q 'Live datanodes (1)'; then break; fi
  sleep 1
done
hdfs dfs -test -e /Demo1-HDFS/Shakespeare.txt
rsm-hdfs reset --yes
rsm-hdfs init
rsm-hdfs start
for _ in $(seq 1 40); do
  if hdfs dfsadmin -report 2>/dev/null | grep -q 'Live datanodes (1)'; then break; fi
  sleep 1
done
if hdfs dfs -test -e /Demo1-HDFS/Shakespeare.txt; then
  echo "Reset did not clear the test data" >&2
  exit 1
fi
echo 'Scalable Analytics HDFS lifecycle and file checks passed.'
