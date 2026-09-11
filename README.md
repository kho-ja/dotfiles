# kho-ja/dotfiles

Dotfiles managed with [chezmoi](https://chezmoi.io).

This repository is itself your chezmoi source state. The actual dotfiles live in
[`home/`](home/); the root only holds repo-level files (this README, `.gitattributes`), so
nothing in this README ever ends up in your home directory.

## What's managed

| Area | Target(s) |
| --- | --- |
| Terminal | `~/.config/windows-terminal/settings.json` |
| Shell | PowerShell profiles (`~/.config/powershell/user_profile.ps1`, `Documents/PowerShell/Microsoft.PowerShell_profile.ps1`) |
| Prompt | `~/.config/oh-my-posh/theme.omp.json` |
| Window manager | `~/komorebi.json`, `~/komorebi.bar.json`, `~/applications.json`, `~/.config/whkdrc` |
| Bar | `~/.config/yasb/config.yaml`, `~/.config/yasb/styles.css` |
| Wallpapers | `~/Pictures/Wallpapers/**` (Git LFS) |
| herdr plugin | `~/AppData/Roaming/herdr/plugins/toys-startup` |

Running `chezmoi managed` lists everything currently tracked.

## Quick start

On a new machine (Windows with winget):

```powershell
# 1) Get chezmoi (any install method works - winget/shims/script)
winget install twpayne.chezmoi

# 2) Apply this config; you'll be asked which profile (home / work) once
chezmoi init --apply kho-ja
```

Profile and later tweaks are persisted in `~/.config/chezmoi/chezmoi.toml` (generated from
`home/.chezmoi.toml.tmpl`, never committed).

## What the setup installs

The first `chezmoi apply` runs a one-time bootstrap that installs only what running the setup
itself needs, so it works from a bare machine:

- **winget**: `twpayne.chezmoi`, `Git.Git`, `Microsoft.PowerShell`, `Herdr.Herdr.Preview`
- **scoop** (+ `extras` bucket), then the toys: `cowsay`, `figlet`, `neo-cowsay`, `pipes-rs`

Everything else is installed manually on purpose — see below.

## Manual setup

These are deliberately **not** auto-installed. Install them once yourself:

| Tool | Install | Notes |
| --- | --- | --- |
| komorebi / whkd | `winget install LGUG2Z.komorebi LGUG2Z.whkd` | window manager + hotkeys |
| YASB | `winget install AmN.yasb` | status bar; restarted by the `apply.post` hook via `~/.config/restart-yasb.ps1` |
| Oh My Posh | `winget install JanDeDobbeleer.OhMyPosh` | prompt engine |
| Editors / agents | e.g. Neovim, VS Code, Cursor, Zed, Warp, Claude Code, Codex, Grok, OpenCode | add any via winget |
| PostgreSQL | `winget install PostgreSQL.PostgreSQL.16` | as needed |
| wmux | its own installer / updater | `wmux` CLI + friend/gateway |
| herdr agent integrations | `herdr integration install` | wire herdr into your AI CLIs |

## Daily workflow

| Action | Command |
| --- | --- |
| Make a change (file gets modified) | `chezmoi re-add` (respects `.chezmoiignore` secrets) |
| Test before applying | `chezmoi diff` |
| Apply everything | `chezmoi apply` |
| Full verify | `chezmoi verify` |
| Commit + push | `chezmoi git push` |

### Adding packages to the setup

Edit `home/.chezmoidata/packages.yaml`:

```yaml
scoop:          # installs via scoop
  - <package>
winget_setup:   # installs via winget during bootstrap
  - <Publisher.Id>
```

`chezmoi apply` re-runs the matching installer whenever that file changes.

## Ignored on purpose

`home/.chezmoiignore` keeps runtime state and secrets out of the repo (auth tokens,
credentials, known_hosts, logs, tmp files). `chezmoi re-add` will never pick them up.

## Repository layout

```
.
├── .chezmoiroot      → points chezmoi at home/ as the source root
├── .gitattributes    → Git LFS rule for Pictures/Wallpapers/**
├── README.md         → this file (never applied)
└── home/             → actual source state
    ├── .chezmoi.toml.tmpl      → profile prompt + apply.post hook
    ├── .chezmoiignore          → runtime state + secrets
    ├── .chezmoidata/packages.yaml
    ├── run_once_after_install-bootstrap.ps1.tmpl   → winget + scoop bootstrap
    ├── run_onchange_install-scoop-packages.ps1.tmpl
    └── …rest of the dotfiles
```

## References

- [chezmoi](https://chezmoi.io) — docs: [user guide](https://chezmoi.io/user-guide/setup/),
  [declarative packages](https://chezmoi.io/user-guide/advanced/install-packages-declaratively/),
  [source directory layout](https://chezmoi.io/user-guide/advanced/customize-your-source-directory/)