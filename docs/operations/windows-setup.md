# Windows Setup

These steps keep the repository aligned with the local `television` runtime on Windows.

## Installation Flow

1. Run `./scripts/install.ps1`.
2. Confirm `TELEVISION_CONFIG` points to this repository.
3. Run `./scripts/validate.ps1`.
4. Open `tv list-channels` and verify the expected channels appear.

## When to Re-Sync

- after changing `config.toml`
- after adding or renaming a cable file
- after moving scripts referenced by a channel

## Troubleshooting

- if a channel is missing, verify the cable file name and the local sync target
- if previews fail, run the underlying command directly from PowerShell first
- if environment variables changed, restart the terminal before validating again
