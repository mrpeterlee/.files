#!/usr/bin/env bash
#
# deploy-host.sh — Bootstrap miniconda + shared acap env on a host
#
# Designed to be run ON the target host as peter (who owns /opt).
# Safe to re-run: skips miniconda install if /opt/conda already exists,
# and sets up each user's bashrc idempotently.
#
# Usage:
#   ./deploy-host.sh
#
set -Eeuo pipefail

CONDA_DIR="/opt/conda"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USERS=(peter toni kayden kassandra)

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m'
    BLUE='\033[0;34m' BOLD='\033[1m' RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi
info()    { echo -e "${BLUE}==>${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}!${RESET} $*"; }
error()   { echo -e "${RED}✗${RESET} $*" >&2; }

# ── Step 1: Install miniconda (skip if present) ─────────────────────────────

install_miniconda() {
    if [[ -x "${CONDA_DIR}/bin/conda" ]]; then
        success "Miniconda already installed at ${CONDA_DIR}"
        "${CONDA_DIR}/bin/conda" --version
        return 0
    fi

    info "Installing Miniconda to ${CONDA_DIR}..."
    local arch
    arch=$(uname -m)
    local url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${arch}.sh"

    local tmp
    tmp=$(mktemp /tmp/miniconda-XXXXXX.sh)
    curl -fsSLo "$tmp" "$url"
    chmod +x "$tmp"
    # Run installer in a clean subshell — it fails under set -eu and
    # detects sourcing by checking $0, so invoke via env -i.
    env -i HOME="$HOME" PATH="/usr/bin:/bin" bash "$tmp" -b -p "$CONDA_DIR"
    rm -f "$tmp"

    # Accept ToS for default channels
    CONDA_DEFAULT_ENV="" CONDA_PREFIX="" \
        "${CONDA_DIR}/bin/conda" tos accept \
            --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
    CONDA_DEFAULT_ENV="" CONDA_PREFIX="" \
        "${CONDA_DIR}/bin/conda" tos accept \
            --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

    # Clean stale env registrations
    mkdir -p "${HOME}/.conda"
    echo "${CONDA_DIR}" > "${HOME}/.conda/environments.txt"

    success "Miniconda installed"
}

# ── Step 2: Make /opt/conda world-readable + executable ──────────────────────

fix_permissions() {
    info "Setting permissions on ${CONDA_DIR} (owner: peter, world-readable)..."
    chmod -R a+rX "$CONDA_DIR"
    # envs dir needs to stay writable by peter only
    chmod 755 "${CONDA_DIR}/envs" 2>/dev/null || true
    success "Permissions set"
}

# ── Step 3: Build shared environment ────────────────────────────────────────

build_shared_env() {
    info "Building shared conda environment..."

    # Ensure conda is on PATH and no stale env vars interfere
    export CONDA_DEFAULT_ENV="" CONDA_PREFIX="" CONDA_SHLVL=0
    export PATH="${CONDA_DIR}/bin:${SCRIPT_DIR}:${PATH}"

    "${SCRIPT_DIR}/cli" env build 2>&1

    # Make the new env world-readable
    fix_permissions
}

# ── Step 4: Ensure /etc/zsh/zshenv sets ZDOTDIR ──────────────────────────────

setup_system_zshenv() {
    local zshenv="/etc/zsh/zshenv"
    if grep -q 'ZDOTDIR' "$zshenv" 2>/dev/null; then
        success "ZDOTDIR already set in ${zshenv}"
        return 0
    fi
    info "Adding ZDOTDIR to ${zshenv}..."
    printf '\nexport ZDOTDIR="$HOME"/.config/zsh\n' | sudo tee -a "$zshenv" > /dev/null
    success "ZDOTDIR added to ${zshenv}"
}

# ── Step 5: Set up each user's bashrc ───────────────────────────────────────

CONDA_BASHRC_BLOCK='# >>> conda initialize >>>
# !! Contents within this block are managed by conda init !!
__conda_setup="$('"'"'/opt/conda/bin/conda'"'"' '"'"'shell.bash'"'"' '"'"'hook'"'"' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then
        . "/opt/conda/etc/profile.d/conda.sh"
    else
        export PATH="/opt/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
if command -v conda &>/dev/null; then
    conda activate /opt/conda/envs/prod 2>/dev/null || true
fi'

setup_user_bashrc() {
    local user="$1"
    local home
    home=$(eval echo "~${user}")
    local bashrc="${home}/.bashrc"

    info "Setting up bashrc for ${user} (${bashrc})..."

    # All file checks via sudo — home dirs may be 700
    if ! sudo test -f "$bashrc"; then
        sudo -u "$user" bash -c "touch '${bashrc}'"
    fi

    if sudo grep -q '>>> conda initialize >>>' "$bashrc" 2>/dev/null; then
        success "${user}: conda block already in bashrc"
        # Fix stale paper activation if present
        if sudo grep -q 'conda activate.*paper' "$bashrc" 2>/dev/null; then
            sudo sed -i 's#conda activate.*paper.*#conda activate /opt/conda/envs/prod 2>/dev/null || true#' "$bashrc"
            sudo chown "${user}:${user}" "$bashrc"
            success "${user}: updated activation from paper to prod"
        fi
        return 0
    fi

    # Append conda block
    printf '\n%s\n' "$CONDA_BASHRC_BLOCK" | sudo tee -a "$bashrc" > /dev/null
    sudo chown "${user}:${user}" "$bashrc"

    success "${user}: conda block added to bashrc"
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BOLD}Deploying Shared Conda Environment${RESET}"
    echo "════════════════════════════════════════"
    echo "  Host:  $(hostname)"
    echo "  Users: ${USERS[*]}"
    echo ""

    # Must be peter (who owns /opt)
    if [[ "$(whoami)" != "peter" ]]; then
        error "This script must be run as peter (owner of /opt)"
        exit 1
    fi

    # Step 1
    echo -e "\n${BOLD}[1/5] Miniconda${RESET}"
    echo "────────────────────────────────────────"
    install_miniconda

    # Step 2
    echo -e "\n${BOLD}[2/5] Permissions${RESET}"
    echo "────────────────────────────────────────"
    fix_permissions

    # Step 3
    echo -e "\n${BOLD}[3/5] Build Shared Environment${RESET}"
    echo "────────────────────────────────────────"
    build_shared_env

    # Step 4
    echo -e "\n${BOLD}[4/5] System ZSH Config${RESET}"
    echo "────────────────────────────────────────"
    setup_system_zshenv

    # Step 5
    echo -e "\n${BOLD}[5/5] User Shell Setup${RESET}"
    echo "────────────────────────────────────────"
    for user in "${USERS[@]}"; do
        setup_user_bashrc "$user"
    done

    echo ""
    echo -e "${BOLD}════════════════════════════════════════${RESET}"
    echo ""

    # Show result
    export CONDA_DEFAULT_ENV="" CONDA_PREFIX="" CONDA_SHLVL=0
    export PATH="${CONDA_DIR}/bin:${PATH}"
    "${SCRIPT_DIR}/cli" env status

    success "Deployment complete!"
    echo ""
    echo "All users can now run:  source ~/.bashrc"
    echo ""
}

main "$@"
