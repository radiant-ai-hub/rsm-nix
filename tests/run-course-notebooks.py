"""Execute the original Scalable Analytics notebooks using the Nix profile."""
import pathlib
import sys

import nbformat
from nbclient import NotebookClient

folder = pathlib.Path(sys.argv[1]).resolve()
for name in (
    "check-pyspark.ipynb",
    "check-hdfs-setup.ipynb",
    "hdfs-handson-test.ipynb",
):
    print(f"Running {name}", flush=True)
    notebook = nbformat.read(folder / name, as_version=4)
    NotebookClient(
        notebook,
        timeout=180,
        kernel_name="spark-hadoop",
        resources={"metadata": {"path": str(folder)}},
    ).execute()
    print(f"Passed {name}", flush=True)
