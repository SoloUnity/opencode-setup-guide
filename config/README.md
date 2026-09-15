# Configuration files

These files are copied to the global OpenCode directory:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/opencode/
```

The plugin paths in `opencode.json` and `cli.json` are relative to that
directory. The installer creates the matching links in `plugins/`.

Do not copy service state, OAuth credentials, logs, caches, session databases,
or generated Slim manifests. OpenCode creates those files locally.
