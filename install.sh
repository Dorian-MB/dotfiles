#!/usr/bin/env bash
# Create (or repair) the symlinks from README "Link what you want".
# Idempotent: re-run it after moving a directory in the repo. A stale or broken
# symlink is replaced; a real file/dir at the target is left alone (warning).
#   ./install.sh            link everything
#   ./install.sh nvim zsh   only entries whose source starts with these paths

set -u
DOT="$(cd "$(dirname "$0")" && pwd)"

# source (relative to the repo)  ->  target
LINKS=(
  "nvim                     $HOME/.config/nvim"
  "macos/aerospace          $HOME/.config/aerospace"
  "macos/sketchybar         $HOME/.config/sketchybar"
  "macos/wezterm            $HOME/.config/wezterm"
  "macos/ghostty            $HOME/.config/ghostty"
  "herdr                    $HOME/.config/herdr"
  "starship/starship.toml   $HOME/.config/starship.toml"
  "zsh/.zshrc               $HOME/.zshrc"
  "zsh/.zshenv              $HOME/.zshenv"
  "zsh/.zprofile            $HOME/.zprofile"
  "agents/keybindings.json  $HOME/.claude/keybindings.json"
)

status=0
for entry in "${LINKS[@]}"; do
  read -r src dst <<<"$entry"
  if [ $# -gt 0 ]; then
    keep=0
    for f in "$@"; do [[ "$src" == "$f"* ]] && keep=1; done
    [ $keep = 1 ] || continue
  fi
  if [ ! -e "$DOT/$src" ]; then
    echo "missing  $src (not in repo)"; status=1; continue
  fi
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$DOT/$src" ]; then
    echo "ok       $dst"; continue
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "SKIP     $dst exists and is not a symlink (move it away first)"; status=1; continue
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$DOT/$src" "$dst" && echo "linked   $dst -> $DOT/$src"
done
exit $status
