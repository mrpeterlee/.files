# CLI Backup/Restore Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the 1,581-line monolithic `cli` into a thin dispatcher sourcing focused `lib/*.sh` modules, with a simplified backup/restore command surface.

**Architecture:** Extract functions from the monolith into 6 library files (`common.sh`, `platform.sh`, `backup.sh`, `restore.sh`, `conda.sh`, `status.sh`). The `cli` script becomes a ~100-line dispatcher that sources these libraries and routes subcommands. Dead commands (`prereq`, `install`, `reinstall`, `uninstall`, `update`) are removed; their logic is either absorbed into `restore` or deleted entirely.

**Tech Stack:** Bash (set -Eeuo pipefail), chezmoi, conda

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `cli` | Rewrite | ~100 lines: config vars, `SCRIPT_DIR`, source `lib/common.sh` + `lib/platform.sh`, dispatch `main()`, inline `cmd_help()` |
| `lib/common.sh` | Create | Colors, logging (`info`/`success`/`warn`/`error`/`debug`), `has_cmd`, `ensure_chezmoi`, `is_local_source` |
| `lib/platform.sh` | Create | `detect_platform`, `pkg_install`, `pkg_update`, `get_pkg_name`, `install_homebrew`, `install_1password_cli` |
| `lib/backup.sh` | Create | `cmd_backup()` — run `chezmoi re-add`, show summary, print hint |
| `lib/restore.sh` | Create | `cmd_restore()` — prereq logic + chezmoi init/apply + conda + essential tools. `--force` path wipes state first. Contains `create_default_config`, `ensure_conda`, `ensure_conda_env`, `install_essential_tools` |
| `lib/conda.sh` | Create | `cmd_conda()` dispatcher + `cmd_conda_build`, `cmd_conda_nuke`, `cmd_conda_rollback`, `cmd_conda_status`, `cmd_conda_install_timer`, `_env_cleanup`. Conda config vars (`CONDA_ENVS_DIR`, etc.) |
| `lib/status.sh` | Create | `cmd_status()` |
| `.claude/CLAUDE.md` | Modify | Update CLI command references throughout |

---

### Task 1: Create `lib/common.sh`

**Files:**
- Create: `lib/common.sh`

- [ ] **Step 1: Create `lib/common.sh`**

```bash
mkdir -p /home/peter/.files/lib
```

Write `lib/common.sh` with this content (extracted verbatim from `cli` lines 43-76, 168-171, 442-444):

```bash
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
```

- [ ] **Step 2: Verify the file is syntactically valid**

Run: `bash -n /home/peter/.files/lib/common.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add lib/common.sh
git commit -m "refactor: extract lib/common.sh from monolithic cli"
```

---

### Task 2: Create `lib/platform.sh`

**Files:**
- Create: `lib/platform.sh`

- [ ] **Step 1: Create `lib/platform.sh`**

Write `lib/platform.sh` with this content (extracted verbatim from `cli` lines 365-617):

