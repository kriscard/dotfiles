# Draft: project-first asdf to mise migration

Status: proposed configuration only. Do not merge, activate, retire version
files, or uninstall asdf as part of reviewing this draft.

Authoritative sequence:
https://mise.jdx.dev/dev-tools/comparison-to-asdf.html

## Preserve the current environment

- Node `26.12.1`, Ruby `3.3.6`, pnpm `10.34.4`, QMD `2.8.3`.
- Keep asdf and its runtime data until projects work with mise. This repository
  previously exposed a rollback problem when shell links remained pointed at
  absent mise files and the home version file was still retired; prevent both.
- Do not copy or symlink asdf runtime directories into mise. Reinstall needed npm
  globals/gems and native dependencies under the selected mise runtime.
- No secret-manager migration, global `.env` change, plugin upgrade, or package
  cleanup. Preserve machine-local MCP settings without committing credentials.
- Source authored configuration stays in the single Stow `home` package.

## 1. Prove one project before activation

Keep the current shell/asdf setup while inspecting an existing project:

```bash
mise config ls
mise ls --current
mise install
mise exec -- node --version
```

Review the project's configuration and tasks before trusting or executing them.
Then run its actual dependency installation, build, tests, and dev server through
`mise exec`. Tool version output alone is not a project proof.
Inventory other required versions; not every old asdf installation needs copying.

mise reads existing `.tool-versions`, including the home file in parent lookup.
Keep shared project files when teammates use asdf. If a project should move to
`mise.toml`, review the official conversion preview first; converting is optional.

## 2. Inspect global defaults and QMD ownership

The proposed Stow target is `~/.config/mise/config.toml`, with exact versions
listed above and Node/Ruby idiomatic version-file support. Compare each entry
with the home `.tool-versions` individually rather than bulk converting it.

Install QMD under the selected mise Node, not an inherited asdf/Homebrew npm
prefix. Its bootstrap checks the mise installation's actual `bin/qmd` path.
The global npm install is pinned to `@tobilu/qmd@2.8.3`; it is not run by the test
suite. Native database and semantic checks must run with both Node and QMD
resolving from mise.

From this PR's worktree, installing into mise's own data directory does not
activate its shell integration:

```bash
MISE_GLOBAL_CONFIG_FILE="$PWD/home/.config/mise/config.toml" mise install
mise exec node@26.12.1 -- npm install -g --prefix "$(mise where node@26.12.1)" @tobilu/qmd@2.8.3
mise reshim
bash scripts/test-mise.sh
python3 scripts/test-migration-rollback.py
python3 scripts/test-qmd-runtime.py
```

The explicit npm prefix prevents a machine's npmrc from redirecting the QMD
installation back into an unrelated global prefix.

Prerequisites: mise, the declared runtimes, QMD under mise, and (for the last
command only) the existing indexed vault and local models. No test should rebuild
vault indexes, clone the vault, or print note contents.

The shell test uses a disposable HOME and sanitized PATH. It first proves that
mise reads a legacy project's `.tool-versions` and runs its Node program without
activation, then tests activation, non-interactive shims, helpers, and overrides.
The rollback test exercises actual Stow apply/unstow in a temporary home and
asserts there are no remaining migration links and saved version declarations
can be restored. This is not a substitute for real project and work-Mac testing.

CI installs the declared versions into a disposable runner, runs the isolated
migration/rollback tests, and retains the existing regression/lint/history checks.
It does not use personal vault data or claim private integration coverage.

## 3. Activate only after approval and project proof

Before changing live configuration:

1. Fetch current main, update this PR if needed, and rerun exact head/base checks.
2. Privately back up effective config, local edits, and home `.tool-versions`;
   record the pre-migration Git revision and keep a rescue terminal open.
3. Install mise, the declared runtimes, and required globals before switching
   the canonical checkout. Do not use full init/update as a migration shortcut.
4. Unstow the old package while its files still exist, then switch the canonical
   checkout to the reviewed migration revision. If the branch is checked out in
   a testing worktree, detach that clean worktree first; never force-switch over
   user edits. Do not Stow a temporary checkout onto the real home directory.
5. Inspect the complete Stow dry-run, then apply from the canonical checkout.
6. Verify both the mise config link and `90-mise.zsh` link exist. Only after all
   home version entries are represented, move the home `.tool-versions` into
   the private backup. Do not delete project-local files used by teammates.
7. Start a fresh terminal. Check `mise doctor`, runtime versions, executable
   ownership, Pi/Claude, QMD native/semantic retrieval, LSP, formatting, and DAP.
8. Exercise normal projects for a validation period before work-Mac rollout.

Removing asdf/pnpm declarations from Brewfile does not uninstall them. Do not run
blanket Homebrew cleanup. Uninstall the asdf CLI only after every required project
works; keep its runtime data longer for rollback. Cleanup is a separate approved
action, not a hook in this PR.

## 4. Roll back in the correct order

1. Preserve any new local work. Unstow the migration while the new package files
   still exist, so `90-mise.zsh` and the mise config link cannot dangle.
2. Restore the saved home version declarations and return the canonical checkout
   to the recorded pre-migration revision, without resetting unrelated edits.
3. Restow the old package and open a fresh terminal; verify asdf's runtime
   selection. If asdf was later removed, reinstall its CLI first.

Do not just switch to main after a merge: main would contain the migration too.
Use the recorded pre-migration revision. Original runtimes and private backups
remain the recovery assets; no automatic data deletion belongs in this PR.
