#!/usr/bin/env bash
# run-examples.sh — run the non-interactive examples as a quick full-functionality
# check. Run from the workspace root inside the dev shell:
#
#     nix develop -c bash examples/run-examples.sh
#
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$here"
fail=0

run() {
  local label="$1"; shift
  printf '\n########## %s ##########\n' "$label"
  if "$@"; then :; else echo ">>> $label FAILED"; fail=1; fi
}

run "check_environment.py" python check_environment.py
run "python_data_stack.py" python python_data_stack.py
run "pyrsm_example.py" python pyrsm_example.py

printf '\n########## postgres_python.py ##########\n'
if command -v rsm-pg-start >/dev/null 2>&1; then
  rsm-pg-start >/dev/null 2>&1 || true
  if python postgres_python.py; then :; else echo ">>> postgres_python.py FAILED"; fail=1; fi
else
  echo "  (rsm-pg-* not on PATH; skipping)"
fi

run "quarto render quarto_report.qmd" quarto render quarto_report.qmd --quiet

# Notebooks: execute them headlessly if jupyter/nbconvert is available. The
# postgres notebook needs the DB, which the postgres step above started.
if jupyter nbconvert --version >/dev/null 2>&1; then
  # ipykernel 7 warns "Kernel is running over TCP without encryption ..." on
  # every headless run. We're executing a trusted local notebook, so switch the
  # kernel to IPC (Unix-socket) transport — the fix the warning itself suggests.
  # Endpoint paths stay ~86 chars, well under the macOS 104-char socket limit.
  for nb in notebook_intro.ipynb notebook_pyrsm.ipynb notebook_postgres.ipynb; do
    run "execute $nb" jupyter nbconvert --to notebook --execute --output-dir /tmp/rsm-nb \
      --KernelManager.transport=ipc "$nb"
  done
  rm -rf /tmp/rsm-nb
else
  echo "  (jupyter nbconvert not available; skipping notebook execution)"
fi

printf '\n=================================================\n'
[ "$fail" -eq 0 ] && echo "ALL EXAMPLES PASSED" || echo "SOME EXAMPLES FAILED (see above)"
printf '(Spark is separate: nix develop .#spark-hadoop -c python examples/spark_pyspark.py)\n'
exit "$fail"
