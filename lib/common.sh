#!/usr/bin/env bash
#
# common.sh - Shared helpers for the dotfiles CLI
#
# Assumes SCRIPT_DIR is set by the caller.

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

# Logging functions
info() { echo -e "${BLUE}==>${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn() { echo -e "${YELLOW}!${RESET} $*"; }
error() { echo -e "${RED}✗${RESET} $*" >&2; }
debug() { [[ "${DOTFILES_DEBUG:-}" == "1" ]] && echo -e "${YELLOW}[debug]${RESET} $*" || true; }

# Check if a command exists
has_cmd() {
    command -v "$1" &>/dev/null
}

# Find or install chezmoi
ensure_chezmoi() {
    if command -v chezmoi &>/dev/null; then
        CHEZMOI="chezmoi"
        return 0
    elif [[ -x "$CHEZMOI_BIN" ]]; then
        CHEZMOI="$CHEZMOI_BIN"
        return 0
    fi

    info "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
    CHEZMOI="$CHEZMOI_BIN"
    success "chezmoi installed"
}

# Check if running from local source
is_local_source() {
    [[ -f "${SCRIPT_DIR}/.chezmoi.toml.tmpl" ]]
}
