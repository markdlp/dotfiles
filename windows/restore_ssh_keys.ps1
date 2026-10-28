<#
.SYNOPSIS
    Restores SSH private keys from your Bitwarden vault into ~/.ssh/ and locks down their permissions.
.DESCRIPTION
    Requires Bitwarden CLI ('bw', installed via Winget).
    Ensure you have logged in via:
        bw login
    and exported your session:
        $env:BW_SESSION = (bw unlock --raw)
#>

param(
    [string]$ItemName = "SSH Keys"
)

$sshDir = "$env:USERPROFILE\.ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

# Check if bw is available
if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
    Write-Error "Bitwarden CLI ('bw') is not installed. Install it via 'winget install Bitwarden.CLI' and retry."
    exit 1
}

# Verify authentication / session
if (-not $env:BW_SESSION) {
    Write-Host "BW_SESSION not detected. Unlocking Bitwarden vault..." -ForegroundColor Cyan
    $env:BW_SESSION = bw unlock --raw
    if (-not $env:BW_SESSION) {
        Write-Error "Failed to unlock Bitwarden vault."
        exit 1
    }
}

Write-Host "Syncing Bitwarden vault..." -ForegroundColor Cyan
bw sync | Out-Null

# List of keys expected from the dotfiles repository
$keys = @(
    "id_aspire",
    "id_gh_win",
    "id_gitkraken",
    "id_myHair",
    "id_mySkull",
    "id_myWaist",
    "id_zafora"
)

Write-Host "Retrieving SSH private keys from vault item '$ItemName'..." -ForegroundColor Cyan
$vaultItem = bw get item $ItemName | ConvertFrom-Json

if (-not $vaultItem) {
    Write-Warning "Could not find vault item '$ItemName'. Please check the item name in Bitwarden."
    exit 1
}

# Download any matching attachments
foreach ($attachment in $vaultItem.attachments) {
    if ($keys -contains $attachment.fileName) {
        $dest = Join-Path $sshDir $attachment.fileName
        Write-Host "  -> Downloading $($attachment.fileName) to $dest"
        bw get attachment $attachment.fileName --itemid $vaultItem.id --output $dest | Out-Null
    }
}

# Trigger the permission lockdown script
$lockdownScript = Join-Path $PSScriptRoot "run_once_fix-ssh-permissions.ps1"
if (Test-Path $lockdownScript) {
    Write-Host "Locking down private key permissions..." -ForegroundColor Cyan
    & $lockdownScript
}

Write-Host "SSH private key restoration completed successfully!" -ForegroundColor Green

