# Change this letter to whatever your USB adapter maps the old drive to!
$OldDrive = "D:" 

# List the exact files and folders you want to migrate
$ItemsToCopy = @(
    "\Users\mark\AppData\Roaming\Code\User\settings.json",
    "\Users\mark\AppData\Roaming\Code\User\keybindings.json",
    "\Users\mark\.ssh"
)

foreach ($item in $ItemsToCopy) {
    $Source = "$OldDrive$item"
    $Destination = "C:$item"

    if (Test-Path $Source) {
        Write-Host "Copying $item..."
        # Ensure the destination folder exists before copying
        $DestDir = Split-Path $Destination
        if (-not (Test-Path $DestDir)) { New-Item -ItemType Directory -Force -Path $DestDir | Out-Null }
        
        Copy-Item -Path $Source -Destination $Destination -Recurse -Force
    } else {
        Write-Host "Skipped: $Source not found." -ForegroundColor Yellow
    }
}