#!/usr/bin/env bash
#
# auto-update.sh - Update system prerequisites and AI CLI tools
#
# Sourced by the main cli script. Expects logging functions (info, success, warn, error)
# and CONDA_ENVS_DIR / PROD_LINK to be defined.
#

update_prereqs() {
    info "Updating system packages..."
    detect_platform
    pkg_update
    success "System packages updated"

    info "Checking 1Password CLI..."
    install_1password_cli || true

    info "Checking chezmoi..."
    if has_cmd chezmoi || [[ -x "$CHEZMOI_BIN" ]]; then
        local current
        current=$(chezmoi --version 2>/dev/null | head -1 || echo "unknown")
        success "chezmoi present ($current)"
    else
        ensure_chezmoi
    fi
}

update_ai_clis() {
    local failed=0

    # --- Claude Code (standalone binary at ~/.local/bin/claude) ---
    info "Updating Claude Code CLI..."
    if command -v claude &>/dev/null; then
        if claude update 2>&1; then
            success "Claude Code updated: $(claude --version 2>&1 | head -1)"
        else
            warn "Claude Code update returned non-zero (may already be latest)"
            success "Claude Code version: $(claude --version 2>&1 | head -1)"
        fi
    else
        warn "Claude Code CLI not found, installing..."
        if curl -fsSL https://claude.ai/install.sh | bash 2>&1; then
            success "Claude Code installed: $(claude --version 2>&1 | head -1)"
        else
            error "Failed to install Claude Code"
            ((failed++))
        fi
    fi

    # --- Codex & Gemini (npm global packages in conda prod env) ---
    local npm_bin="${PROD_LINK}/bin/npm"
    if [[ ! -x "$npm_bin" ]]; then
        error "npm not found at ${npm_bin} — is the conda prod env built?"
        return 1
    fi

    info "Updating Codex CLI..."
    if "$npm_bin" install -g @openai/codex@latest 2>&1; then
        success "Codex updated: $(${PROD_LINK}/bin/codex --version 2>&1 | head -1)"
    else
        error "Failed to update Codex"
        ((failed++))
    fi

    info "Updating Gemini CLI..."
    if "$npm_bin" install -g @google/gemini-cli@latest 2>&1; then
        success "Gemini updated: $(${PROD_LINK}/bin/gemini --version 2>&1 | head -1)"
    else
        error "Failed to update Gemini"
        ((failed++))
    fi

    if ((failed > 0)); then
        error "${failed} tool(s) failed to update"
        return 1
    fi

    success "All AI CLI tools are up to date"
    return 0
}
