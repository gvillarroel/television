# Channel Inventory

This page summarizes the tracked channels in `cable/`, what they search, and what they depend on.

## Core Local Channels

| Channel | Purpose | Depends on | Notes |
| --- | --- | --- | --- |
| `dev` | projects under `~/dev` | local filesystem | default landing channel |
| `dirs` | directories in the current context | local filesystem | shell fallback helper |
| `files` | files in the current context | local filesystem | configured shell fallback |
| `folder` | focused folder navigation | local filesystem | utility channel |
| `env` | environment values | shell env | quick inspection |
| `alias` | shell aliases | shell config | local convenience |
| `text` | text-oriented navigation | local filesystem | generic text search helper |
| `pwsh-history` | PowerShell history | PowerShell history file | used by `ctrl-r` |
| `nu-history` | Nushell history | Nushell history file | optional local helper |
| `dotfiles` | dotfiles and config files | local filesystem | local config lookup |

## Workspace Tooling Channels

| Channel | Purpose | Depends on | Notes |
| --- | --- | --- | --- |
| `npm-scripts` | scripts from `package.json` | Node.js workspace | command completion helper |
| `cargo-packages` | Rust packages in a workspace | Cargo workspace | package-scoped commands |
| `docker-images` | local Docker images | Docker CLI | local runtime inspection |

## Git And Repository Channels

| Channel | Purpose | Depends on | Notes |
| --- | --- | --- | --- |
| `git-repos` | git repos under `C:\Users` | `fd`, local filesystem | used by validation |
| `git-status` | changed files in current repo | `git` | patch-oriented preview |
| `git-branch` | branches in current repo | `git` | preview for branch work |
| `git-log` | recent commits | `git` | patch preview per commit |
| `git-diff` | diff targets | `git` | diff-focused navigation |
| `git-reflog` | reflog entries | `git` | local recovery inspection |

## GitHub And Remote Channels

| Channel | Purpose | Depends on | Notes |
| --- | --- | --- | --- |
| `github-repos` | repositories from the authenticated GitHub account | `gh` auth | used by validation |
| `repos` | recent GitHub repos touched by the current user | `gh` auth | contribution and starred-repo flow |
| `repo-issues` | issues for `TV_REPO` | `gh` auth, `TV_REPO` | used by validation |
| `repo-prs` | pull requests for `TV_REPO` | `gh` auth, `TV_REPO` | used by validation |
| `repo-discussions` | discussions for `TV_REPO` | `gh` auth, `TV_REPO` | used by validation |

## Know Channels

The `know-*` set is the largest channel family. It is designed for the `know` CLI workflow and related source browsing.

Tracked channels:

- `know`
- `know-aha-sync`
- `know-arxiv`
- `know-arxiv-sync`
- `know-brave`
- `know-by-key`
- `know-by-type`
- `know-commands`
- `know-confluence`
- `know-confluence-sync`
- `know-credentials`
- `know-crossref`
- `know-cspaces`
- `know-files`
- `know-follow`
- `know-github-view`
- `know-grepos`
- `know-jira`
- `know-jira-sync`
- `know-jprojects`
- `know-keys`
- `know-local`
- `know-papers`
- `know-recent`
- `know-releases-sync`
- `know-repos`
- `know-sites-browse`
- `know-sources`
- `know-stale`
- `know-stats`
- `know-timeline`
- `know-unsynced`
- `know-videos-browse`

Common dependencies:

- the `know` CLI and its configured sources
- optional provider credentials depending on the selected source
- local knowledge stores and synced artifacts when a channel previews local material

## Maintenance Rules

- keep each channel focused on one navigation task
- document new external dependencies here when adding a channel
- validate changed channels with `tv list-channels`
- run the live validation flow from [operations/windows-setup.md](./operations/windows-setup.md) for GitHub-backed channels
