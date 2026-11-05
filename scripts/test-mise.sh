#!/usr/bin/env bash
# Integration smoke test: real mise/runtimes, isolated HOME, no live Stow changes.
# Prerequisites: mise and the versions in home/.config/mise/config.toml installed.
# The child Zsh, not this Bash process, must expand the quoted test programs.
# shellcheck disable=SC2016
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mise_bin="$(command -v mise)"
data_dir="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/.config/mise" "$tmp/project" "$tmp/.cache"
ln -s "$repo/home/.zshenv" "$tmp/.zshenv"
ln -s "$repo/home/.zshrc" "$tmp/.zshrc"
ln -s "$repo/home/zsh" "$tmp/zsh"
ln -s "$repo/home/.config/mise/config.toml" "$tmp/.config/mise/config.toml"
cd "$tmp"

# Strip inherited asdf tool paths, mise overrides, credentials, and activation.
clean_env=(env -i "HOME=$tmp" "ZDOTDIR=$tmp" "SHELL=/bin/zsh"
  "TERM=${TERM:-xterm-256color}" "MISE_DATA_DIR=$data_dir"
  "PATH=$(dirname "$mise_bin"):/usr/bin:/bin:/usr/sbin:/sbin")

# Official migration path: exercise a legacy project before shell activation.
mkdir -p "$tmp/legacy"
printf 'nodejs 26.12.1\n' > "$tmp/legacy/.tool-versions"
printf '%s\n' 'require("node:assert/strict").equal(6 * 7, 42)' > "$tmp/legacy/smoke.cjs"
(
  cd "$tmp/legacy"
  "${clean_env[@]}" "$mise_bin" config ls | grep -F '.tool-versions'
  "${clean_env[@]}" "$mise_bin" ls --current node | grep -F '.tool-versions'
  [[ "$("${clean_env[@]}" "$mise_bin" exec -- node --version)" == v26.12.1 ]]
  "${clean_env[@]}" "$mise_bin" exec -- node smoke.cjs
)

for mode in -c -ic; do
  "${clean_env[@]}" zsh "$mode" '
    set -e
    [[ "$(node --version)" == v26.12.1 ]]
    [[ "$(ruby --version)" == "ruby 3.3.6 "* ]]
    [[ "$(pnpm --version)" == 10.34.4 ]]
    for tool in node ruby pnpm; do
      [[ "$(command -v "$tool")" == "$MISE_DATA_DIR/"* ]]
    done
  '
done

"${clean_env[@]}" zsh -ic '
  set -e
  mise doctor
  node-use 26.12.1
  [[ "$MISE_NODE_VERSION" == 26.12.1 ]]
  [[ "$(node --version)" == v26.12.1 ]]
  mise shell --unset node
  if node-use; then exit 1; else [[ $? == 2 ]]; fi
  if node-install; then exit 1; else [[ $? == 2 ]]; fi
  node-list
'

# A project can override a global default without downloading another runtime.
printf '[tools]\nnode = "system"\n' > "$tmp/project/mise.toml"
"${clean_env[@]}" zsh -c '
  set -e
  cd "$HOME/project"
  mise trust
  mise ls --current node | grep -q system
'

echo 'PASS: legacy project before activation, shell resolution, helpers, and project override'
