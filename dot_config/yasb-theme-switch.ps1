param([switch]$Quiet)

$yasbDir = "$env:USERPROFILE\.config\yasb"
$dark  = Join-Path $yasbDir "styles-dark.css"
$light = Join-Path $yasbDir "styles-light.css"
$active = Join-Path $yasbDir "styles.css"

try {
    $useLight = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction Stop).SystemUsesLightTheme
} catch {
    $useLight = 0
}

$desired = if ($useLight -eq 1) { $light } else { $dark }

if (-not (Test-Path $desired)) {
    if (-not $Quiet) { Write-Error "Missing theme file: $desired" }
    exit 1
}

$desiredHash = (Get-FileHash $desired -Algorithm SHA256).Hash
$activeHash  = if (Test-Path $active) { (Get-FileHash $active -Algorithm SHA256).Hash } else { "" }

if ($desiredHash -ne $activeHash) {
    Copy-Item $desired $active -Force
    if (-not $Quiet) { Write-Host "yasb theme switched to $(if ($useLight -eq 1) {'light'} else {'dark'})" }
} elseif (-not $Quiet) {
    Write-Host "yasb theme already $(if ($useLight -eq 1) {'light'} else {'dark'})"
}
