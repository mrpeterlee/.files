#!/usr/bin/env bash
#
# conda.sh - Conda environment lifecycle management
#
# Assumes lib/common.sh has been sourced (provides: info, success, warn, error, debug).
# Assumes SCRIPT_DIR is set by the caller.

# ============================================================================
# Conda Environment Management
# ============================================================================

CONDA_ENVS_DIR="/opt/conda/envs"
PROD_LINK="${CONDA_ENVS_DIR}/prod"
PREV_FILE="${CONDA_ENVS_DIR}/.prod-previous"
ENV_PREFIX="acap"

cmd_conda() {
    local subcmd="${1:-status}"
    shift || true

    case "$subcmd" in
        build)      cmd_conda_build "$@" ;;
        nuke)       cmd_conda_nuke "$@" ;;
        rollback)   cmd_conda_rollback "$@" ;;
        status)     cmd_conda_status "$@" ;;
        install-timer) cmd_conda_install_timer "$@" ;;
        *)
            error "Unknown conda subcommand: $subcmd"
            echo ""
            echo "Usage: cli conda <build|nuke|rollback|status|install-timer>"
            exit 1
            ;;
    esac
}

cmd_conda_build() {
    echo ""
    echo -e "${BOLD}Building Conda Environment${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    source "${SCRIPT_DIR}/env/lib/build.sh"
    source "${SCRIPT_DIR}/env/lib/validate.sh"

    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local new_prefix="${CONDA_ENVS_DIR}/${ENV_PREFIX}-${timestamp}"

    info "New environment: ${new_prefix}"

    # Ensure partial env is cleaned up on any failure
    trap 'error "Build interrupted — removing ${new_prefix}"; rm -rf "$new_prefix"; trap - ERR' ERR

    # Build
    build_env "$new_prefix"

    # Validate
    validate_env "$new_prefix"

    # Disable the cleanup trap now that build+validate succeeded
    trap - ERR

    # Record previous target
    if [[ -L "$PROD_LINK" ]]; then
        readlink -f "$PROD_LINK" > "$PREV_FILE"
        info "Previous prod recorded: $(cat "$PREV_FILE")"
    fi

    # Atomic swap
    info "Swapping prod symlink..."
    ln -sfn "$new_prefix" "$PROD_LINK"
    success "prod -> ${new_prefix}"

    # Cleanup: remove envs older than 30 days (keeps prod + previous)
    _env_cleanup

    echo ""
    success "Build complete!"
    echo ""
}

cmd_conda_nuke() {
    echo ""
    echo -e "${BOLD}Nuking All Conda Environments${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    # Confirm unless --force
    if [[ "${1:-}" != "--force" ]] && [[ -t 0 ]]; then
        echo -e "${YELLOW}Warning:${RESET} This will remove ALL ${ENV_PREFIX}-* envs and rebuild from scratch."
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    info "Removing prod symlink..."
    rm -f "$PROD_LINK"

    info "Removing previous-env record..."
    rm -f "$PREV_FILE"

    info "Removing all ${ENV_PREFIX}-* environments..."
    for d in "${CONDA_ENVS_DIR}/${ENV_PREFIX}"-*; do
        if [[ -d "$d" ]]; then
            info "  Removing ${d}..."
            rm -rf "$d"
        fi
    done

    success "All environments removed"
    echo ""

    # Rebuild
    cmd_conda_build
}

cmd_conda_rollback() {
    echo ""
    echo -e "${BOLD}Rolling Back Conda Environment${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    if [[ ! -f "$PREV_FILE" ]]; then
        error "No previous environment recorded (${PREV_FILE} not found)"
        exit 1
    fi

    local previous
    previous=$(cat "$PREV_FILE")

    if [[ ! -d "$previous" ]]; then
        error "Previous environment no longer exists: ${previous}"
        exit 1
    fi

    local current=""
    if [[ -L "$PROD_LINK" ]]; then
        current=$(readlink -f "$PROD_LINK")
    fi

    info "Current prod:  ${current:-<none>}"
    info "Rolling back to: ${previous}"

    ln -sfn "$previous" "$PROD_LINK"
    success "prod -> ${previous}"

    echo ""
    success "Rollback complete!"
    echo ""
}