```bash
#!/usr/bin/env bash
#
# platform.sh - Platform detection and package management
#
# Assumes lib/common.sh has been sourced (provides: info, success, warn, error, debug, has_cmd).

detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    IS_WSL=false
    IS_DARWIN=false
    IS_LINUX=false
    PKGMGR=""
    DISTRO=""

    case "$OS" in
        Darwin)
            IS_DARWIN=true
            PKGMGR="brew"
            DISTRO="macos"
            ;;
        Linux)
            IS_LINUX=true
            # Check for WSL
            if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || grep -qi microsoft /proc/version 2>/dev/null; then
                IS_WSL=true
            fi
            # Detect distro and package manager
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                DISTRO="${ID:-unknown}"
                case "$ID" in
                    ubuntu|debian|pop|linuxmint|elementary|zorin)
                        PKGMGR="apt"
                        ;;
                    amzn|amazonlinux|fedora|rhel|centos|rocky|almalinux)
                        PKGMGR="dnf"
                        # Amazon Linux 2 uses yum
                        if [[ "$VERSION_ID" == "2" ]] && command -v yum &>/dev/null && ! command -v dnf &>/dev/null; then
                            PKGMGR="yum"
                        fi
                        ;;
                    arch|manjaro|endeavouros)
                        PKGMGR="pacman"
                        ;;
                    opensuse*|sles)
                        PKGMGR="zypper"
                        ;;
                    *)
                        # Fallback detection
                        if command -v apt &>/dev/null; then
                            PKGMGR="apt"
                        elif command -v dnf &>/dev/null; then
                            PKGMGR="dnf"
                        elif command -v yum &>/dev/null; then
                            PKGMGR="yum"
                        elif command -v pacman &>/dev/null; then
                            PKGMGR="pacman"
                        elif command -v zypper &>/dev/null; then
                            PKGMGR="zypper"
                        fi
                        ;;
                esac
            fi
            ;;
        *)
            error "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    debug "Platform: OS=$OS ARCH=$ARCH DISTRO=$DISTRO PKGMGR=$PKGMGR IS_WSL=$IS_WSL"
}

# Install packages based on package manager
pkg_install() {
    local packages=("$@")

    case "$PKGMGR" in
        apt)
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}"
            ;;
        yum)
            sudo yum install -y "${packages[@]}"
            ;;
        pacman)
            sudo pacman -Syu --noconfirm --needed "${packages[@]}"
            ;;
        zypper)
            sudo zypper install -y "${packages[@]}"
            ;;
        brew)
            brew install "${packages[@]}"
            ;;
        *)
            error "Unknown package manager: $PKGMGR"
            return 1
            ;;
    esac
}

# Update packages based on package manager
pkg_update() {
    case "$PKGMGR" in
        apt)
            sudo apt update && sudo apt upgrade -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        yum)
            sudo yum update -y
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        zypper)
            sudo zypper update -y
            ;;
        brew)
            brew update && brew upgrade
            ;;
    esac
}

# Map package names across distributions
get_pkg_name() {
    local pkg="$1"

    case "$pkg" in
        fd)
            case "$PKGMGR" in
                apt) echo "fd-find" ;;
                dnf|yum) echo "fd-find" ;;
                *) echo "fd" ;;
            esac
            ;;
        bat)
            echo "bat"
            ;;
        ripgrep)
            case "$PKGMGR" in
                *) echo "ripgrep" ;;
            esac
            ;;
        shellcheck)
            case "$PKGMGR" in
                dnf|yum) echo "ShellCheck" ;;
                *) echo "shellcheck" ;;
            esac
            ;;
        *)
            echo "$pkg"
            ;;
    esac
}

# Install Homebrew on macOS
install_homebrew() {
    if ! has_cmd brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add to PATH for current session
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    else
        success "Homebrew already installed"
    fi
}

# Install 1Password CLI
install_1password_cli() {
    if has_cmd op; then
        local op_version
        op_version=$(op --version 2>/dev/null || echo "unknown")
        success "1Password CLI already installed (v${op_version})"
        return 0
    fi

    info "Installing 1Password CLI..."

    case "$PKGMGR" in
        apt)
            # Add 1Password apt repository
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg 2>/dev/null || true
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
                sudo tee /etc/apt/sources.list.d/1password.list >/dev/null
            sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
            curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
                sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
            sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
                sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg 2>/dev/null || true
            sudo apt update && sudo apt install -y 1password-cli
            ;;
        dnf|yum)
            sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
            sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password.repo'
            if [[ "$PKGMGR" == "dnf" ]]; then
                sudo dnf install -y 1password-cli
            else
                sudo yum install -y 1password-cli
            fi
            ;;
        pacman)
            if has_cmd yay; then
                yay -S --noconfirm 1password-cli
            elif has_cmd paru; then
                paru -S --noconfirm 1password-cli
            else
                warn "Please install 1password-cli from AUR manually (yay -S 1password-cli)"
                return 1
            fi
            ;;
        brew)
            brew install --cask 1password-cli
            ;;
        zypper)
            sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
            sudo zypper addrepo https://downloads.1password.com/linux/rpm/stable/x86_64 1password
            sudo zypper install -y 1password-cli
            ;;
        *)
            warn "Cannot auto-install 1Password CLI for $PKGMGR"
            echo "  Please visit: https://1password.com/downloads/command-line/"
            return 1
            ;;
    esac

    if has_cmd op; then
        success "1Password CLI installed (v$(op --version))"
    else
        error "1Password CLI installation failed"
        return 1
    fi
}
```

- [ ] **Step 2: Verify the file is syntactically valid**

Run: `bash -n /home/peter/.files/lib/platform.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add lib/platform.sh
git commit -m "refactor: extract lib/platform.sh from monolithic cli"
```

---

### Task 3: Create `lib/backup.sh`

**Files:**
- Create: `lib/backup.sh`

- [ ] **Step 1: Create `lib/backup.sh`**

Write `lib/backup.sh`:

```bash
#!/usr/bin/env bash
#
# backup.sh - Capture live system changes back into the repo
#
# Assumes lib/common.sh has been sourced (provides: info, success, error, ensure_chezmoi).
# Assumes CHEZMOI_BIN is set by the caller.

cmd_backup() {
    echo ""
    echo -e "${BOLD}Backing Up Dotfiles${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    ensure_chezmoi

    info "Capturing changes from live system..."
    "$CHEZMOI" re-add

    # Show what changed in the source dir
    local changes
    changes=$(cd "$SCRIPT_DIR" && git diff --name-only 2>/dev/null || true)

    if [[ -n "$changes" ]]; then
        echo ""
        success "Files updated:"
        echo "$changes" | while read -r f; do
            echo "  $f"
        done
    else
        success "No changes detected"
    fi

    echo ""
    echo "Next: run 'git diff' to review, then 'git commit && git push'"
    echo ""
}
```

- [ ] **Step 2: Verify the file is syntactically valid**

Run: `bash -n /home/peter/.files/lib/backup.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add lib/backup.sh
git commit -m "feat: add lib/backup.sh — chezmoi re-add wrapper"
```

---

### Task 4: Create `lib/restore.sh`

**Files:**
- Create: `lib/restore.sh`

- [ ] **Step 1: Create `lib/restore.sh`**

Write `lib/restore.sh` (absorbs `cmd_prereq`, `cmd_install`, `cmd_reinstall`, `ensure_conda`, `ensure_conda_env`, `install_essential_tools`, `create_default_config` from the old `cli`):

