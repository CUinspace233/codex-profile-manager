# Codex Profile Manager

Small CLI helper for using multiple Codex CLI logins on the same machine.

Use it to keep several ChatGPT account logins and API-key logins side by side,
then launch Codex with the profile you want:

```sh
cx run personal
cx run work
cx run api
```

Each profile gets its own isolated `CODEX_HOME`, so logging in to one account
does not overwrite another account or API-key profile.

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

Create a profile with the guided setup:

```sh
cx setup
```

The setup flow handles profile creation, optional `OPENAI_BASE_URL`, and
account or API-key login. After setup, run Codex with that profile:

```sh
cx run <name>
```

For example:

```sh
cx run personal
cx run work
cx run api
```

View profile status:

```sh
cx status
```

## Manual Commands

The guided setup is the normal path. Use these commands when you want to script
or change a specific part of a profile.

Create account profiles manually:

```sh
cx init personal
cx login personal

cx init work
cx login work
```

Create an API-key profile manually:

```sh
cx init api
export OPENAI_API_KEY='sk-...'
printenv OPENAI_API_KEY | cx login api --api-key
```

`printenv` reads an environment variable by name. If you want to paste the key
directly instead, use:

```sh
printf '%s\n' 'sk-...' | cx login api --api-key
```

Set or unset a profile-specific API base URL:

```sh
cx base-url api https://api.example.com/v1
cx base-url api --unset
```

Delete a profile:

```sh
cx delete old-work
```

Switch the current shell to a profile:

```sh
eval "$(cx switch personal)"
codex
```

## Existing Login

The tool does not automatically copy your current `~/.codex/auth.json` into a
profile. Authentication files contain sensitive tokens, so importing an existing
login should be an explicit action.

To turn your current Codex login into the `main` profile:

```sh
cx init main
cp ~/.codex/auth.json ~/.codex-profiles/main/auth.json
chmod 600 ~/.codex-profiles/main/auth.json
cx status main
```

## Commands

Short form:

```sh
cx setup
cx init <name>
cx login <name> [--api-key]
cx status [<name>]
cx base-url <name> [url|--unset]
cx delete <name>
cx run <name> [codex args...]
cx switch <name>
```

Long form:

```sh
codex-profile setup
codex-profile init <name> [--no-copy-config]
codex-profile login <name> [--api-key]
codex-profile status [<name>]
codex-profile list
codex-profile base-url <name> [url|--unset]
codex-profile delete <name>
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
CODEX_PROFILE_ROOT=/path/to/profiles cx status
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

Per-profile `OPENAI_BASE_URL` overrides are stored in:

```sh
~/.codex-profiles/<name>/openai_base_url
```

When a profile does not have this file, `cx run`, `cx login`, `cx status`, and
`cx switch` unset `OPENAI_BASE_URL`, so Codex uses its default endpoint.

## Security Notes

The tool does not read or print `auth.json`. It lets `codex login` create and
manage authentication inside the selected profile directory.

Avoid committing profile directories, `auth.json`, or API keys.
