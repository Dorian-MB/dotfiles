#!/usr/bin/env bash
# Install the dotfiles for this machine: macOS, WSL, or plain Linux (detected).
# Idempotent: re-run it after moving a directory or editing a file in the repo.
#   link  Mac/Linux side: a symlink. A stale or broken one is replaced; a real
#         file/dir at the target is left alone (warning).
#   copy  Windows side (from WSL): Windows apps can't follow WSL symlinks, so the
#         file is copied. A different file already there is kept as <file>.bak.
#   ./install.sh            install everything for this OS
#   ./install.sh nvim zsh   only entries whose source starts with these paths
#   WINHOME=/mnt/c/Users/me ./install.sh   force the Windows home (WSL)

set -u
DOT="$(cd "$(dirname "$0")" && pwd)"

case "$(uname)" in
Darwin) OS=mac ;;
Linux) grep -qi microsoft /proc/version 2>/dev/null && OS=wsl || OS=linux ;;
*) echo "unsupported OS: $(uname)"; exit 1 ;;
esac

# mode  source (relative to the repo)  target
ENTRIES=(
  "link nvim                     $HOME/.config/nvim"
  "link herdr                    $HOME/.config/herdr"
  "link starship/starship.toml   $HOME/.config/starship.toml"
  "link zsh/.zshrc               $HOME/.zshrc"
  "link zsh/.zshrc_alias         $HOME/.zshrc_alias"
  "link zsh/.zshenv              $HOME/.zshenv"
  "link zsh/.zprofile            $HOME/.zprofile"
  "link agents/keybindings.json  $HOME/.claude/keybindings.json"
)

if [ $OS = mac ]; then
  ENTRIES+=(
    "link macos/aerospace          $HOME/.config/aerospace"
    "link macos/sketchybar         $HOME/.config/sketchybar"
    "link macos/wezterm            $HOME/.config/wezterm"
    "link macos/ghostty            $HOME/.config/ghostty"
  )
fi

if [ $OS = wsl ]; then
  if [ -z "${WINHOME:-}" ]; then
    # full path: the Windows PATH may not be appended (wsl.conf appendWindowsPath).
    # cd /mnt/c: cmd.exe refuses a \\wsl.localhost working directory
    win=$(cd /mnt/c && /mnt/c/Windows/System32/cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
    [ -n "$win" ] && WINHOME=$(wslpath -u "$win")
  fi
  if [ -d "${WINHOME:-}" ]; then
    ENTRIES+=(
      "copy windows/glaze/config.yaml      $WINHOME/.glzr/glazewm/config.yaml"
      "copy windows/yasb/config.yaml       $WINHOME/.config/yasb/config.yaml"
      "copy windows/yasb/styles.css        $WINHOME/.config/yasb/styles.css"
      "copy windows/yasb/yasb_colors.css   $WINHOME/.config/yasb/yasb_colors.css"
      "copy windows/wezterm/.wezterm.lua   $WINHOME/.wezterm.lua"
      "copy windows/wsl/.wslconfig         $WINHOME/.wslconfig"
      "copy windows/wsl/wsl.conf           /etc/wsl.conf"
    )
  else
    echo "SKIP     Windows files: Windows home not found (set WINHOME=/mnt/c/Users/<you>)"
  fi
fi

# run "$@" with sudo only when the target's directory isn't writable (/etc/wsl.conf)
as_needed() {
  if [ -w "$(dirname "$dst")" ]; then "$@"; else sudo "$@"; fi
}

do_link() {
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$DOT/$src" ]; then
    echo "ok       $dst"; return
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "SKIP     $dst exists and is not a symlink (move it away first)"; status=1; return
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$DOT/$src" "$dst" && echo "linked   $dst -> $DOT/$src"
}

do_copy() {
  if cmp -s "$DOT/$src" "$dst"; then
    echo "ok       $dst"; return
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    as_needed mv "$dst" "$dst.bak" && echo "backup   $dst.bak"
  fi
  # cp copies bytes as-is: the CRLF files stay CRLF
  as_needed cp "$DOT/$src" "$dst" && echo "copied   $dst" || status=1
}

status=0
echo "OS: $OS"
for entry in "${ENTRIES[@]}"; do
  read -r mode src dst <<<"$entry"
  if [ $# -gt 0 ]; then
    keep=0
    for f in "$@"; do [[ "$src" == "$f"* ]] && keep=1; done
    [ $keep = 1 ] || continue
  fi
  if [ ! -e "$DOT/$src" ]; then
    echo "missing  $src (not in repo)"; status=1; continue
  fi
  "do_$mode"
done
[ $OS = wsl ] && echo "note     .wslconfig / wsl.conf apply after \`wsl --shutdown\` (from Windows)"
exit $status
