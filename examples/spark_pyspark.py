# %% [markdown]
# # Spark / PySpark — optional profile test
#
# Spark lives in the **separate** `spark-hadoop` dev shell, not the default one.
# Launch it first from the workspace root, then run this file inside it:
#
# ```bash
# nix develop .#spark-hadoop
# python examples/spark_pyspark.py
# ```
#
# (Or just run the bundled proof: `rsm-spark-hadoop-proof`.)

# %%
import os

if not os.environ.get("SPARK_HOME"):
    raise SystemExit(
        "SPARK_HOME is not set — start the Spark profile first:\n"
        "    nix develop .#spark-hadoop\n"
        "then re-run this file."
    )

# %%
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder.master("local[1]")
    .appName("rsm-examples-spark")
    .config("spark.ui.enabled", "false")
    .getOrCreate()
)

df = spark.createDataFrame([(1, "a"), (2, "b"), (3, "c")], ["id", "label"])
df.show()
print("row count:", df.count())

spark.stop()
print("PySpark OK.")