```bash
#!/usr/bin/env bash
#
# restore.sh - Restore dotfiles and tools from repo to system
#
# Assumes lib/common.sh and lib/platform.sh have been sourced.
# Assumes SCRIPT_DIR, CHEZMOI_BIN, CHEZMOI_SOURCE, CHEZMOI_CONFIG_DIR, REPO are set.

# Create default config for non-interactive mode
create_default_config() {
    mkdir -p "$CHEZMOI_CONFIG_DIR"
    cat > "${CHEZMOI_CONFIG_DIR}/chezmoi.toml" <<EOF
# Root-level chezmoi configuration (must be before any sections)
sourceDir = "${HOME}/.files"

[data]
    email = "peter.lee@astrocapital.net"
    name = "Peter Lee"
    hostname = "$(hostname)"
    personal = true
    osid = "$(uname -s | tr '[:upper:]' '[:lower:]')"
    arch = "$(uname -m | sed 's/x86_64/amd64/')"
    isWSL = $(test -f /proc/sys/fs/binfmt_misc/WSLInterop && echo true || echo false)
    isDarwin = $(test "$(uname -s)" = "Darwin" && echo true || echo false)
    isLinux = $(test "$(uname -s)" = "Linux" && echo true || echo false)
    isWindows = false
    pkgmgr = "$(command -v pacman >/dev/null && echo pacman || (command -v brew >/dev/null && echo brew || echo apt))"
    hasOp = $(command -v op >/dev/null && echo true || echo false)
    opSignedIn = false

    [data.infra]
        aws_account_id = "000000000000"
        aws_route53_zone_id = "ZXXXXXXXXXXXXXXXXXX"
        aws_iam_role = "arn:aws:iam::000000000000:role/example-role"
        vpn_host = "vpn.example.com"
        vpn_port = "55555"
        vault_url = "https://vault.example.com"
        docker_registry = "registry.example.com"
        internal_ip = "10.0.0.1"
        internal_port = "8080"
        base_domain = "example.com"

[edit]
    command = "nvim"

[diff]
    pager = "diff-so-fancy"

[git]
    autoCommit = false
    autoPush = false
EOF
}

# Install miniconda to /opt/conda if not present (Linux only).
ensure_conda() {
    local conda_dir="/opt/conda"

    # Only supported on Linux
    [[ "$(uname -s)" != "Linux" ]] && return 0

    if [[ -x "${conda_dir}/bin/conda" ]]; then
        debug "Miniconda already installed at ${conda_dir}"
        return 0
    fi

    # Check we can write to /opt (or create /opt/conda)
    local use_sudo=false
    if mkdir -p "$conda_dir" 2>/dev/null; then
        rmdir "$conda_dir" 2>/dev/null || true
    elif sudo -n mkdir -p "$conda_dir" 2>/dev/null; then
        use_sudo=true
        sudo rmdir "$conda_dir" 2>/dev/null || true
    else
        warn "Cannot write to /opt — skipping conda install (run as /opt owner or use sudo)"
        return 0
    fi

    info "Installing Miniconda to ${conda_dir}..."
    local arch
    arch=$(uname -m)
    local url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${arch}.sh"

    local tmp
    tmp=$(mktemp /tmp/miniconda-XXXXXX.sh)
    curl -fsSLo "$tmp" "$url"
    chmod +x "$tmp"

    if [[ "$use_sudo" == "true" ]]; then
        sudo env HOME="$HOME" bash "$tmp" -b -p "$conda_dir"
        sudo chown -R "$(id -u):$(id -g)" "$conda_dir"
        sudo chown -R "$(id -u):$(id -g)" "${HOME}/.conda" 2>/dev/null || true
    else
        env -i HOME="$HOME" PATH="/usr/bin:/bin" bash "$tmp" -b -p "$conda_dir"
    fi
    rm -f "$tmp"

    # Accept ToS for default channels
    CONDA_DEFAULT_ENV="" CONDA_PREFIX="" \
        "${conda_dir}/bin/conda" tos accept \
            --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
    CONDA_DEFAULT_ENV="" CONDA_PREFIX="" \
        "${conda_dir}/bin/conda" tos accept \
            --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

    # Clean stale env registrations
    mkdir -p "${HOME}/.conda"
    echo "${conda_dir}" > "${HOME}/.conda/environments.txt"

    # Make world-readable so other users can use the env
    chmod -R a+rX "$conda_dir"
    chmod 755 "${conda_dir}/envs" 2>/dev/null || true

    success "Miniconda installed at ${conda_dir}"
}

# Build the shared conda env if no prod symlink exists yet.
ensure_conda_env() {
    local conda_dir="/opt/conda"

    [[ "$(uname -s)" != "Linux" ]] && return 0
    [[ ! -x "${conda_dir}/bin/conda" ]] && return 0

    if [[ -L "${conda_dir}/envs/prod" ]]; then
        debug "Conda prod env already exists"
        return 0
    fi

    info "Building conda environment (this may take a while)..."

    export CONDA_DEFAULT_ENV="" CONDA_PREFIX="" CONDA_SHLVL=0
    export PATH="${conda_dir}/bin:${PATH}"

    # Source conda.sh to get cmd_conda_build
    source "${SCRIPT_DIR}/lib/conda.sh"
    cmd_conda_build

    chmod -R a+rX "$conda_dir"
    chmod 755 "${conda_dir}/envs" 2>/dev/null || true
}

# Install essential CLI tools into ~/.local/bin when conda env is not available.
install_essential_tools() {
    local bin_dir="${HOME}/.local/bin"

    # Skip if the conda prod env already provides these tools
    if [[ -d /opt/conda/envs/prod/bin ]] && [[ -x /opt/conda/envs/prod/bin/oh-my-posh ]]; then
        debug "Conda prod env provides tools, skipping standalone install"
        return 0
    fi

    # Only run on Linux
    [[ "$(uname -s)" != "Linux" ]] && return 0

    mkdir -p "$bin_dir"

    local arch
    arch=$(uname -m)
    local arch_go arch_alt
    case "$arch" in
        x86_64)  arch_go="amd64"; arch_alt="x86_64" ;;
        aarch64) arch_go="arm64"; arch_alt="aarch64" ;;
        *)       warn "Unsupported architecture: ${arch}"; return 0 ;;
    esac

    local tmp
    tmp=$(mktemp -d)
    trap "rm -rf '$tmp'" RETURN

    info "Installing essential CLI tools into ~/.local/bin..."

    # oh-my-posh (prompt theme)
    if ! command -v oh-my-posh &>/dev/null; then
        info "  Installing oh-my-posh..."
        local omp_tag
        omp_tag=$(curl -sL https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest | jq -r '.tag_name')
        if [[ -n "$omp_tag" && "$omp_tag" != "null" ]]; then
            curl -sLo "${bin_dir}/oh-my-posh" \
                "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/${omp_tag}/posh-linux-${arch_go}"
            chmod +x "${bin_dir}/oh-my-posh"
            success "  oh-my-posh ${omp_tag}"
        fi
    else
        debug "  oh-my-posh already available"
    fi

    # eza (ls replacement)
    if ! command -v eza &>/dev/null; then
        info "  Installing eza..."
        local eza_tag
        eza_tag=$(curl -sL https://api.github.com/repos/eza-community/eza/releases/latest | jq -r '.tag_name')
        if [[ -n "$eza_tag" && "$eza_tag" != "null" ]]; then
            curl -sL "https://github.com/eza-community/eza/releases/download/${eza_tag}/eza_${arch_alt}-unknown-linux-gnu.tar.gz" \
                | tar xz -C "$tmp"
            cp "${tmp}/eza" "${bin_dir}/eza" 2>/dev/null || cp "${tmp}/./eza" "${bin_dir}/eza" 2>/dev/null
            chmod +x "${bin_dir}/eza"
            success "  eza ${eza_tag}"
        fi
    else
        debug "  eza already available"
    fi

    # lazygit (git TUI)
    if ! command -v lazygit &>/dev/null; then
        info "  Installing lazygit..."
        local lg_tag
        lg_tag=$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name')
        if [[ -n "$lg_tag" && "$lg_tag" != "null" ]]; then
            local lg_ver="${lg_tag#v}"
            local lg_arch; case "$arch" in x86_64) lg_arch="x86_64";; aarch64) lg_arch="arm64";; esac
            curl -sL "https://github.com/jesseduffield/lazygit/releases/download/${lg_tag}/lazygit_${lg_ver}_linux_${lg_arch}.tar.gz" \
                | tar xz -C "$bin_dir" lazygit
            chmod +x "${bin_dir}/lazygit"
            success "  lazygit ${lg_tag}"
        fi
    else
        debug "  lazygit already available"
    fi

    # delta (git pager)
    if ! command -v delta &>/dev/null; then
        info "  Installing delta..."
        local delta_tag
        delta_tag=$(curl -sL https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.tag_name')
        if [[ -n "$delta_tag" && "$delta_tag" != "null" ]]; then
            curl -sL "https://github.com/dandavison/delta/releases/download/${delta_tag}/delta-${delta_tag}-${arch_alt}-unknown-linux-gnu.tar.gz" \
                | tar xz -C "$tmp"
            cp "${tmp}/delta-${delta_tag}-${arch_alt}-unknown-linux-gnu/delta" "${bin_dir}/delta"
            chmod +x "${bin_dir}/delta"
            success "  delta ${delta_tag}"
        fi
    else
        debug "  delta already available"
    fi

    # neovim
    if ! command -v nvim &>/dev/null; then
        info "  Installing nvim..."
        local nvim_tag
        nvim_tag=$(curl -sL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name')
        if [[ -n "$nvim_tag" && "$nvim_tag" != "null" ]]; then
            local nvim_arch; case "$arch" in x86_64) nvim_arch="x86_64";; aarch64) nvim_arch="arm64";; esac
            curl -sLo "${tmp}/nvim.tar.gz" \
                "https://github.com/neovim/neovim/releases/download/${nvim_tag}/nvim-linux-${nvim_arch}.tar.gz"
            tar xzf "${tmp}/nvim.tar.gz" -C "$tmp"
            cp "${tmp}/nvim-linux-${nvim_arch}/bin/nvim" "${bin_dir}/nvim"
            chmod +x "${bin_dir}/nvim"
            local share_dir="${HOME}/.local/share"
            if [[ -d "${tmp}/nvim-linux-${nvim_arch}/share/nvim" ]]; then
                mkdir -p "${share_dir}"
                rm -rf "${share_dir}/nvim"
                cp -r "${tmp}/nvim-linux-${nvim_arch}/share/nvim" "${share_dir}/"
            fi
            if [[ -d "${tmp}/nvim-linux-${nvim_arch}/lib" ]]; then
                mkdir -p "${HOME}/.local/lib"
                cp -r "${tmp}/nvim-linux-${nvim_arch}/lib/"* "${HOME}/.local/lib/" 2>/dev/null || true
            fi
            success "  nvim ${nvim_tag}"
        fi
    else
        debug "  nvim already available"
    fi

    # gh (GitHub CLI)
    if ! command -v gh &>/dev/null; then
        info "  Installing gh..."
        local gh_ver
        gh_ver=$(curl -sL https://api.github.com/repos/cli/cli/releases/latest | jq -r '.tag_name' | sed 's/^v//')
        if [[ -n "$gh_ver" && "$gh_ver" != "null" ]]; then
            curl -sL "https://github.com/cli/cli/releases/download/v${gh_ver}/gh_${gh_ver}_linux_${arch_go}.tar.gz" \
                | tar xz -C "$tmp"
            cp "${tmp}/gh_${gh_ver}_linux_${arch_go}/bin/gh" "${bin_dir}/gh"
            chmod +x "${bin_dir}/gh"
            success "  gh ${gh_ver}"
        fi
    else
        debug "  gh already available"
    fi

    success "Essential CLI tools installed"
}

# Install prereqs (absorbed from old cmd_prereq — minus --update/--no-op flags)
_restore_prereqs() {
    info "Checking prerequisites..."
    echo ""

    detect_platform

    echo "Platform detected:"
    echo "  OS:       $(uname -s)"
    echo "  Arch:     $(uname -m)"
    echo "  Distro:   ${DISTRO:-unknown}"
    echo "  Package:  ${PKGMGR:-unknown}"
    [[ "$IS_WSL" == "true" ]] && echo "  WSL:      yes"
    echo ""

    # Install Homebrew first on macOS
    if [[ "$IS_DARWIN" == "true" ]]; then
        install_homebrew
    fi

    # Define required packages
    local -a base_packages=(curl wget git jq unzip)
    local -a optional_packages=(zsh tmux tree htop ripgrep xclip)

    local -a install_packages=()

    info "Checking base prerequisites..."
    for pkg in "${base_packages[@]}"; do
        local pkg_name
        pkg_name=$(get_pkg_name "$pkg")
        if ! has_cmd "$pkg"; then
            install_packages+=("$pkg_name")
            echo "  ✗ $pkg (will install)"
        else
            echo "  ✓ $pkg"
        fi
    done

    info "Checking optional prerequisites..."
    for pkg in "${optional_packages[@]}"; do
        local pkg_name
        pkg_name=$(get_pkg_name "$pkg")
        if ! has_cmd "$pkg"; then
            install_packages+=("$pkg_name")
            echo "  ✗ $pkg (will install)"
        else
            echo "  ✓ $pkg"
        fi
    done

    # Add fd and bat with proper package names
    if ! has_cmd fd && ! has_cmd fdfind; then
        install_packages+=("$(get_pkg_name fd)")
        echo "  ✗ fd (will install)"
    else
        echo "  ✓ fd"
    fi

    if ! has_cmd bat && ! has_cmd batcat; then
        install_packages+=("$(get_pkg_name bat)")
        echo "  ✗ bat (will install)"
    else
        echo "  ✓ bat"
    fi

    echo ""

    if [[ ${#install_packages[@]} -gt 0 ]]; then
        info "Installing ${#install_packages[@]} packages..."
        pkg_install "${install_packages[@]}"
        success "Packages installed"
    else
        success "All packages already installed"
    fi

    # Create symlinks for fd and bat on Debian/Ubuntu
    if [[ "$PKGMGR" == "apt" ]]; then
        mkdir -p ~/.local/bin
        if [[ -f /usr/bin/fdfind ]] && [[ ! -f ~/.local/bin/fd ]]; then
            ln -sf /usr/bin/fdfind ~/.local/bin/fd
            debug "Created symlink: fd -> fdfind"
        fi
        if [[ -f /usr/bin/batcat ]] && [[ ! -f ~/.local/bin/bat ]]; then
            ln -sf /usr/bin/batcat ~/.local/bin/bat
            debug "Created symlink: bat -> batcat"
        fi
    fi

    echo ""

    # Install 1Password CLI
    info "Checking 1Password CLI..."
    install_1password_cli || true

    echo ""

    # Install chezmoi
    info "Checking chezmoi..."
    if has_cmd chezmoi || [[ -x "$CHEZMOI_BIN" ]]; then
        local chezmoi_version
        chezmoi_version=$(chezmoi --version 2>/dev/null | head -1 || echo "unknown")
        success "chezmoi already installed ($chezmoi_version)"
    else
        ensure_chezmoi
    fi
}

cmd_restore() {
    local force=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                echo "Usage: cli restore [--force]"
                exit 1
                ;;
        esac
    done

    echo ""
    echo -e "${BOLD}Restoring Dotfiles${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    # --force: wipe state first
    if [[ "$force" == "true" ]]; then
        warn "Force mode: wiping chezmoi state..."
        rm -rf "$CHEZMOI_SOURCE"
        rm -f "${CHEZMOI_CONFIG_DIR}/chezmoistate.boltdb"

        info "Removing external dependencies..."
        rm -rf "${HOME}/.local/share/tmux/plugins/tpm"
        rm -rf "${HOME}/.local/share/zinit"
        rm -rf "${HOME}/.local/share/nvim/lazy/lazy.nvim"
        rm -f "${HOME}/.local/bin/fzf"
        rm -f "${HOME}/.local/bin/nvim.appimage"
        rm -f "${HOME}/.local/bin/nvim"
        echo ""
    fi

    # Step 1: Prerequisites
    _restore_prereqs

    echo ""

    # Step 2: Chezmoi init + apply
    ensure_chezmoi

    if [[ ! -t 0 ]]; then
        info "Non-interactive mode detected, using defaults"
        create_default_config

        if is_local_source; then
            info "Using local source: ${SCRIPT_DIR}"
        else
            info "Fetching from: ${REPO}"
            "$CHEZMOI" init "$REPO" --prompt=false
        fi
    else
        if is_local_source; then
            info "Using local source: ${SCRIPT_DIR}"
            "$CHEZMOI" init --source "$SCRIPT_DIR"
        else
            info "Fetching from: ${REPO}"
            "$CHEZMOI" init "$REPO"
        fi
    fi

    info "Applying dotfiles..."
    if [[ ! -t 0 ]]; then
        "$CHEZMOI" apply --force
    else
        "$CHEZMOI" apply
    fi

    # --force: also refresh externals
    if [[ "$force" == "true" ]]; then
        info "Refreshing external dependencies..."
        "$CHEZMOI" apply --refresh-externals 2>&1 || warn "Some externals may have failed"
    fi

    # Step 3: Conda + shared env (Linux only)
    ensure_conda
    ensure_conda_env

    # Step 4: Essential CLI tools fallback
    install_essential_tools

    echo ""
    success "Restore complete!"
    echo ""
    echo "Run 'cli status' to see what was installed."
    echo "Run 'chezmoi diff' to see pending changes."
    echo ""
}
```

