y# Clean Android SDK Setup Script for Flutter
# Run this in PowerShell as Administrator if needed

# 1) Set SDK root
$env:ANDROID_SDK_ROOT = 'C:\Users\Charles\AppData\Local\Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT  # Legacy compat
$SdkRoot = $env:ANDROID_SDK_ROOT

Write-Host "Android SDK Root: $SdkRoot"

# 2) Clean existing cmdline-tools (keep latest if clean)
$cmdlineDir = "$SdkRoot\cmdline-tools"
if (Test-Path $cmdlineDir) {
    Get-ChildItem $cmdlineDir -Directory | ForEach-Object {
        if ($_.Name -ne 'latest') {
            Write-Host "Removing duplicate: $($_.FullName)"
            Remove-Item $_.FullName -Recurse -Force
        }
    }
}

# 3) Download latest commandlinetools (as of 2024)
$downloadUrl = 'https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip'
$zipPath = "$env:USERPROFILE\Downloads\commandlinetools-win-latest.zip"
Write-Host "Downloading from $downloadUrl to $zipPath..."

if (!(Test-Path $zipPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
}

# 4) Extract to temp, move to cmdline-tools/latest
$tempExtract = "$env:TEMP\cmdline-tools-extract"
Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $zipPath $tempExtract

$dest = "$SdkRoot\cmdline-tools"
$latestDir = "$dest\latest"

# Create cmdline-tools if not exists
if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

# Move extracted cmdline-tools to latest
$extractedCmdline = Get-ChildItem $tempExtract -Directory | Where-Object { $_.Name -like 'cmdline-tools*' } | Select-Object -First 1
if ($extractedCmdline) {
    Move-Item $extractedCmdline.FullName $latestDir -Force
} else {
    # Direct move if no subdir
    Get-ChildItem $tempExtract | Move-Item -Destination $latestDir -Force
}

Remove-Item $tempExtract -Recurse -Force
Write-Host "Extracted to $latestDir"

# 5) Install required packages (modern versions for Flutter 3.24+)
$sdkmanager = "$latestDir\bin\sdkmanager.bat"
& $sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "cmdline-tools;latest"

# 6) Accept all licenses
Write-Host "Accepting licenses... Type 'y' when prompted."
& $sdkmanager --licenses

# 7) Add to PATH permanently
$path = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($path -notlike "*$SdkRoot\platform-tools*" -and $path -notlike "*$latestDir\bin*") {
    $newPath = "$path;$SdkRoot\platform-tools;$latestDir\bin"
    [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
    Write-Host "PATH updated. Restart terminal/PowerShell."
}

# 8) Verify
Write-Host "Setup complete! Run 'flutter doctor' to verify."
flutter doctor --android-licenses  # Auto-accept any remaining

# Cleanup zip
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

