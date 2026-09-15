# Configuration files

These files are copied to the global OpenCode directory:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/opencode/
```

The plugin paths in `opencode.json` and `cli.json` are relative to that
directory. The installer creates the matching links in `plugins/`.

`tui.json` is retained because it is part of the captured Slim installation;
the terminal-only settings remain in `cli.json`.

The Slim plugin path points to a local checkout of the upstream
`v2.2.19` tag. This avoids depending on a package registry retaining that
exact release while keeping the upstream source and license outside this
repository.

Do not copy service state, OAuth credentials, logs, caches, session databases,
or generated Slim manifests. OpenCode creates those files locally.