- [ ] **Step 2: Verify the file is syntactically valid**

Run: `bash -n /home/peter/.files/lib/restore.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add lib/restore.sh
git commit -m "feat: add lib/restore.sh — unified prereq + install + reinstall"
```

---

### Task 5: Create `lib/conda.sh`

**Files:**
- Create: `lib/conda.sh`

- [ ] **Step 1: Create `lib/conda.sh`**

Write `lib/conda.sh` (extracted from `cli` lines 1054-1351, renaming `cmd_env*` → `cmd_conda*`):

```bash
#!/usr/bin/env bash
#
# conda.sh - Conda environment lifecycle management
#
# Assumes lib/common.sh has been sourced (provides: info, success, warn, error, debug).
# Assumes SCRIPT_DIR is set by the caller.

CONDA_ENVS_DIR="/opt/conda/envs"
PROD_LINK="${CONDA_ENVS_DIR}/prod"
PREV_FILE="${CONDA_ENVS_DIR}/.prod-previous"
ENV_PREFIX="acap"

cmd_conda() {
    local subcmd="${1:-status}"
    shift || true

    case "$subcmd" in
        build)         cmd_conda_build "$@" ;;
        nuke)          cmd_conda_nuke "$@" ;;
        rollback)      cmd_conda_rollback "$@" ;;
        status)        cmd_conda_status "$@" ;;
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

        local real_d
        real_d=$(readlink -f "$d")
        if [[ "$real_d" == "$prod_target" ]] || [[ "$real_d" == "$prev_target" ]]; then
            debug "Keeping (protected): $d"
            continue
        fi

        # Parse timestamp from directory name: acap-YYYYMMDD-HHMMSS
        local name
        name=$(basename "$d")
        local ts_part="${name#"${ENV_PREFIX}"-}"
        local date_part="${ts_part%%-*}"
        local time_part="${ts_part##*-}"

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
```

