# Secrets Management Guide

This guide explains how secrets are managed in this dotfiles repository using 1Password and chezmoi templates.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            SECRETS FLOW                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1Password Vault: AstroCapital                                          │
│  └── Item: Infrastructure                                               │
│       ├── aws_account_id                                                │
│       ├── aws_route53_zone_id                                           │
│       ├── aws_iam_role                                                  │
│       ├── vpn_host                                                      │
│       ├── vpn_port                                                      │
│       ├── vault_url                                                     │
│       ├── docker_registry                                               │
│       ├── internal_ip                                                   │
│       ├── internal_port                                                 │
│       └── base_domain                                                   │
│                           │                                              │
│                           ▼                                              │
│  chezmoi init ───────────────────────────────────────────────────────   │
│       │                                                                  │
│       │  Reads via onepasswordRead()                                    │
│       │                                                                  │
│       ▼                                                                  │
│  ~/.config/chezmoi/chezmoi.toml                                         │
│  [data.infra]                                                           │
│       aws_account_id = "123456789012"                                   │
│       vpn_host = "vpn.company.com"                                      │
│       ...                                                               │
│                           │                                              │
│                           ▼                                              │
│  chezmoi apply ──────────────────────────────────────────────────────   │
│       │                                                                  │
│       │  Processes .tmpl files                                          │
│       │                                                                  │
│       ▼                                                                  │
│  Final config files with real values                                    │
│       ~/.config/tmuxinator/work.yml                                     │
│       ~/.config/zsh/.zshrc                                              │
│       etc.                                                              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## 1Password Setup

### Prerequisites

```bash
# Install 1Password CLI
# macOS
brew install --cask 1password-cli

# Linux (Debian/Ubuntu)
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install 1password-cli

# Sign in
op signin
```

### Creating the Infrastructure Item

#### Option 1: Interactive Script

```bash
./scripts/setup-1password-secrets.sh
```

#### Option 2: Manual CLI

```bash
op item create --category=login --vault AstroCapital --title Infrastructure \
    "aws_account_id=123456789012" \
    "aws_route53_zone_id=ZXXXXXXXXXXXXX" \
    "aws_iam_role=arn:aws:iam::123456789012:role/MyRole" \
    "vpn_host=vpn.company.com" \
    "vpn_port=55555" \
    "vault_url=https://vault.company.com" \
    "docker_registry=registry.company.com" \
    "internal_ip=10.1.1.100" \
    "internal_port=8080" \
    "base_domain=company.com"
```

#### Option 3: 1Password Web/App

1. Open 1Password
2. Go to vault "AstroCapital"
3. Create new Login item named "Infrastructure"
4. Add custom fields for each secret

### Viewing Current Secrets

```bash
# List all fields
op item get Infrastructure --vault AstroCapital --format json | jq '.fields[] | {label, value}'

# Get specific field
op read "op://AstroCapital/Infrastructure/vpn_host"
```

### Updating Secrets

```bash
# Update single field
op item edit Infrastructure --vault AstroCapital "vpn_host=new-vpn.company.com"

# Then refresh chezmoi
chezmoi init --force
chezmoi apply
```

## Chezmoi Integration

### How It Works

1. `.chezmoi.toml.tmpl` checks if 1Password CLI is signed in
2. If signed in, reads secrets via `onepasswordRead()`
3. If not signed in, uses defaults from `.chezmoidata.yaml`
4. Secrets are stored in generated `~/.config/chezmoi/chezmoi.toml`
5. Template files (`.tmpl`) reference secrets via `{{ .infra.* }}`

### Key Files

| File | Purpose |
|------|---------|
| `.chezmoi.toml.tmpl` | Reads secrets from 1Password, generates config |
| `.chezmoidata.yaml` | Default/placeholder values (safe for public repo) |
| `*.tmpl` files | Use `{{ .infra.* }}` variables |

### Template Syntax

```go
// Basic variable
{{ .infra.vpn_host }}

// With default fallback
{{ .infra.vpn_host | default "localhost" }}

// In a command
ssh -p {{ .infra.vpn_port }} user@{{ .infra.vpn_host }}

// Conditional
{{ if .opSignedIn }}
# Using 1Password
{{ else }}
# Using defaults
{{ end }}

// Building URLs
https://{{ .infra.base_domain }}/api
docker.{{ .infra.base_domain }}
```

## Adding New Secrets

### Step 1: Add to 1Password

