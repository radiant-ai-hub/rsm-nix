{ pkgs, sparkHadoop }:
let
  notebookPython = pkgs.python313.withPackages (ps: [ ps.ipykernel ps.nbclient ps.nbformat ]);
  courseExamples = builtins.path {
    path = ../course-examples/mgta466/test;
    name = "rsm-mgta466-notebooks";
  };
  vmCheck = pkgs.writeShellScript "check-scalable-analytics-vm" ''
    set -euo pipefail
    export RSM_HDFS_STATE="$HOME/hdfs-test"
    export HADOOP_CONF_DIR="$RSM_HDFS_STATE/conf"
    export HADOOP_LOG_DIR="$RSM_HDFS_STATE/logs"
    export HADOOP_PID_DIR="$RSM_HDFS_STATE/pids"
    on_exit() {
      result=$?
      if [ "$result" -ne 0 ]; then
        for log in "$HADOOP_LOG_DIR"/*datanode*.log; do
          if [ -f "$log" ]; then tail -n 120 "$log"; fi
        done
      fi
      rsm-hdfs stop || true
      exit "$result"
    }
    trap on_exit EXIT
    rsm-hdfs init
    rsm-hdfs start
    for n in $(seq 1 40); do
      if hdfs dfsadmin -report 2>/dev/null | grep -q 'Live datanodes (1)'; then break; fi
      sleep 1
    done
    hdfs dfsadmin -report | grep -q 'Live datanodes (1)'
    echo 'NixOS HDFS round trip' > "$HOME/sample.txt"
    hdfs dfs -mkdir /course
    hdfs dfs -copyFromLocal "$HOME/sample.txt" /course/
    hdfs dfs -cat /course/sample.txt | cmp - "$HOME/sample.txt"
    rsm-hdfs stop
    rsm-hdfs start
    for n in $(seq 1 40); do
      if hdfs dfsadmin -report 2>/dev/null | grep -q 'Live datanodes (1)'; then break; fi
      sleep 1
    done
    hdfs dfs -test -e /course/sample.txt
    python3 - <<'PY'
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local[1]").appName("nixos-scalable-analytics").config("spark.ui.enabled", "false").getOrCreate()
assert spark.range(3).count() == 3
spark.stop()
PY

    # Exercise the same three course notebooks inside NixOS. Jupyter needs a
    # writable working directory; the bundled source in the Nix store is read-only.
    cp -R ${courseExamples} "$HOME/course-notebooks"
    chmod -R u+w "$HOME/course-notebooks"
    export RSM_HDFS_STATE="$HOME/hdfs-notebooks"
    export HADOOP_CONF_DIR="$RSM_HDFS_STATE/conf"
    export HADOOP_LOG_DIR="$RSM_HDFS_STATE/logs"
    export HADOOP_PID_DIR="$RSM_HDFS_STATE/pids"
    export PYSPARK_PYTHON="${notebookPython}/bin/python3"
    export PYSPARK_DRIVER_PYTHON="$PYSPARK_PYTHON"
    mkdir -p "$HOME/.local/share/jupyter/kernels/spark-hadoop"
    cat > "$HOME/.local/share/jupyter/kernels/spark-hadoop/kernel.json" <<EOF
{"argv": ["${sparkHadoop.runner}/bin/rsm-spark-hadoop", "${notebookPython}/bin/python3", "-m", "ipykernel_launcher", "-f", "{connection_file}"], "display_name": "Python (Spark/Hadoop)", "language": "python"}
EOF
    export JUPYTER_PATH="$HOME/.local/share/jupyter"
    rsm-hdfs init
    ${notebookPython}/bin/python3 ${../tests/run-course-notebooks.py} "$HOME/course-notebooks"
  '';
in
pkgs.testers.runNixOSTest {
  name = "scalable-analytics";
  nodes.machine = { ... }: {
    virtualisation.memorySize = 6144;
    virtualisation.diskSize = 8192;
    users.users.student = {
      isNormalUser = true;
      home = "/home/student";
      createHome = true;
    };
    environment.systemPackages = [ sparkHadoop.runner ];
  };
  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("su - student -c 'rsm-spark-hadoop bash ${vmCheck}'")
  '';
}