- [ ] **Step 2: Verify the file is syntactically valid**

Run: `bash -n /home/peter/.files/lib/conda.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add lib/conda.sh
git commit -m "refactor: extract lib/conda.sh from monolithic cli (env → conda)"
```

---

### Task 6: Create `lib/status.sh`

**Files:**
- Create: `lib/status.sh`

- [ ] **Step 1: Create `lib/status.sh`**

Write `lib/status.sh` (extracted from `cli` lines 999-1052, with `cli install` reference updated to `cli restore`):

```bash
#!/usr/bin/env bash
#
# status.sh - Show installation status
#
# Assumes lib/common.sh has been sourced (provides: info, success, warn, error, debug).
# Assumes CHEZMOI_BIN is set by the caller.

cmd_status() {
    echo ""
    echo -e "${BOLD}Dotfiles Status${RESET}"
    echo "────────────────────────────────────────"
    echo ""

    # Check chezmoi
    if command -v chezmoi &>/dev/null || [[ -x "$CHEZMOI_BIN" ]]; then
        success "chezmoi installed"
        CHEZMOI="${CHEZMOI_BIN}"
        command -v chezmoi &>/dev/null && CHEZMOI="chezmoi"
    else
        error "chezmoi not installed"
        echo ""
        echo "Run 'cli restore' to get started."
        return 1
    fi

    # Count managed files
    local file_count
    file_count=$("$CHEZMOI" managed --include=files 2>/dev/null | wc -l || echo 0)
    echo "  Managed files: ${file_count}"
    echo ""

    echo "External dependencies:"
    test -d ~/.local/share/tmux/plugins/tpm && success "TPM (Tmux Plugin Manager)" || error "TPM"
    test -d ~/.local/share/zinit && success "Zinit (Zsh plugin manager)" || error "Zinit"
    test -d ~/.local/share/nvim/lazy/lazy.nvim && success "Lazy.nvim (Neovim plugins)" || error "Lazy.nvim"
    test -x ~/.local/bin/fzf && success "fzf" || error "fzf"
    test -x ~/.local/bin/nvim.appimage && success "Neovim" || error "Neovim"
    echo ""

    echo "Config files:"
    test -f ~/.config/zsh/.zshrc && success "zsh" || error "zsh"
    test -f ~/.config/nvim/init.lua && success "nvim" || error "nvim"
    test -f ~/.config/tmux/tmux.conf && success "tmux" || error "tmux"
    test -f ~/.config/git/config && success "git" || error "git"
    test -f ~/.wezterm.lua && success "wezterm" || error "wezterm"
    test -f ~/.config/lazygit/config.yml && success "lazygit" || error "lazygit"
    echo ""

    echo "Conda environment:"
    if [[ -x /opt/conda/bin/conda ]]; then
        success "Miniconda (/opt/conda)"
    else
        warn "Miniconda not installed"
    fi
    if [[ -L /opt/conda/envs/prod ]]; then
        success "prod -> $(readlink /opt/conda/envs/prod)"
    else
        warn "No prod env (run 'cli conda build')"
    fi
    echo ""
}
```

