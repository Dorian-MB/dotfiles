# dotfiles

Terminal / window-manager config for macOS (+ a Windows corner).

| Directory | Tool | Target |
|---|---|---|
| `nvim/` | Neovim (NvChad v2.5) | `~/.config/nvim` |
| `zsh/` | zsh | `~/.zshrc`, `~/.zshenv`, `~/.zprofile` |
| `starship/` | starship prompt | `~/.config/starship.toml` |
| `wezterm/` | WezTerm | `~/.config/wezterm` |
| `ghostty/` | Ghostty | `~/.config/ghostty` |
| `sketchybar/` | SketchyBar | `~/.config/sketchybar` |
| `aerospace/` | AeroSpace | `~/.config/aerospace` |
| `herdr/` | herdr | `~/.config/herdr` |
| `windows/` | GlazeWM + YASB | `%USERPROFILE%\.config\` |

## Install

```bash
git clone https://github.com/Dorian-MB/dotfiles.git ~/dotfiles
```

### Dependencies

```bash
brew install neovim git ripgrep fd fzf bat eza jq starship tree-sitter uv rustup
brew install jesseduffield/lazygit/lazygit
brew install --cask wezterm ghostty
brew install nikitabobko/tap/aerospace FelixKratz/formulae/sketchybar FelixKratz/formulae/borders
brew services start borders
```

Fonts: `JetBrainsMono Nerd Font` (terminals + bar) and the bundled
`sketchybar/helpers/sketchybar-app-font.ttf` (workspace app icons).

### Link what you want

```bash
ln -s ~/dotfiles/nvim        ~/.config/nvim
ln -s ~/dotfiles/aerospace   ~/.config/aerospace
ln -s ~/dotfiles/sketchybar  ~/.config/sketchybar
ln -s ~/dotfiles/wezterm     ~/.config/wezterm
ln -s ~/dotfiles/ghostty     ~/.config/ghostty
ln -s ~/dotfiles/herdr       ~/.config/herdr
ln -s ~/dotfiles/starship/starship.toml ~/.config/starship.toml

ln -s ~/dotfiles/zsh/.zshrc    ~/.zshrc
ln -s ~/dotfiles/zsh/.zshenv   ~/.zshenv
ln -s ~/dotfiles/zsh/.zprofile ~/.zprofile
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

