#!/usr/bin/env bash
# Uses installed plugins; does not sync/upgrade plugins or alter the lockfile.
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
ln -s "$repo/home/.config/nvim" "$tmp/nvim"
export XDG_CONFIG_HOME="$tmp"
export DOTFILES_AUDIT_TEST="$repo/scripts/test-nvim-audit.lua"
nvim --headless \
  -c 'lua local ok, err = pcall(dofile, vim.env.DOTFILES_AUDIT_TEST); if not ok then print(err); vim.cmd("cquit 1") end' \
  -c 'qa!'
