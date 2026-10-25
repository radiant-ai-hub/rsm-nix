# Optional Spark/Hadoop profile for the RSM-MSBA flake.
#
# Reuses the Spark / Hadoop approach from rsm-podman-nix/spark-hadoop:
# build Spark without R support and patch SPARK_DIST_CLASSPATH so it uses a
# filtered Hadoop classpath (no YARN, no shuffle jar) for local execution.
#
# Returns an attrset of derivations the top-level flake wires into devShells,
# packages, and apps. `pythonEnvBin` is the path to the interpreter PySpark
# should drive (the uv base env when present, else the Nix python).
{ pkgs, python }:
let
  sparkPackagesNoR = pkgs.callPackage
    "${pkgs.path}/pkgs/applications/networking/cluster/spark" {
      R = null;
      RSupport = false;
    };
  hadoop = pkgs.hadoop;
  java = pkgs.openjdk17_headless;
  spark = sparkPackagesNoR.spark_4_0.overrideAttrs (old: {
    # Force the JDK Spark bakes into its launcher wrappers (--set JAVA_HOME).
    # By default spark 3.5 derives this from hadoop.jdk = jdk11_headless, and
    # the Nix linux-aarch64 OpenJDK 11 build crashes under real Spark workloads
    # (ObjectSynchronizer::inflate) — Windows-ARM/WSL students would hit this.
    # Spark 4.0 fully supports Java 17, so pin the stable jdk17 everywhere.
    jdk = java;
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    postFixup = (old.postFixup or "") + ''
      filtered_hadoop_classpath="$(
        ${hadoop}/bin/hadoop classpath \
          | tr ':' '\n' \
          | grep -v '/share/hadoop/yarn' \
          | grep -v '/spark-[0-9].*-yarn-shuffle[.]jar$' \
          | paste -sd ':'
      )"

      for spark_bin in "$out"/bin/*; do
        if [ -f "$spark_bin" ]; then
          sed -i \
            "s|^\[ -z  \] && export SPARK_DIST_CLASSPATH=.*$|[ -z \"''${SPARK_DIST_CLASSPATH:-}\" ] \&\& export SPARK_DIST_CLASSPATH=$filtered_hadoop_classpath|" \
            "$spark_bin"
        fi
      done
    '';
  });

  sparkHadoopEnv = pkgs.buildEnv {
    name = "rsm-spark-hadoop-env";
    paths = [ hadoop java spark ];
    ignoreCollisions = true;
    pathsToLink = [ "/bin" "/lib" "/share" ];
  };

  hdfsCtl = pkgs.writeShellApplication {
    name = "rsm-hdfs";
    runtimeInputs = [ pkgs.coreutils hadoop java ];
    text = builtins.readFile ../bin/rsm-hdfs;
  };

  # Shell snippet that wires the Spark/Hadoop environment variables. Shared by
  # the devShell hook and the standalone proof app so behaviour matches.
  envHook = ''
    export JAVA_HOME="${java}"
    export SPARK_HOME="${spark}"
    export HADOOP_HOME="${hadoop}"
    export SPARK_LOCAL_HOSTNAME="localhost"
    : "''${PYSPARK_PYTHON:=${python}/bin/python3}"
    : "''${PYSPARK_DRIVER_PYTHON:=${python}/bin/python3}"
    export PYSPARK_PYTHON PYSPARK_DRIVER_PYTHON

    SPARK_DIST_CLASSPATH="$(
      ${hadoop}/bin/hadoop classpath \
        | tr ':' '\n' \
        | grep -v '/share/hadoop/yarn' \
        | grep -v '/spark-[0-9].*-yarn-shuffle[.]jar$' \
        | paste -sd ':'
    )"
    export SPARK_DIST_CLASSPATH

    export HADOOP_CONF_DIR="''${RSM_HDFS_STATE:-''${RSMBASE:-$HOME/rsm-msba/.rsm-msba}/hdfs}/conf"
    export HADOOP_LOG_DIR="''${RSM_HDFS_STATE:-''${RSMBASE:-$HOME/rsm-msba/.rsm-msba}/hdfs}/logs"
    export HADOOP_PID_DIR="''${RSM_HDFS_STATE:-''${RSMBASE:-$HOME/rsm-msba/.rsm-msba}/hdfs}/pids"

    spark_python="$SPARK_HOME/python"
    if [ ! -d "$spark_python/pyspark" ]; then
      spark_python="$(find "$SPARK_HOME" -type d -path '*/python/pyspark' -print -quit)"
      spark_python="''${spark_python%/pyspark}"
    fi
    py4j_zip="$(find "$SPARK_HOME" -type f -path '*/python/lib/py4j-*.zip' -print -quit)"
    export PYTHONPATH="$spark_python:$py4j_zip''${PYTHONPATH:+:$PYTHONPATH}"
  '';

  proof = pkgs.writeShellApplication {
    name = "rsm-spark-hadoop-proof";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.procps
      hadoop
      java
      python
      spark
      hdfsCtl
    ];
    text = ''
      ${envHook}

      echo "== Hadoop =="
      hadoop version

      echo "== Spark =="
      spark-submit --version

      echo "== PySpark local session =="
      python3 - <<'PY'
      from pyspark.sql import SparkSession

      spark = (
          SparkSession.builder.master("local[1]")
          .appName("rsm-spark-hadoop-proof")
          .config("spark.ui.enabled", "false")
          .getOrCreate()
      )
      print("pyspark-count", spark.range(3).count())
      spark.stop()
      PY
    '';
  };

  runner = pkgs.writeShellApplication {
    name = "rsm-spark-hadoop";
    runtimeInputs = [
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.procps
      hadoop
      java
      python
      spark
      hdfsCtl
    ];
    text = ''
      rsm_uv_env="''${RSM_UV_ENV:-}"
      if [ -n "$rsm_uv_env" ] && [ -x "$rsm_uv_env/bin/python3" ]; then
        export PYSPARK_PYTHON="$rsm_uv_env/bin/python3"
        export PYSPARK_DRIVER_PYTHON="$rsm_uv_env/bin/python3"
      fi
      unset rsm_uv_env
      ${envHook}

      if [ "$#" -eq 0 ]; then
        exec bash
      fi
      exec "$@"
    '';
  };

  kernelInstall = pkgs.writeShellApplication {
    name = "rsm-spark-kernel-install";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      base="''${RSMBASE:-$HOME/rsm-msba/.rsm-msba}"
      python="''${RSM_UV_ENV:-$base/envs/nix-uv}/bin/python"
      if [ ! -x "$python" ]; then
        echo "Run rsm-setup to create the shared Python environment first" >&2
        exit 1
      fi
      kernel_dir="$base/jupyter/kernels/spark-hadoop"
      mkdir -p "$kernel_dir"
      cat > "$kernel_dir/kernel.json" <<EOF
      {
        "argv": ["${runner}/bin/rsm-spark-hadoop", "$python", "-m", "ipykernel_launcher", "-f", "{connection_file}"],
        "display_name": "Python (Spark/Hadoop)",
        "language": "python",
        "env": {
          "RSMBASE": "$base",
          "RSM_UV_ENV": "''${RSM_UV_ENV:-$base/envs/nix-uv}",
          "RSM_WORKSPACE": "''${RSM_WORKSPACE:-$HOME/rsm-msba}"
        }
      }
      EOF
      echo "Installed Python (Spark/Hadoop) kernel at $kernel_dir"
    '';
  };
in
{
  inherit hadoop java spark sparkHadoopEnv envHook proof runner hdfsCtl kernelInstall;
}
