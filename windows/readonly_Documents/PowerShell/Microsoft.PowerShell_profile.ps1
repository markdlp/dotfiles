# Initialize Oh My Posh with local atomic theme (matching Linux/Nix systems)
if ($env:POSH_THEMES_PATH -and (Test-Path "$env:POSH_THEMES_PATH\atomic.omp.json")) {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\atomic.omp.json" | Invoke-Expression
} else {
    oh-my-posh init pwsh | Invoke-Expression
}

# --- Productive Aliases ---
Set-Alias -Name cat -Value bat -Option AllScope -ErrorAction SilentlyContinue
Set-Alias -Name nano -Value micro -Option AllScope -ErrorAction SilentlyContinue
function ll { Get-ChildItem -Force @args }
