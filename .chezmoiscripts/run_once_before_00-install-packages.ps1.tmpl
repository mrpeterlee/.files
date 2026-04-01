# Windows package installation via winget
# Runs once before other setup scripts

$ErrorActionPreference = "Stop"

Write-Host "==> Installing Windows packages via winget..."

$packages = @(
    @{ Id = "AgileBits.1Password.CLI";    Name = "1Password CLI" }
    @{ Id = "BurntSushi.ripgrep.MSVC";   Name = "ripgrep" }
    @{ Id = "sharkdp.bat";               Name = "bat" }
    @{ Id = "ajeetdsouza.zoxide";        Name = "zoxide" }
    @{ Id = "eza-community.eza";         Name = "eza" }
)

foreach ($pkg in $packages) {
    $installed = winget list --id $pkg.Id --accept-source-agreements 2>$null |
        Select-String $pkg.Id
    if ($installed) {
        Write-Host "    [ok] $($pkg.Name) already installed"
    } else {
        Write-Host "    [install] $($pkg.Name)..."
        winget install --id $pkg.Id --accept-source-agreements --accept-package-agreements --silent
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "    [warn] Failed to install $($pkg.Name)"
        }
    }
}

Write-Host "==> Windows package installation complete."
