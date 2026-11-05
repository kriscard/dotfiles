#!/usr/bin/env bash
# Requires installed nvim-dap, dap-ui, and Mason js-debug-adapter; no sync/update.
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ln -s "$repo/home/.config/nvim" "$tmp/nvim"
export XDG_CONFIG_HOME="$tmp"
export DOTFILES_DAP_TEST="$repo/scripts/test-javascript-dap.lua"
nvim --headless \
  -c 'lua local ok, err = pcall(dofile, vim.env.DOTFILES_DAP_TEST); if not ok then print(err); vim.cmd("cquit 1") end' \
  -c 'qa!'
