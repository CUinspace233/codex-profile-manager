# Codex Profile Manager

Small CLI helper for switching Codex CLI authentication profiles.

It isolates each login under its own `CODEX_HOME`, so you can switch between
multiple ChatGPT accounts or an API-key profile without overwriting
`~/.codex/auth.json`.

## Install

From this directory:

```sh
./scripts/install.sh
```

This installs:

- `codex-profile` to `~/.local/bin/codex-profile`
- `cx` as a short alias command

Make sure `~/.local/bin` is in your `PATH`.

## Quick Start

Create and log in to an account profile:

```sh
cx init main
cx login main
cx run main
```

Create and log in to an API-key profile:

```sh
cx init api
printenv OPENAI_API_KEY | cx login api --api-key
cx run api
```

View profile status:

```sh
cx status --all
```

Switch the current shell to a profile:

```sh
eval "$(cx switch main)"
codex
```

## Commands

Short form:

```sh
cx init <name>
cx login <name> [--api-key]
cx status [<name>|--all]
cx run <name> [codex args...]
cx switch <name>
```

Long form:

```sh
codex-profile init <name> [--no-copy-config]
codex-profile login <name> [--api-key]
codex-profile status [<name>|--all]
codex-profile list
codex-profile run <name> [codex args...]
codex-profile switch <name>
codex-profile shell-aliases
codex-profile path <name>
```

## Configuration

Profiles are stored in:

```sh
~/.codex-profiles/<name>
```

You can override this:

```sh
CODEX_PROFILE_ROOT=/path/to/profiles cx status --all
```

By default, new profiles copy non-sensitive config from:

```sh
~/.codex/config.toml
```

Override the source:

```sh
CODEX_PROFILE_SOURCE=/path/to/source cx init work
```

Skip config copying:

```sh
cx init clean --no-copy-config
```

## Security Notes

The tool does not read or print `auth.json`. It lets `codex login` create and
manage authentication inside the selected profile directory.

Avoid committing profile directories, `auth.json`, or API keys.
