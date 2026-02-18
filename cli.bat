@echo off
rem cli.bat - Windows dotfiles CLI wrapper
rem Delegates to cli.ps1 via PowerShell 7 (pwsh)

where pwsh >nul 2>&1
if errorlevel 1 (
    echo Error: PowerShell 7 ^(pwsh^) is required but not found.
    echo Install it with: winget install Microsoft.PowerShell
    exit /b 1
)

pwsh -NoProfile -NoLogo -File "%~dp0cli.ps1" %*
exit /b %errorlevel%
