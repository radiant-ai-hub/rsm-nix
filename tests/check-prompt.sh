# check-prompt.sh
#
# Verifies the adaptive venv label in the RSM zsh prompt. Run in the dev shell:
#   nix develop -c bash tests/check-prompt.sh
#
# The virtualenv indicator is a RIGHT-prompt segment, and zsh hides the WHOLE
# right prompt when the line does not fit -- it never truncates a segment. So a
# long label did not shrink on a narrow terminal, it disappeared, and the shell
# looked like no environment was active. shell/zdotdir/zshrc fixes that in a
# precmd hook; this exercises that hook's logic directly with a stubbed p10k.
set -uo pipefail

fail=0
ok()  { printf '  \033[32mok\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

command -v zsh >/dev/null 2>&1 || { echo "zsh not on PATH (run inside the dev shell)"; exit 1; }
zshrc="${RSM_FLAKE:-$HOME/rsm-nix}/shell/zdotdir/zshrc"
[ -f "$zshrc" ] || { echo "cannot find $zshrc"; exit 1; }

# Pull just the hook out of the zshrc so we can drive it without a real prompt.
hook="$(sed -n '/^_rsm_venv_label()/,/^add-zsh-hook precmd _rsm_prompt_fit$/p' "$zshrc" \
        | sed '/^add-zsh-hook/d')"
[ -n "$hook" ] || { echo "could not extract the prompt hook from $zshrc"; exit 1; }

# Drive the hook: run_fit COLUMNS LABEL [VIRTUAL_ENV] -> prints the label shown
# and which segments p10k was told to hide/show.
run_fit() {
  local cols="$1" lbl="$2" venv="${3:-/tmp/proj/.venv}"
  COLUMNS="$cols" RSM_VENV_LABEL="$lbl" VIRTUAL_ENV="$venv" RSM_UV_ENV=/shared/nix-uv \
  RSM_PROMPT_COST=76 \
  zsh -f -c "
    p10k() { print -r -- \"P10K:\$*\" >&2 }
    $hook
    _rsm_prompt_fit
    print -r -- \"\$VIRTUAL_ENV_PROMPT\"
  " 2>/dev/null
}

echo "== the label grows with terminal width =="
w60="$(run_fit 60 mgta464-snowflake)"
w100="$(run_fit 100 mgta464-snowflake)"
w200="$(run_fit 200 mgta464-snowflake)"
case "$w60" in *…*) ok "narrow (60) truncates: $w60";; *) bad "narrow did not truncate: $w60";; esac
[ "$w200" = "(mgta464-snowflake) " ] && ok "wide (200) shows the full label" || bad "wide label wrong: $w200"
if [ "${#w60}" -lt "${#w100}" ] && [ "${#w100}" -le "${#w200}" ]; then
  ok "label length increases monotonically with width"
else
  bad "label does not grow with width: 60='$w60' 100='$w100' 200='$w200'"
fi

echo "== something is ALWAYS shown, never an empty label =="
for c in 40 50 60 80; do
  out="$(run_fit "$c" mgta464-snowflake)"
  case "$out" in
    "("*")"*) ok "width $c still shows a label: $out" ;;
    *) bad "width $c produced no label: '$out'" ;;
  esac
done

echo "== a label truncated when narrow GROWS BACK when the terminal widens =="
# The hook must always truncate from the FULL label. An implementation that
# re-read its own output would be permanently stuck at whatever the narrowest
# terminal produced -- resize wider and the name would never come back.
_grow="$(zsh -f -c "
    p10k() { : }
    RSM_VENV_LABEL=mgta464-snowflake
    VIRTUAL_ENV=/tmp/proj/.venv
    RSM_UV_ENV=/shared/nix-uv
    RSM_PROMPT_COST=76
    $hook
    COLUMNS=85  _rsm_prompt_fit          # narrow first
    typeset -g narrow=\$VIRTUAL_ENV_PROMPT
    COLUMNS=250 _rsm_prompt_fit          # then widen
    print -r -- \"\$narrow|\$VIRTUAL_ENV_PROMPT\"
  " 2>/dev/null)"
_was="${_grow%%|*}"; _now="${_grow##*|}"
case "$_was" in *…*) ok "narrow first truncated it: $_was";; *) bad "narrow did not truncate: $_was";; esac
if [ "$_now" = "(mgta464-snowflake) " ]; then
  ok "widening restored the full label"
else
  bad "label did not grow back after widening: '$_now' (stuck from '$_was')"
fi

