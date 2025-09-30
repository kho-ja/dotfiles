# Prompt
Import-Module posh-git
oh-my-posh init pwsh --config "~/.config/oh-my-posh/theme.omp.json"  | Invoke-Expression

# Icon
Import-Module -Name Terminal-Icons

# Syntax Highlighting
Set-PSReadLineOption -Colors @{
    Command = 'Green'
    Operator = 'Yellow'
    Parameter = 'Cyan'
    String = 'Magenta'
    Number = 'DarkCyan'
    Variable = 'Blue'
    Error = 'Red'
}

# PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Key "Ctrl+K" -Function KillLine
Set-PSReadLineKeyHandler -Key "Ctrl+L" -ScriptBlock { Clear-Host }

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Alias
Set-Alias a 'php artisan'
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Git Clean gone Branches
function git-clean-gone {
    param([switch]$Force)

    git fetch -p
    $branches = git branch -vv | ForEach-Object {
        if ($_ -match "(\S+)\s+.*: gone]") { $matches[1] }
    }
    if ($branches) {
        if ($Force) {
            $branches | ForEach-Object { git branch -D $_ }
        } else {
            $branches | ForEach-Object { git branch -d $_ }
        }
    } else {
        Write-Output "No gone branches to delete."
    }
}

