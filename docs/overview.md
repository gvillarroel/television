# Configuration Overview

The goal of this repository is to keep one portable `television` setup that can be used
both as the live local configuration and as a versioned source of truth.

## Repository Responsibilities

- define the baseline `config.toml`
- provide reusable channel definitions under `cable/`
- ship install, sync, and validation scripts for Windows workflows

## Expected Workflow

1. Edit the tracked configuration in this repository.
2. Run the sync or install script.
3. Validate that `tv` can read the updated configuration.
4. Iterate on channels with quick local feedback.

## Documentation Goal

The docs should make it obvious which files change the shell experience, where channels
live, and how to validate a new channel before relying on it daily.
