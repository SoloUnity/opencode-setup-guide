#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
readonly DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode-setup/plugins"
readonly BACKUP_DIR="$CONFIG_DIR/backups/setup-$(date +%Y%m%d-%H%M%S)"
readonly GITHUB_OWNER="${OPENCODE_SETUP_GITHUB_OWNER:-SoloUnity}"
readonly OMO_PACKAGE="oh-my-opencode-slim@2.2.19"

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

need_command() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

backup_if_needed() {
  local target="$1"
  [ -e "$target" ] || [ -L "$target" ] || return 0
  mkdir -p "$BACKUP_DIR"
  mv -- "$target" "$BACKUP_DIR/$(basename "$target")"
}

clone_or_update() {
  local target="$1"
  local repository="$2"
  if [ -d "$target/.git" ]; then
    git -C "$target" fetch --quiet --prune origin
    git -C "$target" pull --ff-only --quiet
  elif [ -e "$target" ]; then
    die "plugin store path exists but is not a Git checkout: $target"
  else
    git clone --quiet "https://github.com/$GITHUB_OWNER/$repository.git" "$target"
  fi
}

link_plugin() {
  local target="$1"
  local source="$2"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return 0
  fi
  backup_if_needed "$target"
  ln -s "$source" "$target"
}

need_command opencode2
need_command git
need_command node
if ! command -v dcg >/dev/null 2>&1; then
  need_command curl
  curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/main/install.sh?$(date +%s)" \
    | bash -s -- --easy-mode
fi
need_command dcg

node -e 'const major = Number(process.versions.node.split(".")[0]); if (major < 22) process.exit(1)' \
  || die "Node.js 22 or later is required"

mkdir -p "$CONFIG_DIR/plugins" "$DATA_DIR"

if ! opencode2 plugin list 2>/dev/null | grep -q 'oh-my-opencode-slim.*2\.2\.19'; then
  opencode2 plugin add "$OMO_PACKAGE"
fi

clone_or_update "$DATA_DIR/opencode-agent-order" opencode-agent-order
clone_or_update "$DATA_DIR/opencode-dcg-guard" opencode-dcg-guard
clone_or_update "$DATA_DIR/herdr-opencode" herdr-opencode
clone_or_update "$DATA_DIR/herdr-subagent-panes" herdr-subagent-panes

link_plugin "$CONFIG_DIR/plugins/agent-order" "$DATA_DIR/opencode-agent-order"
link_plugin "$CONFIG_DIR/plugins/herdr-opencode" "$DATA_DIR/herdr-opencode"
link_plugin "$CONFIG_DIR/plugins/herdr-subagent-panes" "$DATA_DIR/herdr-subagent-panes"
link_plugin "$CONFIG_DIR/plugins/dcg-guard.js" "$DATA_DIR/opencode-dcg-guard/dcg-guard.js"

for file in opencode.json cli.json oh-my-opencode-slim.json AGENTS.md; do
  target="$CONFIG_DIR/$file"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if cmp -s "$SCRIPT_DIR/config/$file" "$target"; then
      continue
    fi
    backup_if_needed "$target"
  fi
  cp "$SCRIPT_DIR/config/$file" "$target"
done

printf 'OpenCode setup installed in %s\n' "$CONFIG_DIR"
if [ -d "$BACKUP_DIR" ]; then
  printf 'Existing files were backed up in %s\n' "$BACKUP_DIR"
fi
printf 'Start a new OpenCode process to load the plugins.\n'