cmd_conda_status() {
    echo ""
    echo -e "${BOLD}Conda Environment Status${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    # Prod symlink
    if [[ -L "$PROD_LINK" ]]; then
        local target
        target=$(readlink -f "$PROD_LINK")
        success "prod -> ${target}"
    else
        warn "prod symlink does not exist"
    fi

    # Versions (if prod exists)
    if [[ -L "$PROD_LINK" ]]; then
        local prefix
        prefix=$(readlink -f "$PROD_LINK")
        echo ""
        echo "Versions:"
        if [[ -x "${prefix}/bin/python" ]]; then
            echo "  Python: $("${prefix}/bin/python" --version 2>&1)"
        fi
        if [[ -x "${prefix}/bin/node" ]]; then
            echo "  Node:   $("${prefix}/bin/node" --version 2>&1)"
        fi
        if [[ -x "${prefix}/bin/uv" ]]; then
            echo "  uv:     $("${prefix}/bin/uv" --version 2>&1)"
        fi
    fi

    # Previous env
    if [[ -f "$PREV_FILE" ]]; then
        echo ""
        echo "Previous: $(cat "$PREV_FILE")"
    fi

    # List all acap-* envs
    echo ""
    echo "Available environments:"
    local found=0
    for d in "${CONDA_ENVS_DIR}/${ENV_PREFIX}"-*; do
        if [[ -d "$d" ]]; then
            local name
            name=$(basename "$d")
            local created
            created=$(stat -c '%y' "$d" 2>/dev/null | cut -d. -f1)
            echo "  ${name}  (created: ${created:-unknown})"
            found=1
        fi
    done
    if [[ "$found" -eq 0 ]]; then
        echo "  (none)"
    fi

    echo ""
}

cmd_conda_install_timer() {
    echo ""
    echo -e "${BOLD}Installing Auto-Upgrade Timer${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    local service_src="${SCRIPT_DIR}/env/auto-upgrade.service"
    local timer_src="${SCRIPT_DIR}/env/auto-upgrade.timer"
    local systemd_dir="${HOME}/.config/systemd/user"

    mkdir -p "$systemd_dir"

    info "Copying systemd units..."
    cp "$service_src" "${systemd_dir}/finclab-env-upgrade.service"
    cp "$timer_src" "${systemd_dir}/finclab-env-upgrade.timer"

    info "Reloading systemd..."
    systemctl --user daemon-reload

    info "Enabling and starting timer..."
    systemctl --user enable --now finclab-env-upgrade.timer

    success "Timer installed"
    systemctl --user status finclab-env-upgrade.timer --no-pager || true

    echo ""
}

# Cleanup: remove acap-* envs older than 30 days.
# Always preserves current prod target and the previous env (for rollback).
_env_cleanup() {
    local max_age_days=30
    local now_epoch
    now_epoch=$(date +%s)

    # Determine which envs to protect
    local prod_target=""
    if [[ -L "$PROD_LINK" ]]; then
        prod_target=$(readlink -f "$PROD_LINK")
    fi
    local prev_target=""
    if [[ -f "$PREV_FILE" ]]; then
        prev_target=$(cat "$PREV_FILE")
    fi

    local removed=0
    for d in "${CONDA_ENVS_DIR}/${ENV_PREFIX}"-*; do
        [[ -d "$d" ]] || continue

        # Never remove current prod or rollback target
        local real_d
        real_d=$(readlink -f "$d")
        if [[ "$real_d" == "$prod_target" ]] || [[ "$real_d" == "$prev_target" ]]; then
            debug "Keeping (protected): $d"
            continue
        fi

        # Parse timestamp from directory name: acap-YYYYMMDD-HHMMSS
        local name
        name=$(basename "$d")
        local ts_part="${name#"${ENV_PREFIX}"-}"          # YYYYMMDD-HHMMSS
        local date_part="${ts_part%%-*}"                   # YYYYMMDD
        local time_part="${ts_part##*-}"                   # HHMMSS

        # Build a date string that date(1) can parse
        local y="${date_part:0:4}"
        local m="${date_part:4:2}"
        local day="${date_part:6:2}"
        local H="${time_part:0:2}"
        local M="${time_part:2:2}"
        local S="${time_part:4:2}"

        local env_epoch
        env_epoch=$(date -d "${y}-${m}-${day} ${H}:${M}:${S}" +%s 2>/dev/null || echo 0)

        local age_days=$(( (now_epoch - env_epoch) / 86400 ))

        if [[ "$age_days" -ge "$max_age_days" ]]; then
            info "  Removing ${name} (${age_days} days old)..."
            rm -rf "$d"
            removed=$((removed + 1))
        else
            debug "Keeping ${name} (${age_days} days old)"
        fi
    done

    if [[ "$removed" -gt 0 ]]; then
        info "Cleaned up ${removed} old environment(s)"
    else
        debug "No environments older than ${max_age_days} days to clean up"
    fi
}
