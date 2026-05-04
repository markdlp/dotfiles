# This script is executed by chezmoi to lock down SSH private key permissions on Windows.
$sshDir = "$env:USERPROFILE\.ssh"

if (Test-Path $sshDir) {
    Write-Host "Securing SSH private keys in $sshDir..." -ForegroundColor Cyan

    # Find all files in the .ssh directory that are likely private keys.
    # We do this by EXCLUDING known non-private file types/names.
    $privateKeys = Get-ChildItem -Path $sshDir -File | Where-Object {
        $_.Name -notmatch '\.pub$' -and     # Ignore public keys
        $_.Name -notmatch '\.ppk$' -and     # Ignore PuTTY formatted keys
        $_.Name -ne 'config' -and           # Ignore the config file
        $_.Name -notmatch '^known_hosts'    # Ignore known_hosts and known_hosts.old
    }

    foreach ($key in $privateKeys) {
        $KeyPath = $key.FullName
        Write-Host "  -> Locking down: $($key.Name)"
        
        # 1. Strip all inherited permissions (removes System, Everyone, etc.)
        icacls.exe $KeyPath /inheritance:r /Q | Out-Null
        
        # 2. Grant the current specific user Full Control
        icacls.exe $KeyPath /grant "$env:USERNAME`:F" /Q | Out-Null
    }

    Write-Host "SSH permissions successfully secured!" -ForegroundColor Green
} else {
    Write-Host "No .ssh directory found. Skipping permission fix." -ForegroundColor Yellow
}