```bash
op item edit Infrastructure --vault AstroCapital "new_secret=secret-value"
```

### Step 2: Update `.chezmoi.toml.tmpl`

Add to the variable declarations section:

```go
{{- $newSecret := "default-value" -}}
{{- if $opSignedIn -}}
{{-   $newSecret = onepasswordRead "op://AstroCapital/Infrastructure/new_secret" -}}
{{- end -}}
```

Add to the `[data.infra]` section:

```toml
new_secret = {{ $newSecret | quote }}
```

### Step 3: Update `.chezmoidata.yaml`

```yaml
infra:
  # ... existing fields ...
  new_secret: "placeholder-value"
```

### Step 4: Use in Templates

```go
// In any .tmpl file
export MY_SECRET={{ .infra.new_secret }}
```

### Step 5: Test

```bash
# Verify template data
chezmoi data | grep new_secret

# Preview changes
chezmoi diff

# Apply
chezmoi apply
```

## Naming Conventions

### Field Names

| Type | Pattern | Examples |
|------|---------|----------|
| Hostnames | `*_host` | `vpn_host`, `db_host`, `api_host` |
| Ports | `*_port` | `vpn_port`, `db_port`, `api_port` |
| URLs | `*_url` | `vault_url`, `api_url`, `webhook_url` |
| IPs | `*_ip` | `internal_ip`, `gateway_ip` |
| AWS | `aws_*` | `aws_account_id`, `aws_region` |
| Domains | `*_domain` | `base_domain`, `api_domain` |
| Credentials | Don't store in chezmoi | Use `op read` at runtime |

### API Keys and Tokens

For API keys that need to be available as environment variables, use runtime injection instead of storing in chezmoi:

```bash
# In .zshrc or .secrets.local.zsh
export OPENAI_API_KEY="$(op read 'op://AstroCapital/OpenAI/credential')"

# Or use op inject for .env files
op inject -i .env.template -o .env
```

## Security Best Practices

### DO

- Store infrastructure config (hosts, ports, IPs) in the Infrastructure item
- Use `op read` at runtime for actual credentials (API keys, passwords)
- Keep `.chezmoidata.yaml` values as obvious placeholders
- Run `chezmoi diff` before applying to verify no secrets leak
- Use `.chezmoiignore` for files that should never be templated

### DON'T

- Never hardcode real IPs, hostnames, or credentials in the repo
- Never commit `~/.config/chezmoi/chezmoi.toml` (it has real values)
- Never store actual passwords/tokens in chezmoi templates
- Never use `git add -A` without reviewing changes first

### Pre-Commit Check

```bash
# Check for potential secrets before committing
git diff --cached | grep -E \
    "(password|secret|token|api.?key|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"
```

## Troubleshooting

### "op: not signed in"

```bash
op signin
chezmoi init --force
```

### "item not found"

```bash
# Check vault exists
op vault list

# Check item exists
op item list --vault AstroCapital
```

### Template not rendering

```bash
# Check if file ends in .tmpl
ls -la dot_config/myfile.tmpl

# Test template
chezmoi execute-template < dot_config/myfile.tmpl

# Check available data
chezmoi data
```

### Values not updating

```bash
# Force re-init from 1Password
chezmoi init --force

# Then apply
chezmoi apply --force
```

## Bitwarden / Vaultwarden (Tapai)

For Tapai project infrastructure, credentials are stored in a self-hosted Vaultwarden instance at `pw.tapai.com` and retrieved via the Bitwarden CLI (`bw`).

### Architecture

```
~/.config/bw/env              Machine-local config (server, email, password)
        │                     chmod 600, NOT in chezmoi
        ▼
~/.config/zsh/.secrets.local.zsh    Shell function: bw-unlock
        │                           Sources bw/env, exports BW_SESSION
        ▼
bw CLI (/usr/local/bin/bw)    Configured for pw.tapai.com
        │
        ▼
Vaultwarden (pw.tapai.com)    Tapai org, 29 vault items
```

### Setup on a New Host

