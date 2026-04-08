# Configuration Overview

The goal of this repository is to keep one portable `television` setup that can be used
both as the live local configuration and as a versioned source of truth.

## Runtime Model

There are two important runtime states:

1. `TELEVISION_CONFIG` points at this repository.
2. `scripts/sync-local.ps1` copies `config.toml` and `cable/*.toml` into `%LOCALAPPDATA%\television\config`.

That split matters:

- the repo is the editable source of truth
- the local app directory is the copied runtime state
- `install.ps1` sets `TELEVISION_CONFIG`, runs sync, then lists channels
- `validate.ps1` runs live checks against `tv`, `gh`, and repository-driven channels

## Repository Responsibilities

- define the baseline `config.toml`
- provide reusable channel definitions under `cable/`
- ship install, sync, and validation scripts for Windows workflows

## Expected Workflow

1. Edit the tracked configuration in this repository.
2. Run the sync or install script.
3. Validate that `tv` can read the updated configuration and that live channels still resolve.
4. Iterate on channels with quick local feedback.

## Documentation Goal

The docs should make it obvious which files change the shell experience, where channels
live, and how to validate a new channel before relying on it daily.

## Shell Behavior

Current user-visible defaults from `config.toml`:

- default channel: `dev`
- shell fallback channel: `files`
- history is global and stored across channels
- `ctrl-t` opens smart autocomplete
- `ctrl-r` opens command history
- `ctrl-s` cycles sources
- `ctrl-o` toggles preview

Important shell integration triggers:

- `git checkout`, `git branch`, `git merge`, `git pull`, `git push` -> `git-branch`
- `git add`, `git restore`, `git rm` -> `git-status`
- `gh repo clone`, `gh repo view` -> `github-repos`
- `gh browse`, `gh issue list --repo`, `gh pr list --repo` -> `repos`
- `npm run`, `npm exec`, `npx`, `pnpm run` -> `npm-scripts`

## Next Reads

- [operations/windows-setup.md](./operations/windows-setup.md)
- [channels.md](./channels.md)
