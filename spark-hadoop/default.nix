# Optional Spark/Hadoop profile for the RSM-MSBA flake.
#
# Reuses the proven Spark 3.5 / Hadoop approach from rsm-podman-nix/spark-hadoop:
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
  spark = sparkPackagesNoR.spark_3_5.overrideAttrs (old: {
    # Force the JDK Spark bakes into its launcher wrappers (--set JAVA_HOME).
    # By default spark 3.5 derives this from hadoop.jdk = jdk11_headless, and
    # the Nix linux-aarch64 OpenJDK 11 build crashes under real Spark workloads
    # (ObjectSynchronizer::inflate) — Windows-ARM/WSL students would hit this.
    # Spark 3.5 fully supports Java 17, so pin the stable jdk17 everywhere.
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
in
{
  inherit hadoop java spark sparkHadoopEnv envHook proof;
}