echo "== fallbacks when no RSM_VENV_LABEL is exported =="
_nixuv="$(COLUMNS=200 VIRTUAL_ENV=/shared/nix-uv RSM_UV_ENV=/shared/nix-uv \
  RSM_PROMPT_COST=76 zsh -f -c "p10k(){ : }; $hook; _rsm_prompt_fit; print -r -- \"\$VIRTUAL_ENV_PROMPT\"" 2>/dev/null)"
[ "$_nixuv" = "(nix-uv) " ] && ok "shared env labels itself nix-uv" || bad "shared env label wrong: $_nixuv"
_foreign="$(COLUMNS=200 VIRTUAL_ENV=/home/u/someproj/.venv RSM_UV_ENV=/shared/nix-uv \
  RSM_PROMPT_COST=76 zsh -f -c "p10k(){ : }; $hook; _rsm_prompt_fit; print -r -- \"\$VIRTUAL_ENV_PROMPT\"" 2>/dev/null)"
[ "$_foreign" = "(someproj) " ] && ok "a foreign .venv uses its parent folder name" || bad "foreign venv label wrong: $_foreign"

echo "== crowded segments are hidden when narrow, shown when wide =="
_narrow="$(run_fit 80 mgta464-snowflake 2>&1 >/dev/null; COLUMNS=80 RSM_VENV_LABEL=mgta464-snowflake VIRTUAL_ENV=/tmp/proj/.venv RSM_UV_ENV=/shared/nix-uv \
  RSM_PROMPT_COST=76 zsh -f -c "p10k(){ print -r -- \"P10K:\$*\" }; $hook; _rsm_prompt_fit" 2>/dev/null)"
_wide="$(COLUMNS=250 RSM_VENV_LABEL=mgta464-snowflake VIRTUAL_ENV=/tmp/proj/.venv RSM_UV_ENV=/shared/nix-uv \
  RSM_PROMPT_COST=76 zsh -f -c "p10k(){ print -r -- \"P10K:\$*\" }; $hook; _rsm_prompt_fit" 2>/dev/null)"
case "$_narrow" in *context*hide*) ok "narrow hides context/time/nix_shell";; *) bad "narrow did not hide extras: $_narrow";; esac
case "$_wide" in *context*show*) ok "wide shows them again";; *) bad "wide did not restore extras: $_wide";; esac

echo "== the width budget shrinks as the path gets deeper =="
# Not a fixed constant: a deeper directory leaves less room for the label, since
# p10k prints the current folder in full on the left.
_shallow_dir="$(mktemp -d)"
_deep_dir="$_shallow_dir/aaaaaaaaaa/bbbbbbbbbb/cccccccccc/dddddddddd"
mkdir -p "$_deep_dir"
_label_at() {
  ( cd "$1" && COLUMNS=110 RSM_VENV_LABEL=mgta464-snowflake VIRTUAL_ENV=/tmp/proj/.venv \
      RSM_UV_ENV=/shared/nix-uv zsh -f -c "p10k(){ : }; $hook; _rsm_prompt_fit; print -r -- \"\$VIRTUAL_ENV_PROMPT\"" 2>/dev/null )
}
_ls="$(_label_at "$_shallow_dir")"; _ld="$(_label_at "$_deep_dir")"
if [ "${#_ld}" -lt "${#_ls}" ]; then
  ok "deeper path yields a shorter label (${#_ls} -> ${#_ld} chars)"
else
  bad "path depth did not affect the budget: shallow='$_ls' deep='$_ld'"
fi
rm -rf "$_shallow_dir"

echo "== the managed .envrc exports the full label for the hook to truncate =="
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
export RSM_WORKSPACE="$tmp/ws"; export RSMBASE="$RSM_WORKSPACE/.rsm-msba"
export RSM_UV_ENV="$RSMBASE/envs/nix-uv"
mkdir -p "$RSM_WORKSPACE" "$RSMBASE/zsh"
( cd "$RSM_WORKSPACE" && rsm-mkdir --venv rsm-mgta464-snowflake-rsm-k1xiang >/dev/null 2>&1 )
if grep -q 'export RSM_VENV_LABEL=' "$RSM_WORKSPACE/rsm-mgta464-snowflake-rsm-k1xiang/.envrc"; then
  ok ".envrc exports RSM_VENV_LABEL"
else
  bad ".envrc does not export RSM_VENV_LABEL (the hook would use the raw folder name)"
fi

[ "$fail" -eq 0 ] && echo "prompt check passed." || { echo "prompt check FAILED." >&2; exit 1; }
