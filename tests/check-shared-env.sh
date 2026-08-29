# check-shared-env.sh
#
# The shared nix-uv environment must be IMPOSSIBLE to clobber from a project
# folder, while still being the DEFAULT interpreter in a folder that has no
# .venv of its own. Run in the dev shell:
#   nix develop -c bash tests/check-shared-env.sh
#
# Background: `uv sync` does not install into its target, it makes the target
# MATCH pyproject.toml + uv.lock -- removing everything the project does not
# list. When that target was the shared env, one `uv sync` in one course folder
# pruned the Python every other folder shares. Three independent layers now stop
# that, and this file tests each one SEPARATELY so a regression in any single
# layer is visible even though the other two would still save the day:
#
#   1. bin/rsm-env.sh    no longer defaults UV_PROJECT_ENVIRONMENT to the shared env
#   2. the managed .envrc pins UV_PROJECT_ENVIRONMENT=$PWD/.venv unconditionally
#   3. bin/uv           refuses a mutating command aimed at the shared env
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v uv >/dev/null 2>&1 || { echo "uv not on PATH (run inside the dev shell)"; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_WORKSPACE="$tmp/ws"
export RSMBASE="$RSM_WORKSPACE/.rsm-msba"
export RSM_UV_ENV="$RSMBASE/envs/nix-uv"
mkdir -p "$RSM_WORKSPACE" "$RSMBASE/zsh"

# A stand-in for the shared env holding a REAL installed distribution that no
# project below depends on -- the stand-in for numpy/polars. It must be a proper
# package with metadata, not a hand-made directory: `uv sync` prunes what it has
# records for and would leave a bare mkdir alone, so a fake canary could never
# die and the whole suite would be false comfort.
RSM_ALLOW_SHARED_SYNC=1 uv venv "$RSM_UV_ENV" >/dev/null 2>&1
# iniconfig, deliberately: no command below installs it, so nothing can put it
# back and mask a leak. (typing-extensions would be re-added by the `uv add` and
# `uv pip install` probes further down and the canary could never stay dead.)
RSM_ALLOW_SHARED_SYNC=1 uv pip install --python "$RSM_UV_ENV/bin/python" \
  iniconfig >/dev/null 2>&1 \
  || { echo "setup: could not install the canary package into the test env" >&2; exit 1; }
canary_alive() {
  find "$RSM_UV_ENV/lib" -maxdepth 3 -name 'iniconfig*' 2>/dev/null | grep -q .
}
canary_alive || { echo "setup: canary did not install; aborting" >&2; exit 1; }

cd "$RSM_WORKSPACE"
mkdir -p proj
printf '[project]\nname = "proj"\nversion = "0.1.0"\nrequires-python = ">=3.13"\ndependencies = []\n\n[tool.uv]\npackage = false\n' > proj/pyproject.toml

echo "== layer 1: rsm-env.sh no longer aims uv at the shared env =="
if [ "${UV_PROJECT_ENVIRONMENT:-}" = "$RSM_UV_ENV" ]; then
  bad "UV_PROJECT_ENVIRONMENT still defaults to the shared env"
else
  ok "UV_PROJECT_ENVIRONMENT does not default to the shared env"
fi

echo "== layer 1: a bare 'uv sync' with NO env vars creates ./.venv, not the shared env =="
( cd proj && env -u UV_PROJECT_ENVIRONMENT -u VIRTUAL_ENV uv sync >/dev/null 2>&1 )
[ -d proj/.venv ] && ok "uv sync created ./.venv" || bad "uv sync did not create ./.venv"
canary_alive && ok "shared env untouched" || bad "shared env was pruned"
rm -rf proj/.venv

echo "== the reported scenario: VIRTUAL_ENV points at the shared env (no local .venv yet) =="
# This is a folder you just cd'd into: nix-uv is the ACTIVE interpreter, but uv
# must still not write there. VIRTUAL_ENV must not redirect `uv sync`.
( cd proj && env -u UV_PROJECT_ENVIRONMENT VIRTUAL_ENV="$RSM_UV_ENV" uv sync >/dev/null 2>&1 )
[ -d proj/.venv ] && ok "uv sync still created ./.venv" || bad "uv sync did not create ./.venv"
canary_alive && ok "shared env untouched despite VIRTUAL_ENV pointing at it" || bad "shared env was pruned via VIRTUAL_ENV"
rm -rf proj/.venv

echo "== layer 2: the managed .envrc pins UV_PROJECT_ENVIRONMENT even with NO .venv =="
rsm-mkdir proj >/dev/null 2>&1
if grep -q 'export UV_PROJECT_ENVIRONMENT="$PWD/.venv"' proj/.envrc; then
  ok ".envrc pins UV_PROJECT_ENVIRONMENT to ./.venv"
else
  bad ".envrc does not pin UV_PROJECT_ENVIRONMENT"
fi
# ...and it must be OUTSIDE the `if .venv exists` block, or the pin never applies
# in the one situation that matters.
# Assert ORDERING, not just presence: the pin must appear BEFORE the conditional.
if awk '/^export UV_PROJECT_ENVIRONMENT/{if(!pin)pin=NR}
        /^if \[ -f "\$PWD\/\.venv\/bin\/activate" \]/{if(!cond)cond=NR}
        END{exit !(pin>0 && cond>0 && pin<cond)}' proj/.envrc; then
  ok "the pin is set before/outside the .venv conditional"
else
  bad "the pin is still inside (or after) the .venv conditional"
fi

echo "== layer 2: nix-uv is STILL the default interpreter when there is no .venv =="
# Activation must remain conditional -- that is the behaviour we want to keep.
# VIRTUAL_ENV must be exported ONLY after the conditional opens -- if it moved
# above the `if`, every folder would claim a .venv that may not exist.
if awk '/^if \[ -f "\$PWD\/\.venv\/bin\/activate" \]/{if(!cond)cond=NR}
        /^ *export VIRTUAL_ENV=/{if(!ve)ve=NR}
        END{exit !(cond>0 && ve>0 && ve>cond)}' proj/.envrc; then
  ok "VIRTUAL_ENV is only exported when ./.venv exists (nix-uv stays the default)"
else
  bad "activation is no longer conditional on ./.venv"
fi

echo "== layer 3: the uv guard refuses mutating commands aimed at the shared env =="
guard() { # guard WANT LABEL cmd...
  local want="$1" label="$2" got=0; shift 2
  if "$@" >/dev/null 2>&1; then got=0; else got="$?"; fi
  if [ "$got" -eq "$want" ]; then ok "$label (exit $got)"; else bad "$label: wanted exit $want, got $got"; fi
}
cd "$RSM_WORKSPACE/proj"
guard 3 "uv sync at the shared env"    env UV_PROJECT_ENVIRONMENT="$RSM_UV_ENV" uv sync
guard 3 "uv add at the shared env"     env UV_PROJECT_ENVIRONMENT="$RSM_UV_ENV" uv add typing-extensions
guard 3 "uv remove at the shared env"  env UV_PROJECT_ENVIRONMENT="$RSM_UV_ENV" uv remove typing-extensions
guard 3 "uv pip install via VIRTUAL_ENV" env -u UV_PROJECT_ENVIRONMENT VIRTUAL_ENV="$RSM_UV_ENV" uv pip install typing-extensions
canary_alive && ok "shared env survived every refused command" || bad "a refused command still wrote to the shared env"

echo "== layer 3 must FAIL OPEN: harmless commands still work =="
guard 0 "uv --version"                 uv --version
guard 0 "uv sync at a LOCAL .venv"     env UV_PROJECT_ENVIRONMENT="$PWD/.venv" uv sync
guard 0 "uv pip list at the shared env" env -u UV_PROJECT_ENVIRONMENT VIRTUAL_ENV="$RSM_UV_ENV" uv pip list

echo "== a poisoned UV_PROJECT_ENVIRONMENT from an OLD shell is repaired on entry =="
# Removing the default cannot help a shell that was already running when the fix
# landed -- the old value lives in that process and is inherited by every
# terminal it spawns. The shell hook clears it.
_hook="${RSM_FLAKE:-$HOME/rsm-nix}/shell/rsm-shell-hook.sh"
if [ -f "$_hook" ]; then
  _got="$(env UV_PROJECT_ENVIRONMENT="$RSM_UV_ENV" RSMBASE="$RSMBASE" RSM_UV_ENV="$RSM_UV_ENV" \
      bash -c ". '$_hook' >/dev/null 2>&1; echo \"\${UV_PROJECT_ENVIRONMENT:-<unset>}\"" 2>/dev/null)"
  if [ "$_got" = "<unset>" ]; then
    ok "shell hook clears an inherited shared-env pointer"
  else
    bad "inherited shared-env pointer survived the shell hook: $_got"
  fi
  # ...but a LOCAL project pointer must be left alone.
  _got2="$(env UV_PROJECT_ENVIRONMENT="/tmp/someproj/.venv" RSMBASE="$RSMBASE" RSM_UV_ENV="$RSM_UV_ENV" \
      bash -c ". '$_hook' >/dev/null 2>&1; echo \"\${UV_PROJECT_ENVIRONMENT:-<unset>}\"" 2>/dev/null)"
  if [ "$_got2" = "/tmp/someproj/.venv" ]; then
    ok "a project-local pointer is left untouched"
  else
    bad "the hook clobbered a project-local pointer: $_got2"
  fi
else
  bad "could not find rsm-shell-hook.sh to test"
fi

echo "== the escape hatch still works (rsm-python-sync's route) =="
if env RSM_ALLOW_SHARED_SYNC=1 UV_PROJECT_ENVIRONMENT="$RSM_UV_ENV" uv sync >/dev/null 2>&1; then
  ok "RSM_ALLOW_SHARED_SYNC=1 permits a deliberate shared-env sync"
else
  bad "the escape hatch is broken -- rsm-python-sync could not rebuild nix-uv"
fi

[ "$fail" -eq 0 ] && echo "shared-env check passed." || { echo "shared-env check FAILED." >&2; exit 1; }
