#!/usr/bin/env bash
# Real tmux parser/server; external TPM is replaced with a load-count fixture.
set -euo pipefail
repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
socket="$tmp/tmux.sock"
trap 'tmux -S "$socket" kill-server 2>/dev/null || true; rm -rf "$tmp"' EXIT
mkdir -p "$tmp/.config/tmux/plugins/tpm"
ln -s "$repo/home/.config/tmux/themes" "$tmp/.config/tmux/themes"
cat > "$tmp/.config/tmux/plugins/tpm/tpm" <<'TPM'
#!/bin/sh
printf 'loaded\n' >> "$HOME/tpm-loads"
TPM
chmod +x "$tmp/.config/tmux/plugins/tpm/tpm"

for palette in macchiato frappe latte mocha default; do
  rm -f "$tmp/tpm-loads"
  flavor="$palette"
  [[ "$palette" != default ]] || flavor=''
  env -u DOTFILES HOME="$tmp" THEME_FLAVOUR="$flavor" TERM=xterm-256color \
    tmux -S "$socket" -f /dev/null new-session -d -s audit
  # Start bare, then source so startup parse errors cannot be silently missed.
  if ! tmux -S "$socket" source-file "$repo/home/.config/tmux/tmux.conf" >"$tmp/errors" 2>&1; then
    cat "$tmp/errors" >&2
    exit 1
  fi
  test "$(wc -l < "$tmp/tpm-loads" | tr -d ' ')" = 1
  test "$(tmux -S "$socket" show-environment -g TMUX_PLUGIN_MANAGER_PATH)" = \
    "TMUX_PLUGIN_MANAGER_PATH=$tmp/.config/tmux/plugins/"
  tmux -S "$socket" list-keys -T prefix | grep -E 'split-window (-fh|-h -f|-f -h)' >/dev/null
  test "$(tmux -S "$socket" show-options -gqv @catppuccin_flavor)" = "${flavor:-macchiato}"
  tmux -S "$socket" kill-server
  echo "PASS: $palette palette, one TPM load, post-plugin splits"
done