- [ ] **Step 2: Verify the file is syntactically valid**

Run: `bash -n /home/peter/.files/lib/status.sh`
Expected: No output (clean parse)

- [ ] **Step 3: Commit**

```bash
git add lib/status.sh
git commit -m "refactor: extract lib/status.sh from monolithic cli"
```

---

### Task 7: Rewrite `cli` as thin dispatcher

**Files:**
- Rewrite: `cli`

- [ ] **Step 1: Replace `cli` with the new dispatcher**

Replace the entire content of `cli` with:

```bash
#!/usr/bin/env bash
#
# cli - Manage dotfiles and conda environments
#
# Usage:
#   cli <command> [options]
#
# Commands:
#   backup      Capture live system changes back into the repo
#   restore     Apply dotfiles from repo to system (installs prereqs if needed)
#   conda       Manage conda environments (build, nuke, rollback, status)
#   status      Show current installation status
#   help        Show this help message
#
# Examples:
#   cli backup               # Re-add changed files from system to repo
#   cli restore              # Apply dotfiles + install prereqs if needed
#   cli restore --force      # Clean-slate reinstall
#   cli conda build          # Build new env, validate, swap prod symlink
#   cli conda status         # Show current prod env and available envs
#   cli conda rollback       # Revert prod to previous env
#   cli conda nuke           # Destroy all envs and rebuild
#   cli status               # Check what's installed
#
# Environment Variables:
#   CHEZMOI_REPO    Override the GitHub repo (default: MrPeterLee/dotfiles)
#   DOTFILES_DEBUG  Set to 1 for verbose output
#
set -Eeuo pipefail

# Configuration
REPO="${CHEZMOI_REPO:-MrPeterLee/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEZMOI_BIN="${HOME}/.local/bin/chezmoi"
CHEZMOI_SOURCE="${HOME}/.local/share/chezmoi"
CHEZMOI_CONFIG_DIR="${HOME}/.config/chezmoi"

# Source shared libraries
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/platform.sh"

cmd_help() {
    cat <<'EOF'

  ┌─────────────────────────────────────────────────────────────┐
  │                     DOTFILES CLI                            │
  │                                                             │
  │  Manage your dotfiles with chezmoi                          │
  └─────────────────────────────────────────────────────────────┘

  USAGE:
      cli <command> [options]

  COMMANDS:
      backup        Capture live system changes back into the repo
      restore       Apply dotfiles from repo to system (installs prereqs)
      conda         Manage conda environments
      status        Show installation status
      help          Show this help message

  CONDA SUBCOMMANDS:
      conda build          Build new timestamped env, validate, swap prod symlink
      conda status         Show current prod env and available environments
      conda rollback       Revert prod symlink to previous environment
      conda nuke           Destroy all envs and rebuild from scratch
      conda install-timer  Install systemd timer for weekly auto-rebuild

  RESTORE OPTIONS:
      --force       Clean-slate reinstall (wipe chezmoi state + external deps)

  QUICK START:

      # On a fresh machine:
      git clone https://github.com/MrPeterLee/dotfiles.git ~/.files
      cd ~/.files
      ./cli restore

      # Something broke? Start fresh:
      ./cli restore --force

  COMMON WORKFLOWS:

      # Capture system changes into repo
      $ cli backup
      $ git diff
      $ git commit -am "chore: sync dotfiles"
      $ git push

      # Apply repo to system
      $ cli restore

      # See what chezmoi would change
      $ chezmoi diff

  ENVIRONMENT VARIABLES:
      CHEZMOI_REPO     Override GitHub repo (default: MrPeterLee/dotfiles)
      DOTFILES_DEBUG   Set to 1 for verbose output

  PLATFORM SUPPORT:
      - Linux: Ubuntu/Debian (apt), Fedora/RHEL (dnf), Amazon Linux (dnf/yum),
               Arch (pacman), openSUSE (zypper)
      - macOS: Homebrew (auto-installed if missing)
      - Windows: WSL (uses Linux package manager)

  KEYBOARD LAYOUT:
      This config uses Graphite (not QWERTY):
      y=left  h=down  a=up  e=right  j=end-of-word  l=append  '=yank

  MORE INFO:
      https://github.com/MrPeterLee/dotfiles
      https://www.chezmoi.io/

EOF
}

main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        backup)
            source "${SCRIPT_DIR}/lib/backup.sh"
            cmd_backup "$@"
            ;;
        restore)
            source "${SCRIPT_DIR}/lib/restore.sh"
            cmd_restore "$@"
            ;;
        conda)
            source "${SCRIPT_DIR}/lib/conda.sh"
            cmd_conda "$@"
            ;;
        status)
            source "${SCRIPT_DIR}/lib/status.sh"
            cmd_status "$@"
            ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            error "Unknown command: $cmd"
            echo ""
            echo "Run 'cli help' for usage."
            exit 1
            ;;
    esac
}

main "$@"
```

