# dotfiles

Terminal / window-manager config for macOS (+ a Windows corner).

Every folder has its own `README.md`: what the tool is, where it is linked, and its keybindings.

| Directory | Tool | Target |
|---|---|---|
| `nvim/` | Neovim (NvChad v2.5) | `~/.config/nvim` |
| `zsh/` | zsh | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `starship/` | starship prompt | `~/.config/starship.toml` |
| `herdr/` | herdr | `~/.config/herdr` |
| `macos/wezterm/` | WezTerm | `~/.config/wezterm` |
| `macos/ghostty/` | Ghostty | `~/.config/ghostty` |
| `macos/sketchybar/` | SketchyBar | `~/.config/sketchybar` |
| `macos/aerospace/` | AeroSpace | `~/.config/aerospace` |
| `agents/keybindings.json` | Claude Code keybindings | `~/.claude/keybindings.json` |
| `agents/` (rest) | Claude Code plugins / mods, see [`agents/README.md`](agents/README.md) | not linked |
| `cli/` | list of installed CLI / TUI tools, see [`cli/README.md`](cli/README.md) | doc only |
| `windows/glaze/`, `windows/yasb/` | GlazeWM + YASB | `%USERPROFILE%\.config\` |
| `windows/wezterm/` | WezTerm (Windows) | `%USERPROFILE%\.wezterm.lua` |
| `windows/wsl/` | WSL | `%USERPROFILE%\.wslconfig`, `/etc/wsl.conf` |

## Install

```bash
git clone https://github.com/Dorian-MB/dotfiles.git ~/dotfiles
```

### Dependencies

```bash
brew install neovim git ripgrep fd fzf bat eza jq starship tree-sitter-cli uv rustup
brew install jesseduffield/lazygit/lazygit
brew install --cask wezterm ghostty
brew install nikitabobko/tap/aerospace FelixKratz/formulae/sketchybar FelixKratz/formulae/borders
brew services start borders
```

The nvim config needs **Neovim >= 0.12** and the `tree-sitter` CLI, otherwise
there is no syntax highlighting. On Linux / WSL (no Homebrew), see
[`nvim/README.md`](nvim/README.md) for the install commands and troubleshooting.

Fonts: `JetBrainsMono Nerd Font` (terminals + bar) and the bundled
`macos/sketchybar/helpers/sketchybar-app-font.ttf` (workspace app icons).

### Link what you want

`./install.sh` creates every link below, or only some (`./install.sh nvim zsh`).
It is safe to re-run after moving a directory: stale links are repaired, real
files are never overwritten. Or by hand:

```bash
ln -s ~/dotfiles/nvim              ~/.config/nvim
ln -s ~/dotfiles/macos/aerospace   ~/.config/aerospace
ln -s ~/dotfiles/macos/sketchybar  ~/.config/sketchybar
ln -s ~/dotfiles/macos/wezterm     ~/.config/wezterm
ln -s ~/dotfiles/macos/ghostty     ~/.config/ghostty
ln -s ~/dotfiles/herdr             ~/.config/herdr
ln -s ~/dotfiles/starship/starship.toml ~/.config/starship.toml

ln -s ~/dotfiles/zsh/.zshrc    ~/.zshrc
ln -s ~/dotfiles/zsh/.zshenv   ~/.zshenv
ln -s ~/dotfiles/zsh/.zprofile ~/.zprofile

ln -s ~/dotfiles/agents/keybindings.json ~/.claude/keybindings.json
```

The three zsh files go together: `.zprofile` sets up Homebrew, `.zshenv` sets up
uv/cargo, and `.zshrc` depends on both (it calls `brew --prefix`).

Or just copy paste what you want.

### Secrets

`.zshrc` sources `~/.zshrc_secret` if it exists. That file lives **outside** this
repo on purpose — a secret sitting inside a public checkout is one `git add -f`
away from being published:

```bash
mkdir -p ~/.config/secrets && chmod 700 ~/.config/secrets
touch ~/.config/secrets/zshrc_secret && chmod 600 ~/.config/secrets/zshrc_secret
ln -s ~/.config/secrets/zshrc_secret ~/.zshrc_secret
```

