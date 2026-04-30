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

Create two account profiles:

```sh
cx init personal
cx login personal

cx init work
cx login work
```

Create an API-key profile:

```sh
cx init api
printenv OPENAI_API_KEY | cx login api --api-key
```

Run Codex with any profile:

```sh
cx run personal
cx run work
cx run api
```

View profile status:

```sh
cx status --all
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