- [ ] **Step 2: Verify the new cli is syntactically valid**

Run: `bash -n /home/peter/.files/cli`
Expected: No output (clean parse)

- [ ] **Step 3: Verify help output**

Run: `cd /home/peter/.files && ./cli help`
Expected: New help text with `backup`, `restore`, `conda`, `status`, `help` commands

- [ ] **Step 4: Verify status command works**

Run: `cd /home/peter/.files && ./cli status`
Expected: Shows chezmoi status, external deps, config files, conda env info

- [ ] **Step 5: Verify backup command works (dry-run check)**

Run: `cd /home/peter/.files && ./cli backup`
Expected: Runs `chezmoi re-add`, shows summary of changed/unchanged files

- [ ] **Step 6: Verify conda status works**

Run: `cd /home/peter/.files && ./cli conda status`
Expected: Shows conda env status (prod symlink, versions, available envs)

- [ ] **Step 7: Verify unknown command errors correctly**

Run: `cd /home/peter/.files && ./cli install 2>&1; echo "exit: $?"`
Expected: Error message "Unknown command: install" and exit code 1

- [ ] **Step 8: Commit**

```bash
git add cli
git commit -m "refactor: rewrite cli as thin dispatcher sourcing lib/*.sh"
```

---

### Task 8: Update `.claude/CLAUDE.md`

