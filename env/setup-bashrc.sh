#!/usr/bin/env bash
#
# setup-bashrc.sh — Add conda init + prod activation to each user's bashrc
#
# Run on the target host as peter. Requires sudo (cache creds first).
#
set -euo pipefail

USERS=(peter toni kayden kassandra)

# Validate sudo
if ! sudo -n true 2>/dev/null; then
    echo "ERROR: sudo credentials not cached. Run 'echo pw | sudo -S true' first." >&2
    exit 1
fi

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

for user in "${USERS[@]}"; do
    home=$(eval echo "~${user}")
    bashrc="${home}/.bashrc"
    echo ""
    echo "--- ${user} (${bashrc}) ---"

    # All file checks via sudo since home dirs may be 700
    if ! sudo test -f "$bashrc"; then
        sudo -u "$user" bash -c "touch '${bashrc}'"
        echo "  created empty .bashrc"
    fi

    if sudo grep -q '>>> conda initialize >>>' "$bashrc" 2>/dev/null; then
        echo "  conda init block already present"

        # Replace ANY "conda activate <something-with-paper>" line with prod
        if sudo grep -q 'conda activate.*paper' "$bashrc" 2>/dev/null; then
            sudo sed -i 's#conda activate.*paper.*#conda activate /opt/conda/envs/prod 2>/dev/null || true#' "$bashrc"
            sudo chown "${user}:${user}" "$bashrc"
            echo "  updated: paper -> prod"
        fi

        # Also strip any duplicate conda blocks appended by a previous broken run:
        # If there are multiple ">>> conda initialize >>>" markers, keep only the first block.
        count=""
        count=$(sudo grep -c '>>> conda initialize >>>' "$bashrc" 2>/dev/null || echo 0)
        if [[ "$count" -gt 1 ]]; then
            # Remove everything from the SECOND ">>> conda initialize >>>" to end of file
            # and re-append one clean activation line
            first_end=""
            first_end=$(sudo grep -n '<<< conda initialize <<<' "$bashrc" | head -1 | cut -d: -f1)
            # Keep lines 1 through (first_end + 3) — the block + activation + blank line
            local keep_lines=$(( first_end + 3 ))
            sudo head -n "$keep_lines" "$bashrc" | sudo tee "${bashrc}.tmp" > /dev/null
            sudo mv "${bashrc}.tmp" "$bashrc"
            sudo chown "${user}:${user}" "$bashrc"
            echo "  removed duplicate conda block(s)"
        fi
    else
        printf '\n%s\n' "$CONDA_BASHRC_BLOCK" | sudo tee -a "$bashrc" > /dev/null
        sudo chown "${user}:${user}" "$bashrc"
        echo "  conda block added"
    fi
done

echo ""
echo "=== Verification ==="
for user in "${USERS[@]}"; do
    home=$(eval echo "~${user}")
    bashrc="${home}/.bashrc"
    if sudo grep -q 'conda activate /opt/conda/envs/prod' "$bashrc" 2>/dev/null; then
        paper_count=""
        paper_count=$(sudo grep -c 'conda activate.*paper' "$bashrc" 2>/dev/null || echo 0)
        if [[ "$paper_count" -gt 0 ]]; then
            echo "  ${user}: WARN - still has ${paper_count} paper reference(s)"
        else
            echo "  ${user}: OK"
        fi
    else
        echo "  ${user}: MISSING prod activation"
    fi
done
echo ""
