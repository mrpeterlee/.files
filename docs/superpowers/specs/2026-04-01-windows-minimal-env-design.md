# Windows Minimal Environment Refactor

**Date:** 2026-04-01
**Status:** Approved

## Problem

The Windows/cmd side of the dotfiles repo installs a full dev environment (Neovim, Oh My Posh, fzf, fd, delta, conda hook, etc.) that duplicates what WSL provides. The Windows host only needs enough tooling to run Claude Code comfortably. All real development happens in WSL.

## Two-Environment Model

| Environment | Purpose | Tooling |
|-------------|---------|---------|
| **cmd/PowerShell** (native Windows) | Minimal host for Claude Code | **winget:** 1Password CLI, ripgrep, bat, zoxide, eza. **conda:** lazygit. **system:** git (`D:\tool\git`), chezmoi. **Configs:** WezTerm, GlazeWM, Windows Terminal, lazygit, WSL, PowerShell profile. |
| **WSL** | Full dev environment | Standard Linux treatment via `cli install` — conda env, zsh, tmux, neovim, all terminal utilities. No customization vs a regular Linux host. |

## Changes

### 1. Trim winget packages (`run_once_before_00-install-packages.ps1.tmpl`)

**Remove** (7 packages):
- `Neovim.Neovim`
- `wez.wezterm` (assumed pre-installed)
- `JanDeDobbeleer.OhMyPosh`
- `junegunn.fzf`
- `sharkdp.fd`
- `dandavison.delta`
- `jesseduffield.lazygit` (comes from conda)

**Keep** (3 packages):
- `AgileBits.1Password.CLI`
- `BurntSushi.ripgrep.MSVC`
- `sharkdp.bat`

**Add** (2 packages):
- `ajeetdsouza.zoxide`
- `eza-community.eza`

Final count: 5 winget packages.

### 2. Strip PowerShell profile (`dot_config/powershell/profile.ps1.tmpl`)

**Keep:**
- PATH additions (`~/.local/bin`, `D:\tool\git\cmd`)
- PSReadLine (Vi mode, prediction, tab complete)
- eza-based `ls`/`ll`/`lt`/`lm`/`lb` functions
- bat-based `cat` override
- zoxide init
- Navigation helpers (`..`, `...`, `....`, `cg`)
- `myip` helper
- Aliases: `g` (git), `lg` (lazygit), `cm` (chezmoi), `e` (exit)

**Replace:**
- Conda hook (`conda-hook.ps1`) → simple PATH append for `D:\tool\conda\envs\paper\Library\bin` (provides lazygit)

**Remove:**
- Oh My Posh init block
- fzf integration block
- ripgrep `$env:RIPGREP_CONFIG_PATH` / rg function wrapper
- `v` alias (nvim)

### 3. Delete nvim setup script

Delete `run_once_after_50-setup-nvim.ps1.tmpl` entirely. No Neovim config, no Lazy.nvim sync, no Mason update on Windows.

### 4. Symlinks (`run_once_after_60-setup-symlinks.ps1.tmpl`)

No changes needed. The nvim appdata symlink is created by `run_once_after_50-setup-nvim.ps1.tmpl` (deleted in Section 3), not by the symlinks script. All remaining symlinks stay:

- Windows Terminal settings
- GlazeWM config
- WSL config
- Lazygit config
- PowerShell profile
- `~/.files` junction

### 5. Update `.chezmoiignore`

Add to the Windows exclusion block:
```
.config/nvim/**
```

Nvim config is no longer deployed to Windows.

### 6. Update `cli.ps1`

**`Invoke-Status` tool checks** — change from:
```
nvim, bat, rg, fzf, lazygit, eza, oh-my-posh, delta, zoxide, op
```
to:
```
bat, rg, lazygit, eza, zoxide, op
```

**`Invoke-Status` config checks** — remove nvim and oh-my-posh entries.

**`Invoke-Status` symlink checks** — remove nvim appdata entry.

**`Invoke-Reinstall` and `Invoke-Uninstall`** — remove Lazy.nvim cleanup blocks:
```powershell
$lazyNvim = Join-Path $env:LOCALAPPDATA "nvim-data\lazy\lazy.nvim"
if (Test-Path $lazyNvim) { Remove-Item $lazyNvim -Recurse -Force }
```
Neovim is no longer installed on Windows, so this dead cleanup code should be removed.

### 7. Document in CLAUDE.md

Add a "Windows Environment Model" section explaining:
- cmd/PowerShell = minimal Claude Code host
- WSL = full dev environment via standard `cli install`
- Tools that live on each side and why

## Files Changed

| File | Action |
|------|--------|
| `.chezmoiscripts/run_once_before_00-install-packages.ps1.tmpl` | Edit: 12 → 5 packages |
| `.chezmoiscripts/run_once_after_50-setup-nvim.ps1.tmpl` | **Delete** |
| `.chezmoiscripts/run_once_after_60-setup-symlinks.ps1.tmpl` | No change (nvim symlink lives in the deleted nvim script) |
| `dot_config/powershell/profile.ps1.tmpl` | Edit: strip to minimal |
| `.chezmoiignore` | Edit: exclude nvim config on Windows |
| `cli.ps1` | Edit: trim status checks, remove nvim cleanup from reinstall/uninstall |
| `.claude/CLAUDE.md` | Edit: add Windows Environment Model section |

## Out of Scope

- WSL environment — no changes, uses existing bash `cli` as-is
- Linux/macOS paths — untouched
- Conda environment management (`cli env`) — Linux-only, unchanged
- AI agents deployment (`run_after_60-deploy-ai-agents.ps1.tmpl`) — unchanged
