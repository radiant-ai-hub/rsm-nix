# MGTA 466 Scalable Analytics examples

These three notebooks and `Shakespeare.txt` are bundled with `rsm-nix`, so
students do not need to clone `rsm-podman`. They come from the
[`rsm-podman` Scalable Analytics test folder](https://github.com/radiant-ai-hub/rsm-podman/tree/53b78c138b0b093e7ecf2ebbffce98fd6d4480e2/files/scalable_analytics/test).
The copies use the **Python (Spark/Hadoop)** kernel; the PySpark example limits
itself to one local worker for shared-server use.

Run `rsm-update` once, then `rsm-scalable` to open the course environment in
`~/rsm-msba/mgta466`. Open `examples/test` in VS Code. `rsm-scalable check`
runs all three notebooks against temporary HDFS data and stops the daemons at
the end. For an interactive HDFS exercise, run `rsm-hdfs init`,
`rsm-hdfs start`, and `rsm-hdfs stop` from the `rsm-scalable` shell.

The last section of `hdfs-handson-test.ipynb` calls `rsm-hdfs reset --yes` and
erases the exercise HDFS data. Skip that section if you want to keep it.
