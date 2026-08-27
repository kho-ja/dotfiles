while ($true) {
    try {
        $current = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction Stop).SystemUsesLightTheme
    } catch { $current = 0 }
    if ($null -eq $script:last) { $script:last = $current }
    if ($current -ne $script:last) {
        Add-Content "$env:LOCALAPPDATA\yasb\theme_watcher.log" "$(Get-Date -Format s) switch $script:last -> $current"
        & "$env:USERPROFILE\.config\yasb-theme-switch.ps1" -Quiet
        $script:last = $current
    }
    Start-Sleep -Seconds 3
}
