# This script runs automatically during 'chezmoi apply' if the JSON file changes.
$PackageList = Join-Path $PSScriptRoot "my-winget-packages.json"

Write-Host "Installing Windows applications via Winget..." -ForegroundColor Cyan
winget import -i $PackageList --accept-package-agreements --accept-source-agreements

Write-Host "Software installation complete!" -ForegroundColor Green