```bash
# 1. Install Bitwarden CLI
curl -sL "https://bitwarden.com/download/?app=cli&platform=linux" -o /tmp/bw.zip
unzip -o /tmp/bw.zip -d /tmp/bw
sudo mv /tmp/bw/bw /usr/local/bin/bw && chmod +x /usr/local/bin/bw
rm -rf /tmp/bw.zip /tmp/bw

# 2. Create machine-local config
mkdir -p ~/.config/bw
cat > ~/.config/bw/env << 'EOF'
# Bitwarden CLI configuration (machine-local, not in chezmoi)
# chmod 600 this file
BW_SERVER=https://pw.tapai.com
BW_EMAIL=tapai.tech@acap.cc
BW_PASSWORD=<master-password-here>
EOF
chmod 600 ~/.config/bw/env

# 3. Create bw-unlock shell function
cat > ~/.config/zsh/.secrets.local.zsh << 'FUNC'
# Machine-local secrets (not managed by chezmoi)

# Bitwarden vault unlock helper
bw-unlock() {
    local bw_config="${XDG_CONFIG_HOME:-$HOME/.config}/bw/env"
    if [[ ! -f "$bw_config" ]]; then
        echo "Error: $bw_config not found" >&2
        return 1
    fi

    local BW_SERVER BW_EMAIL BW_PASSWORD
    source "$bw_config"

    bw config server "$BW_SERVER" 2>/dev/null || true

    if ! bw login --check &>/dev/null; then
        bw login "$BW_EMAIL" "$BW_PASSWORD" --nointeraction
    fi

    export BW_SESSION=$(bw unlock "$BW_PASSWORD" --raw)
    bw sync --quiet
    echo "Vault unlocked (BW_SESSION exported)"
}
FUNC
chmod 600 ~/.config/zsh/.secrets.local.zsh

# 4. Test
source ~/.config/zsh/.secrets.local.zsh
bw-unlock
bw list items | jq 'length'
```

### Files (Machine-Local, NOT in chezmoi)

| File | Purpose | Permissions |
|------|---------|-------------|
| `~/.config/bw/env` | BW server URL, email, master password | `600` |
| `~/.config/zsh/.secrets.local.zsh` | `bw-unlock` shell function | `600` |

The `.secrets.local.zsh` file is automatically sourced by the chezmoi-managed `.secrets.zsh` if it exists.

### Usage

```bash
# Unlock vault (in any zsh session)
bw-unlock

# Get a password
bw get password "argocd-admin"

# Get a secure note
bw get notes "wireguard-plant-vpn"

# List all items
bw list items --pretty

# Create a new item
echo '{"type":1,"name":"my-item","login":{"username":"user","password":"pass"}}' \
  | bw encode | bw create item

# Launch Claude Code with MCP + vault access
~/tapai/bin/claude-tapai
```

### Claude Code Integration

A Bitwarden MCP server is configured in `~/.claude/settings.json`. The wrapper script `~/tapai/bin/claude-tapai` reads `~/.config/bw/env`, unlocks the vault, and launches Claude with `BW_SESSION` available to the MCP server.

The credential registry (which vault item maps to which service) is in `~/tapai/CLAUDE.md`.

### Cross-Platform Notes

- `~/.config/bw/env` uses `XDG_CONFIG_HOME` (defaults to `~/.config` on all platforms)
- The `bw` CLI binary differs per platform — use the correct download URL
- The `.secrets.local.zsh` function works in both zsh and bash (source it manually in bash)
- On macOS: `brew install bitwarden-cli` instead of the curl/unzip method

## Quick Reference

```bash
# 1Password CLI
op signin                                    # Sign in
op item list --vault AstroCapital           # List items
op item get Infrastructure --vault AstroCapital  # View item
op read "op://AstroCapital/Infrastructure/field"  # Read field
op item edit Infrastructure --vault AstroCapital "field=value"  # Update

# Bitwarden CLI (Tapai Vaultwarden)
bw-unlock                                    # Unlock vault (shell function)
bw get password "item-name"                  # Get password
bw get notes "item-name"                     # Get secure note
bw get username "item-name"                  # Get username
bw list items --pretty                       # List all items
bw list items --search "keyword"             # Search items
bw generate -uln --length 32                 # Generate password
bw lock                                      # Lock vault

# Chezmoi
chezmoi data                                 # Show all template data
chezmoi data | jq '.infra'                  # Show infra secrets
chezmoi execute-template '{{ .infra.vpn_host }}'  # Test template
chezmoi init --force                        # Re-read from 1Password
chezmoi diff                                # Preview changes
chezmoi apply                               # Apply changes

# Verification
chezmoi cat ~/.config/tmuxinator/work.yml   # View rendered file
chezmoi source-path ~/.zshrc                # Find source file
```
