# Windows Setup

These steps keep the repository aligned with the local `television` runtime on Windows.

## Prerequisites

Required:

- Windows PowerShell
- `tv`
- `fd`

Required for GitHub-backed channels and full validation:

- `gh`
- authenticated GitHub CLI session

Useful checks:

```powershell
tv --version
fd --version
gh auth status
```

## Installation Flow

1. Run `./scripts/install.ps1`.
2. Confirm `TELEVISION_CONFIG` points to this repository.
3. Run `./scripts/validate.ps1`.
4. Open `tv list-channels` and verify the expected channels appear.

What `install.ps1` does:

- sets the user-level `TELEVISION_CONFIG`
- syncs `config.toml` and `cable/*.toml` into `%LOCALAPPDATA%\television\config`
- runs `tv list-channels` against this repo config

What `validate.ps1` does:

- checks channel loading through `tv`
- validates local repo discovery
- validates GitHub-backed repo, issue, PR, and discussion flows
- depends on live `gh` access and network reachability

## When to Re-Sync

- after changing `config.toml`
- after adding or renaming a cable file
- after moving scripts referenced by a channel

## Troubleshooting

- if a channel is missing, verify the cable file name and the local sync target
- if previews fail, run the underlying command directly from PowerShell first
- if environment variables changed, restart the terminal before validating again
- if GitHub-backed validation fails, check `gh auth status`
- if `git-repos` fails, verify `fd` is installed and can search under `C:\Users`
- if channel listing works but live repo channels fail, treat that as a dependency or auth problem, not a config parse problem
