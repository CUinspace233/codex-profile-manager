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
cx i main
cx l main
cx r main
```

Create and log in to an API-key profile:

```sh
cx i api
printenv OPENAI_API_KEY | cx l api --api-key
cx r api
```

View profile status:

```sh
cx s --all
```

Switch the current shell to a profile:

```sh
eval "$(cx sw main)"
codex
```

## Commands

Short form:

```sh
cx i <name>                 # init
cx l <name> [--api-key]     # login
cx s [<name>|--all]         # status
cx r <name> [codex args...] # run codex with profile
cx sw <name>                # print export CODEX_HOME=...
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
CODEX_PROFILE_ROOT=/path/to/profiles cx s --all
```

By default, new profiles copy non-sensitive config from:

```sh
~/.codex/config.toml
```

Override the source:

```sh
CODEX_PROFILE_SOURCE=/path/to/source cx i work
```

Skip config copying:

```sh
cx i clean --no-copy-config
```

## Security Notes

The tool does not read or print `auth.json`. It lets `codex login` create and
manage authentication inside the selected profile directory.

Avoid committing profile directories, `auth.json`, or API keys.
