$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$localTvRoot = Join-Path $env:LOCALAPPDATA "television"
$localConfigDir = Join-Path $localTvRoot "config"
$localCableDir = Join-Path $localConfigDir "cable"

New-Item -ItemType Directory -Force -Path $localConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path $localCableDir | Out-Null

$localConfigFile = Join-Path $localConfigDir "config.toml"
if (Test-Path $localConfigFile) {
    $backupFile = Join-Path $localConfigDir ("config.backup.{0}.toml" -f (Get-Date -Format "yyyyMMddHHmmss"))
    Copy-Item $localConfigFile $backupFile -Force
    Write-Host "Backup config => $backupFile"
}

Copy-Item (Join-Path $repoRoot "config.toml") $localConfigFile -Force
Copy-Item (Join-Path $repoRoot "cable\\*.toml") $localCableDir -Force

Write-Host "Sincronizado => $localConfigDir"
