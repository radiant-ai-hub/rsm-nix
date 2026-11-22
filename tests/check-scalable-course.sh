#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo '== Spark and PySpark =='
rsm-spark-kernel-install
bash "$script_dir/check-spark-hadoop.sh"

echo '== HDFS lifecycle and file round trip =='
bash "$script_dir/check-scalable-analytics.sh"

echo '== Bundled course notebooks =='
bash "$script_dir/check-course-notebooks.sh"

echo 'Scalable Analytics checks passed. Temporary HDFS services are stopped.'
