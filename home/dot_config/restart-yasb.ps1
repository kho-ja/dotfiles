param([string]$AppName = "")

if ($AppName -and $AppName -notmatch "yasb\.exe$") { exit 0 }

Start-Sleep -Seconds 5
$running = Get-Process -Name "yasb" -ErrorAction SilentlyContinue
if (-not $running) {
    Start-Process "C:\Program Files\YASB\yasb.exe" -ArgumentList "start" -WindowStyle Hidden
    Start-Transcript -Path "$env:LOCALAPPDATA\yasb\restart_watchdog.log" -Append
    "$(Get-Date -Format s) restarted yasb after crash of: $AppName" | Out-Host
    Stop-Transcript
}
