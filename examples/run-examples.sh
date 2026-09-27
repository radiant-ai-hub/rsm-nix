#!/usr/bin/env bash
# run-examples.sh — run the non-interactive examples as a quick full-functionality
# check. Run from the workspace root inside the dev shell:
#
#     nix develop -c bash examples/run-examples.sh
#
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
: "${RSM_WORKSPACE:=$HOME/rsm-msba}"
: "${RSMBASE:=$RSM_WORKSPACE/.rsm-msba}"
: "${TMPDIR:=$RSMBASE/tmp}"
: "${XDG_RUNTIME_DIR:=$RSMBASE/runtime}"
: "${JUPYTER_RUNTIME_DIR:=$RSMBASE/jupyter/runtime}"
export RSM_WORKSPACE RSMBASE TMPDIR XDG_RUNTIME_DIR JUPYTER_RUNTIME_DIR

if [ ! -d "$XDG_RUNTIME_DIR" ] || [ ! -w "$XDG_RUNTIME_DIR" ]; then
  XDG_RUNTIME_DIR="$RSMBASE/runtime"
  export XDG_RUNTIME_DIR
fi

mkdir -p "$TMPDIR" "$XDG_RUNTIME_DIR" "$JUPYTER_RUNTIME_DIR" 2>/dev/null || true
for private_dir in "$XDG_RUNTIME_DIR" "$JUPYTER_RUNTIME_DIR" "$TMPDIR"; do
  case "$private_dir" in
    "$RSMBASE"/*) chmod 700 "$private_dir" 2>/dev/null || true ;;
  esac
done
unset private_dir

cleanup_dir=""
examples_dir="$script_dir"
if [ "$script_dir" != "$RSM_WORKSPACE/examples" ] && [ -d "$RSM_WORKSPACE/examples" ]; then
  examples_dir="$RSM_WORKSPACE/examples"
fi
case "$examples_dir" in
  /nix/store/*|/opt/rsm-nix/*)
    cleanup_dir="$(mktemp -d "$TMPDIR/rsm-examples.XXXXXX")"
    cp -R "$examples_dir/." "$cleanup_dir/"
    examples_dir="$cleanup_dir"
    ;;
esac
trap '[ -n "$cleanup_dir" ] && rm -rf "$cleanup_dir"' EXIT

cd "$examples_dir"
fail=0

run() {
  local label="$1"; shift
  printf '\n########## %s ##########\n' "$label"
  if "$@"; then :; else echo ">>> $label FAILED"; fail=1; fi
}

render_quarto_report() {
  rm -f quarto_report.md
  quarto render quarto_report.qmd --quiet
  test -s quarto_report.md
}

run "check_environment.py" python check_environment.py
run "python_data_stack.py" python python_data_stack.py
run "pyrsm_example.py" python pyrsm_example.py
# Prints seeded-RNG fingerprints; compare the OVERALL line across platforms.
run "random_check.py" python random_check.py

printf '\n########## postgres_python.py ##########\n'
if command -v rsm-pg-start >/dev/null 2>&1; then
  rsm-pg-start >/dev/null 2>&1 || true
  if python postgres_python.py; then :; else echo ">>> postgres_python.py FAILED"; fail=1; fi
else
  echo "  (rsm-pg-* not on PATH; skipping)"
fi

run "quarto render quarto_report.qmd" render_quarto_report

# Notebooks: execute them headlessly if jupyter/nbconvert is available. The
# postgres notebook needs the DB, which the postgres step above started.
if jupyter nbconvert --version >/dev/null 2>&1; then
  nb_out="$(mktemp -d "$TMPDIR/rsm-nb.XXXXXX")"
  # ipykernel 7 warns "Kernel is running over TCP without encryption ..." on
  # every headless run. We're executing a trusted local notebook, so switch the
  # kernel to IPC (Unix-socket) transport — the fix the warning itself suggests.
  # Endpoint paths stay ~86 chars, well under the macOS 104-char socket limit.
  for nb in notebook_intro.ipynb notebook_pyrsm.ipynb notebook_postgres.ipynb notebook_random_check.ipynb; do
    run "execute $nb" jupyter nbconvert --to notebook --execute --output-dir "$nb_out" \
      --KernelManager.transport=ipc "$nb"
  done
  rm -rf "$nb_out"
else
  echo "  (jupyter nbconvert not available; skipping notebook execution)"
fi

printf '\n=================================================\n'
[ "$fail" -eq 0 ] && echo "ALL EXAMPLES PASSED" || echo "SOME EXAMPLES FAILED (see above)"
printf '(Spark is separate: nix develop .#spark-hadoop -c python examples/spark_pyspark.py)\n'
exit "$fail"
