# OpenCode setup guide

This repository reproduces the OpenCode V2 setup captured on 2026-09-15.
It is a portable description of the setup, not a copy of OpenCode runtime
state.

## Repository layout

The active local plugins are published separately:

| Component | Repository | License | Purpose |
| --- | --- | --- | --- |
| Agent order | [opencode-agent-order](https://github.com/SoloUnity/opencode-agent-order) | MIT | Places `plan`, `build`, `orchestrator`, and `council` first. |
| DCG adapter | [opencode-dcg-guard](https://github.com/SoloUnity/opencode-dcg-guard) | MIT | Sends OpenCode shell commands to the separately installed DCG binary. |
| Herdr primary reporting | [herdr-opencode](https://github.com/SoloUnity/herdr-opencode) | Apache-2.0 | Reports the primary OpenCode session to Herdr. It contains modified Herdr source. |
| Herdr subagent panes | [herdr-subagent-panes](https://github.com/SoloUnity/herdr-subagent-panes) | MIT | Opens and manages Herdr panes for child sessions. |

The other active plugin is the third-party package
`oh-my-opencode-slim@2.2.19`. It is installed from its upstream project and is
not copied into this repository. Its upstream license and its OpenAI/Anthropic
license rider remain in force.

## What is included

- The global `opencode.json` configuration.
- The global `cli.json` configuration, with portable relative plugin paths.
- The `oh-my-opencode-slim.json` configuration.
- The one-line global `AGENTS.md` instruction file.
- A safe installer that clones the four plugin repositories and creates the
  expected plugin links.
- Tests and documentation for each local plugin.

The Slim-managed skills are intentionally not copied. The package installs and
updates these skills: `clonedeps`, `codemap`, `deepwork`,
`verification-planning`, `reflect`, `simplify`, `worktrees`, and
`oh-my-opencode-slim`.

## What is not included

The following files are machine state and must stay private:

- OpenCode service credentials and registration state.
- OpenCode session database, WAL files, logs, caches, and generated manifests.
- Package caches and `node_modules`.
- Provider credentials, OAuth credentials, and the
  `TOOL_GATEWAY_TOKEN` value.
- The `dcg` executable and its local history database.
- The legacy `tui.json` file. The active V2 CLI settings are in `cli.json`.

The `.gitignore` prevents these classes of files from entering this repository.

## Setup

### Prerequisites

Install these tools first:

- OpenCode V2. The captured setup used `opencode2 v0.0.0-beta-19242`.
- Git.
- Node.js 22 or later for plugin tests.
- `dcg` 0.14.3 or a compatible release. Install it from the
  [Destructive Command Guard project](https://github.com/Dicklesworthstone/destructive_command_guard).
- Herdr 0.9.0 when Herdr reporting and child panes are wanted.
- `devx` on `PATH` if the current `commandPrefix: ["devx"]` behavior is wanted.
  Otherwise change that array to `[]` in `config/cli.json` before installing.

Authenticate the model providers used by the Slim configuration with the
OpenCode authentication flow:

```sh
opencode2 auth
```

The current setup also needs `TOOL_GATEWAY_TOKEN` for the Shopify Tool Gateway
MCP server. Export it in the shell that starts OpenCode. Do not put the token
in a config file.

### Install

```sh
git clone https://github.com/SoloUnity/opencode-setup-guide.git
cd opencode-setup-guide
./install.sh
```

The installer:

1. Checks the required local commands.
2. Installs or verifies `oh-my-opencode-slim@2.2.19` with OpenCode's plugin
   manager.
3. Clones the four plugin repositories into the OpenCode data directory.
4. Creates links under `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/plugins`.
5. Backs up conflicting existing configuration and plugin entries.
6. Installs the tracked configuration files.

Start a new OpenCode process after installation. The shared background service
loads plugins at startup.

### Verify

```sh
opencode2 service status
opencode2 api get /api/health
opencode2 plugin list
```

Expected local plugins are `agent-order`, `dcg.guard`, `herdr.opencode`, and
`herdr.opencode.subagent-panes.server`. The package plugin should report
version `2.2.19`.

Run plugin tests from each plugin repository:

```sh
node --test test/*.test.js
```

The Herdr subagent-pane tests require Node.js 22 or later. Its live layout test
must run only inside a disposable Herdr pane:

```sh
node test/live-layout.mjs --disposable-pane
```

## Provider and MCP notes

The captured config contains the Shopify Tool Gateway MCP server and a disabled
Craft server. Tool Gateway uses an environment-substituted bearer token. Craft
is disabled, so no Craft page or credential is required.

Context7 and GitHub code search appeared in the running service but were not in
the captured global config. They are environment-provided integrations and are
not required by this repository.

The model names in `config/oh-my-opencode-slim.json` are the exact names from
the captured setup. A different OpenCode account or provider may need different
model IDs.

## License and provenance

The setup repository, the agent-order plugin, the DCG adapter, and the Herdr
subagent-pane plugin are licensed under MIT for the original code in those
repositories.

`herdr-opencode` contains modified source from Herdr commit
`c77af1892ff121736ecb103b32d504d6f1b31805`. That repository keeps the
Apache-2.0 license and identifies local modifications. The DCG executable is a
separate project with its own custom MIT license rider; this repository does
not redistribute it.
