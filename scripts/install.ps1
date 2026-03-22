$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

[Environment]::SetEnvironmentVariable("TELEVISION_CONFIG", $repoRoot, "User")
$env:TELEVISION_CONFIG = $repoRoot

Write-Host "TELEVISION_CONFIG => $repoRoot"
Write-Host ""
& "$PSScriptRoot\\sync-local.ps1"
Write-Host ""
Write-Host "Validando canales..."
tv --config-file "$repoRoot\\config.toml" --cable-dir "$repoRoot\\cable" list-channels
