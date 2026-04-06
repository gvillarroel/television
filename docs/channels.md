# Built-In Channels

The repository already includes channels for local repositories, Git state, GitHub, and
workspace-specific commands.

## Channel Groups

- repository discovery channels such as `dev` and `git-repos`
- git inspection channels such as `git-status`, `git-branch`, and `git-log`
- remote context channels such as `github-repos` and `repos`
- workspace utility channels such as `npm-scripts` and `cargo-packages`

## Maintenance Guidance

- keep channels focused on one navigation task
- prefer previews that explain the selected entry immediately
- validate every changed channel with `tv list-channels`

## Future Additions

- project-specific channels for active repositories
- channels that surface generated docs or reports
- higher-signal previews for monorepo workspaces
