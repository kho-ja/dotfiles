$ErrorActionPreference = "Stop"

$herdr = $env:HERDR_BIN_PATH
if (-not $herdr) { $herdr = "herdr" }
$lol = "C:\Users\saidkhuja\AppData\Local\Programs\Python\Python312\Scripts\lolcat"

function Hj([string]$raw) { $raw -split "`r?`n" | Where-Object { $_.Trim() } | ConvertFrom-Json }
function RenamePane($id, $label) { & $herdr pane rename $id $label 2>&1 | Out-Null }
function RunCmd($id, $cmd) {
    if ($cmd) { & $herdr pane run $id $cmd 2>&1 | Out-Null }
}
function Relaunch($id, $cmd) {
    if (-not $cmd) { return }
    & $herdr pane send-keys $id ctrl+c 2>&1 | Out-Null
    Start-Sleep -Milliseconds 400
    & $herdr pane run $id $cmd 2>&1 | Out-Null
}

$showCmds = @{
    "figlet"   = "while (`$true) { figlet 'KHO-JA TOYS' | python $lol -a -d 25 -s 40 }"
    "pipes"    = "pipes-rs"
    "neofetch" = "neofetch"
    "matrix"   = "rusty-rain"
    "cowsay"   = "cowsay 'moo from the toys barn' | python $lol -f"
}
$discoCmds = @{
    "rusty-rain"    = "rusty-rain"
    "pipes-rainbow" = "pipes-rs --rainbow 360 -p 20 -k curved"
    "disco-banner"  = "while (`$true) { figlet DISCO | python $lol -a -d 25 -s 40 }"
    "disco-cow"     = "while (`$true) { cowsay 'disco moo' | python $lol -a -d 25 -s 40 }"
}

function Tab-Panes($W, $tabId) {
    (Hj (& $herdr pane list --workspace $W 2>&1)).result.panes | Where-Object { $_.tab_id -eq $tabId }
}
function Find-Tab($W, $label) {
    $tabs = (Hj (& $herdr tab list --workspace $W 2>&1)).result.tabs
    foreach ($t in $tabs) { if ($t.label -eq $label) { return $t } }
    return $null
}
function HasAll($panes, $labels) {
    $have = @($panes.label)
    foreach ($l in $labels) { if ($have -notcontains $l) { return $false } }
    return $true
}
function Refresh-Tab($panes, $cmds) {
    foreach ($p in $panes) { if ($cmds.ContainsKey($p.label)) { Relaunch $p.pane_id $cmds[$p.label] } }
}

try {
    # ---- workspace ----
    $wsList = Hj (& $herdr workspace list 2>&1)
    $toys = @($wsList.result.workspaces | Where-Object { $_.label -eq "toys" })[0]
    if ($toys) {
        $W = $toys.workspace_id
        $fresh = $false
    } else {
        $c = Hj (& $herdr workspace create --cwd $env:USERPROFILE --label toys --no-focus 2>&1)
        $W = $c.result.workspace.workspace_id
        $fresh = $true
    }

    # ---- showroom ----
    $show = Find-Tab $W "showroom"
    if ($fresh) {
        $tabId = $c.result.tab.tab_id
        & $herdr tab rename $tabId showroom 2>&1 | Out-Null
    } elseif ($show) {
        $sp = Tab-Panes $W $show.tab_id
        if (HasAll $sp @("figlet","pipes","neofetch","matrix","cowsay")) {
            Refresh-Tab $sp $showCmds
            $showBuilt = $true
        }
    }
    if (-not $showBuilt) {
        if ($show) { & $herdr tab close $show.tab_id 2>&1 | Out-Null }
        $t = Hj (& $herdr tab create --workspace $W --label showroom --no-focus 2>&1)
        $R  = $t.result.root_pane.pane_id
        $A  = (Hj (& $herdr pane split --pane $R --direction right --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        $B  = (Hj (& $herdr pane split --pane $R --direction down --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        $C  = (Hj (& $herdr pane split --pane $A --direction down --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        $M  = (Hj (& $herdr pane split --pane $B --direction down --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        RenamePane $R "figlet";   RunCmd $R $showCmds["figlet"]
        RenamePane $A "pipes";    RunCmd $A $showCmds["pipes"]
        RenamePane $B "neofetch"; RunCmd $B $showCmds["neofetch"]
        RenamePane $M "matrix";   RunCmd $M $showCmds["matrix"]
        RenamePane $C "cowsay";   RunCmd $C $showCmds["cowsay"]
    }

    # ---- disco ----
    $showBuilt = $false # reset guard (unused below)
    $disco = Find-Tab $W "disco"
    if ($disco) {
        $dp = Tab-Panes $W $disco.tab_id
        if (HasAll $dp @("rusty-rain","pipes-rainbow","disco-banner","disco-cow")) {
            Refresh-Tab $dp $discoCmds
            $discoBuilt = $true
        }
    }
    if (-not $discoBuilt) {
        if ($disco) { & $herdr tab close $disco.tab_id 2>&1 | Out-Null }
        $t = Hj (& $herdr tab create --workspace $W --label disco --no-focus 2>&1)
        $D = $t.result.root_pane.pane_id
        $E = (Hj (& $herdr pane split --pane $D --direction right --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        $F = (Hj (& $herdr pane split --pane $D --direction down --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        $G = (Hj (& $herdr pane split --pane $E --direction down --ratio 0.5 --no-focus 2>&1)).result.pane.pane_id
        RenamePane $D "rusty-rain";    RunCmd $D $discoCmds["rusty-rain"]
        RenamePane $E "pipes-rainbow"; RunCmd $E $discoCmds["pipes-rainbow"]
        RenamePane $F "disco-banner";  RunCmd $F $discoCmds["disco-banner"]
        RenamePane $G "disco-cow";     RunCmd $G $discoCmds["disco-cow"]
    }

    & $herdr workspace focus $W 2>&1 | Out-Null
    exit 0
} catch {
    $msg = $_.Exception.Message
    [System.IO.File]::AppendAllText("C:\Users\saidkhuja\AppData\Roaming\herdr\plugins\toys-startup\toys.err.log", "[$([DateTime]::Now.ToString('s'))] $msg`n")
    exit 1
}