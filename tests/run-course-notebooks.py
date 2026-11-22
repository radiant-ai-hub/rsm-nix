"""Execute the original Scalable Analytics notebooks using the Nix profile."""
import pathlib
import sys
import tempfile

import nbformat
from nbclient import NotebookClient
from jupyter_client import KernelManager

folder = pathlib.Path(sys.argv[1]).resolve()
for name in (
    "check-pyspark.ipynb",
    "check-hdfs-setup.ipynb",
    "hdfs-handson-test.ipynb",
):
    print(f"Running {name}", flush=True)
    notebook = nbformat.read(folder / name, as_version=4)
    # Unix sockets live in a private, short /tmp path. This avoids exposing
    # notebook traffic over TCP on a shared teaching server, and stays below
    # macOS's Unix socket path limit.
    with tempfile.TemporaryDirectory(prefix="rsm-ipc-") as ipc_dir:
        manager = KernelManager(
            kernel_name="spark-hadoop",
            transport="ipc",
            ip=str(pathlib.Path(ipc_dir) / "kernel"),
        )
        NotebookClient(
            notebook,
            km=manager,
            timeout=180,
            kernel_name="spark-hadoop",
            resources={"metadata": {"path": str(folder)}},
        ).execute()
    print(f"Passed {name}", flush=True)
