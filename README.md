# television

Personal `television` (`tv`) configuration repository, intended to be used as `TELEVISION_CONFIG`.

## What This Includes

- `config.toml` with a terminal and development oriented base setup
- `cable/` with dedicated channels for repositories, git state, GitHub, and project scripts
- `scripts/install.ps1` to point `tv` at this repository
- `scripts/sync-local.ps1` to mirror the config into `%LocalAppData%`
- `scripts/validate.ps1` to verify that `tv` can load this configuration

## Activation

```powershell
./scripts/install.ps1
```

This sets the user-level `TELEVISION_CONFIG` variable to this repository and synchronizes the configuration into the local Windows directory that `tv` already uses.

## Dedicated Channels

- `dev`: projects under `~/dev`, annotated with detected stack signals and repository preview
- `git-status`: changed files in the current repository with file preview
- `git-branch`: local and remote branches sorted by recent activity
- `git-log`: recent commits with full patch preview
- `github-repos`: repositories from the authenticated GitHub account
- `repos`: GitHub repositories touched in the last 6 months through pins, stars, commits, PRs, reviews, or PR comments
- `npm-scripts`: scripts from the current `package.json`
- `cargo-packages`: Rust packages detected from the current workspace

## Validation

```powershell
./scripts/validate.ps1
tv list-channels
tv dev
```
