# Windows AI agents deploy — PowerShell port of the bash version
# Creates symlinks for AI agent configs in ~/acap/

$ErrorActionPreference = "Stop"

$acapDir = Join-Path $env:USERPROFILE "acap"
$aiAgentsDir = Join-Path $acapDir ".ai_agents"

# Skip gracefully if .ai_agents repo not cloned yet
if (-not (Test-Path $aiAgentsDir)) {
    Write-Host "==> Skipping AI agents deploy: $aiAgentsDir not found"
    exit 0
}

Write-Host "==> Deploying AI agent configuration..."

function Ensure-AgentSymlink {
    param(
        [string]$Link,
        [string]$Target
    )
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -eq "SymbolicLink") { return }
        Remove-Item $Link -Force -Recurse -ErrorAction SilentlyContinue
    }
    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    Write-Host "    Linked $(Split-Path $Link -Leaf)"
}

# --- Parent-level symlinks (~/acap/) ---

Ensure-AgentSymlink `
    -Link (Join-Path $acapDir "CLAUDE.md") `
    -Target (Join-Path $aiAgentsDir "CLAUDE.md")

Ensure-AgentSymlink `
    -Link (Join-Path $acapDir "AGENTS.md") `
    -Target (Join-Path $aiAgentsDir "AGENTS.md")

# ~/acap/.claude/rules/ and commands/
$claudeDir = Join-Path $acapDir ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

Ensure-AgentSymlink `
    -Link (Join-Path $claudeDir "rules") `
    -Target (Join-Path $aiAgentsDir "claude\rules")

Ensure-AgentSymlink `
    -Link (Join-Path $claudeDir "commands") `
    -Target (Join-Path $aiAgentsDir "claude\commands")

# --- Per-project symlinks ---

Get-ChildItem -Path $acapDir -Directory | Where-Object {
    $_.Name -ne ".ai_agents" -and (Test-Path (Join-Path $_.FullName ".git"))
} | ForEach-Object {
    $projectDir = $_.FullName
    $projectName = $_.Name
    $projectClaude = Join-Path $projectDir ".claude"
    if (-not (Test-Path $projectClaude)) {
        New-Item -ItemType Directory -Path $projectClaude -Force | Out-Null
    }

    $rulesLink = Join-Path $projectClaude "rules"
    if (-not (Test-Path $rulesLink) -or (Get-Item $rulesLink -Force).LinkType -ne "SymbolicLink") {
        Remove-Item $rulesLink -Force -Recurse -ErrorAction SilentlyContinue
        New-Item -ItemType SymbolicLink -Path $rulesLink `
            -Target (Join-Path $aiAgentsDir "claude\rules") -Force | Out-Null
        Write-Host "    Linked $projectName/.claude/rules/"
    }

    $cmdsLink = Join-Path $projectClaude "commands"
    if (-not (Test-Path $cmdsLink) -or (Get-Item $cmdsLink -Force).LinkType -ne "SymbolicLink") {
        Remove-Item $cmdsLink -Force -Recurse -ErrorAction SilentlyContinue
        New-Item -ItemType SymbolicLink -Path $cmdsLink `
            -Target (Join-Path $aiAgentsDir "claude\commands") -Force | Out-Null
        Write-Host "    Linked $projectName/.claude/commands/"
    }
}

# --- Codex prompts ---

$codexPromptsDir = Join-Path $env:USERPROFILE ".codex\prompts"
if (-not (Test-Path $codexPromptsDir)) {
    New-Item -ItemType Directory -Path $codexPromptsDir -Force | Out-Null
}

$codexSourceDir = Join-Path $aiAgentsDir "codex\prompts"
if (Test-Path $codexSourceDir) {
    Get-ChildItem -Path $codexSourceDir -Filter "acap-*.md" | ForEach-Object {
        $target = Join-Path $codexPromptsDir $_.Name
        if (-not (Test-Path $target) -or (Get-Item $target -Force).LinkType -ne "SymbolicLink") {
            Remove-Item $target -Force -ErrorAction SilentlyContinue
            New-Item -ItemType SymbolicLink -Path $target -Target $_.FullName -Force | Out-Null
            Write-Host "    Linked codex prompt: $($_.Name)"
        }
    }
}

Write-Host "==> AI agent configuration deployed."

# --- User-level agent configs (~/.agents) ---
$agentsDir = Join-Path $env:USERPROFILE ".agents"
$agentsCli = Join-Path $agentsDir "cli"
if ((Test-Path $agentsDir) -and (Test-Path $agentsCli)) {
    # Try to run via git-bash if available
    $gitBash = "D:\tool\git\bin\bash.exe"
    if (Test-Path $gitBash) {
        Write-Host "==> Applying user-level agent configs from ~/.agents..."
        & $gitBash -c "$agentsCli install"
    }
}