**Files:**
- Modify: `.claude/CLAUDE.md`

- [ ] **Step 1: Update the "Useful Commands" section**

In `.claude/CLAUDE.md`, find the line:
```
./cli install|reinstall|uninstall|status|help
```

Replace with:
```
./cli backup|restore|conda|status|help
```

- [ ] **Step 2: Update the Windows Environment Model section**

Find:
```
| **WSL** | Full dev environment | Standard Linux — run `cli install` inside WSL. Gets conda env, zsh, tmux, neovim, all terminal utilities. |
```

Replace with:
```
| **WSL** | Full dev environment | Standard Linux — run `cli restore` inside WSL. Gets conda env, zsh, tmux, neovim, all terminal utilities. |
```

- [ ] **Step 3: Update Conda Environment Management section**

Find all references to `cli env` and update to `cli conda`:

- `The \`cli env\` command manages` → `The \`cli conda\` command manages`
- `| \`cli env build\`` → `| \`cli conda build\``
- `| \`cli env status\`` → `| \`cli conda status\``
- `| \`cli env rollback\`` → `| \`cli conda rollback\``
- `| \`cli env nuke\`` → `| \`cli conda nuke\``
- `| \`cli env install-timer\`` → `| \`cli conda install-timer\``

- [ ] **Step 4: Update "Adding or removing packages" section**

Find:
```
After editing, run `cli env build` to create a fresh env with the changes.
```

Replace with:
```
After editing, run `cli conda build` to create a fresh env with the changes.
```

- [ ] **Step 5: Update the key files section**

Find:
```
    auto-upgrade.service                 # systemd oneshot for cli env build
```

Replace with:
```
    auto-upgrade.service                 # systemd oneshot for cli conda build
```

- [ ] **Step 6: Update `cli prereq` reference**

Find:
```
   `op` (1Password CLI, via `cli prereq`),
```

Replace with:
```
   `op` (1Password CLI, installed automatically by `cli restore`),
```

- [ ] **Step 7: Verify no stale references remain**

Run: `grep -n 'cli install\|cli prereq\|cli reinstall\|cli uninstall\|cli env\b\|cli update' /home/peter/.files/.claude/CLAUDE.md`

Expected: Only lines referencing `~/.agents/cli install` should remain (that's a different CLI). No references to old dotfiles CLI commands.

- [ ] **Step 8: Commit**

```bash
git add .claude/CLAUDE.md
git commit -m "docs: update CLAUDE.md for new cli backup/restore commands"
```

---

### Task 9: Final verification

**Files:** (none — verification only)

- [ ] **Step 1: Verify all lib files parse cleanly**

Run: `for f in /home/peter/.files/lib/*.sh; do echo "Checking $f..."; bash -n "$f" && echo "  OK" || echo "  FAIL"; done`
Expected: All files OK

- [ ] **Step 2: Verify cli dispatcher parses cleanly**

Run: `bash -n /home/peter/.files/cli`
Expected: No output (clean parse)

- [ ] **Step 3: Run full command surface test**

Run each command and verify it doesn't error:

```bash
cd /home/peter/.files
./cli help
./cli status
./cli backup
./cli conda status
```

Expected: All commands produce output without errors.

- [ ] **Step 4: Verify old commands are rejected**

Run: `cd /home/peter/.files && ./cli install 2>&1 | head -1`
Expected: `✗ Unknown command: install`

Run: `cd /home/peter/.files && ./cli prereq 2>&1 | head -1`
Expected: `✗ Unknown command: prereq`

- [ ] **Step 5: Verify line counts are reasonable**

Run: `wc -l /home/peter/.files/cli /home/peter/.files/lib/*.sh`
Expected: `cli` ~120 lines, lib files between 30-350 lines each, total ~900-1000 lines (down from 1581 due to deleted commands)

- [ ] **Step 6: Commit any fixes if needed, then tag completion**

```bash
git log --oneline -8
```

Expected: 8 commits for this refactor (one per task 1-8).
