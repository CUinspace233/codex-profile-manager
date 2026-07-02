# Codex Profile Manager

Small CLI helper for using multiple Codex CLI logins on the same machine.

Use it to keep several ChatGPT account logins and API-key logins side by side,
then launch Codex with the profile you want:

```sh
cx run personal
cx run work
cx run api-openrouter
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

The setup flow handles profile creation, optional OpenAI-compatible base URL,
and account or API-key login. After setup, run Codex with that profile:

```sh
cx run <name>
```

For example:

```sh
cx run personal
cx run work
cx run api-openrouter
cx run api-deepseek
```

View profile status:

```sh
cx status
```

Resume another profile's conversations with the current profile's login and
configuration:

```sh
cx run api-openrouter resume-from personal
```

This opens Codex's interactive resume picker for `personal` sessions while
running with the `api-openrouter` profile.

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
cx init api-openrouter
export OPENAI_API_KEY='sk-...'
printenv OPENAI_API_KEY | cx login api-openrouter --api-key
```

`printenv` reads an environment variable by name. If you want to paste the key
directly instead, use:

```sh
printf '%s\n' 'sk-...' | cx login api-openrouter --api-key
```

Set or unset a profile-specific API base URL:

```sh
cx base-url api-openrouter https://api.example.com/v1
cx base-url api-openrouter --unset
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

Resume sessions from another profile:

```sh
cx run work resume-from personal
cx run api-openrouter resume-from work --last
```

`resume-from` links the target profile's `sessions` directory to the source
profile's `sessions` directory, then runs `codex resume --all`. Authentication,
base URL, and other config still come from the target profile. If the target
profile already has its own `sessions` directory, it is moved aside as
`sessions.local.<timestamp>` before the link is created.

If linking the target to the source would create a sessions symlink loop,
`resume-from` creates a shared profile named `shared-<first>-<second>`, moves
the real sessions directory there, and points both profiles at the shared
sessions directory. It stops without changing either profile if the source
sessions link is dangling or cyclic, or if neither side owns a real sessions
directory that can be moved safely.

`cx delete <name>` refuses to remove a profile while another profile's
`sessions` link points to it. Repoint the dependent profile first so deletion
cannot leave a dangling sessions link.

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

Per-profile base URL overrides are tracked in:

```sh
~/.codex-profiles/<name>/openai_base_url
```

When this file is present, `cx run` passes Codex the matching
`openai_base_url` config override and syncs the same setting into the profile's
`config.toml`. When it is absent, Codex uses its default endpoint.

When `cx setup` creates an API-key profile, it asks for only a suffix and names
the profile `api-<suffix>`. For example, suffix `openrouter` creates
`api-openrouter`.

## Security Notes

The tool does not read or print `auth.json`. It lets `codex login` create and
manage authentication inside the selected profile directory.

Avoid committing profile directories, `auth.json`, or API keys.
