# CLI Backup/Restore Redesign

**Date:** 2026-04-02
**Status:** Draft

## Problem

The current `./cli` is a 1,581-line monolith with 13 commands/subcommands. Many commands overlap conceptually (`install`, `reinstall`, `prereq`), and the mental model is unclear. The user wants a simple backup/restore paradigm.

## New Command Surface

| Command | Purpose |
|---------|---------|
| `cli backup` | `chezmoi re-add` — capture live system changes back into repo |
| `cli restore [--force]` | Prereqs + `chezmoi apply`. `--force` wipes state first (clean-slate reinstall) |
| `cli conda build` | Build new timestamped conda env, validate, swap prod symlink |
| `cli conda status` | Show current prod env, versions, available envs |
| `cli conda rollback` | Revert prod symlink to previous env |
| `cli conda nuke` | Destroy all envs and rebuild from scratch |
| `cli conda install-timer` | Install systemd timer for weekly auto-rebuild |
| `cli status` | Show installation status |
| `cli help` | Help text |

**Removed:** `prereq` (folded into restore), `install` (replaced by restore), `reinstall` (replaced by restore --force), `uninstall` (dropped), `update` (dropped), `update status` (dropped), `update install-timer` (dropped).

## File Structure

```
~/.files/
  cli                       # ~100 lines: dispatch, config vars, source lib/*.sh
  lib/
    common.sh               # ~80 lines: colors, logging, has_cmd, ensure_chezmoi, is_local_source
    platform.sh             # ~200 lines: detect_platform, pkg_install, pkg_update,
                            #   get_pkg_name, install_homebrew, install_1password_cli
    backup.sh               # ~30 lines: cmd_backup() — chezmoi re-add with summary
    restore.sh              # ~250 lines: cmd_restore() — prereq + chezmoi apply + conda
                            #   ensure_conda, ensure_conda_env, install_essential_tools,
                            #   create_default_config. --force wipes state first.
    conda.sh                # ~200 lines: cmd_conda() dispatcher + build/nuke/rollback/
                            #   status/install-timer (sources env/lib/build.sh, validate.sh)
    status.sh               # ~60 lines: cmd_status()
```

Existing `env/lib/build.sh` and `env/lib/validate.sh` stay where they are — `conda.sh` sources them.

All `lib/*.sh` files are sourced relative to `SCRIPT_DIR` (resolved in `cli` via `dirname "${BASH_SOURCE[0]}"`). Each lib file assumes the caller has already set `SCRIPT_DIR` and sourced `lib/common.sh`.

## Command Behavior

### `cli backup`

1. Run `chezmoi re-add` (captures all changed managed files back into source)
2. Show summary: list of files that were updated
3. Print hint: `Run 'git diff' to review, then 'git commit && git push'`

No flags, no options.

### `cli restore [--force]`

**Normal path** (no flag):

1. `ensure_chezmoi` — install chezmoi if missing
2. Detect platform + install missing prereqs (system packages, 1Password CLI, chezmoi)
3. `chezmoi init` — from local source if available, else from `CHEZMOI_REPO`
4. `chezmoi apply`
5. `ensure_conda` + `ensure_conda_env` — Linux only, skip if already present
6. `install_essential_tools` — fallback if no conda env provides them
7. Print status summary

**Force path** (`--force`):

1. Wipe chezmoi state (`$CHEZMOI_SOURCE` + `chezmoistate.boltdb`)
2. Remove external dependencies (tpm, zinit, lazy.nvim, fzf, nvim)
3. Run the full normal restore path above
4. Additionally run `chezmoi apply --refresh-externals`

Idempotent — safe to run multiple times. On a fresh machine, `cli restore` is the only command needed.

### `cli conda <sub>`

Identical to today's `cli env` behavior, renamed:

- `conda build` — create timestamped env, install packages from `env/config/*.txt`, validate, swap prod symlink, clean up envs older than 30 days
- `conda status` — show prod symlink target, Python/Node versions, list all envs
- `conda rollback` — revert prod symlink to `.prod-previous`
- `conda nuke` — destroy all `acap-*` envs + prod symlink, then rebuild
- `conda install-timer` — install systemd user timer (weekly Sun 04:00)

### `cli status`

Identical to today. References updated to say `cli restore` instead of `cli install`.

### `cli help`

Updated help text reflecting the new command surface.

## Migration from Current Code

### What moves where

| Current function | New location | Notes |
|-----------------|-------------|-------|
| Colors, logging (`info`, `success`, etc.) | `lib/common.sh` | Extracted as-is |
| `has_cmd`, `ensure_chezmoi`, `is_local_source` | `lib/common.sh` | Extracted as-is |
| `detect_platform`, `pkg_install`, `pkg_update`, `get_pkg_name` | `lib/platform.sh` | Extracted as-is |
| `install_homebrew`, `install_1password_cli` | `lib/platform.sh` | Extracted as-is |
| `create_default_config` | `lib/restore.sh` | Used only by restore |
| `ensure_conda`, `ensure_conda_env`, `install_essential_tools` | `lib/restore.sh` | Used only by restore |
| `cmd_prereq` | `lib/restore.sh` | Logic absorbed into `cmd_restore` |
| `cmd_install` | `lib/restore.sh` | Logic absorbed into `cmd_restore` |
| `cmd_reinstall` | `lib/restore.sh` | Logic absorbed into `cmd_restore --force` |
| `cmd_env*` | `lib/conda.sh` | Renamed `env` → `conda` |
| `cmd_status` | `lib/status.sh` | Extracted as-is |
| `cmd_uninstall` | **deleted** | No longer needed |
| `cmd_update*` | **deleted** | Covered by restore |
| `cmd_help` | `cli` (main dispatcher) | Inline in dispatcher |

### What stays untouched

- `env/lib/build.sh` — conda build pipeline
- `env/lib/validate.sh` — post-build validation
- `env/lib/cli-tools.sh` — standalone binary installs
- `env/lib/auto-update.sh` — auto-update utilities
- `env/config/*` — package lists
- `env/auto-upgrade.service`, `env/auto-upgrade.timer` — systemd units
- `.chezmoiscripts/*` — chezmoi lifecycle hooks

## CLAUDE.md Updates

After refactoring, update the `cli` section in `.claude/CLAUDE.md` to reflect:
- New command names (`backup`, `restore`, `conda`)
- Removed commands (`prereq`, `install`, `reinstall`, `uninstall`, `update`)
- Updated quick start examples
