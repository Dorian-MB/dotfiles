# CLI / TUI

Outils en ligne de commande et TUI installés sur ma machine.

## Shell

| Outil | Rôle |
|---|---|
| zsh + zsh-autosuggestions + zsh-syntax-highlighting | shell |
| starship | prompt |
| fzf | fuzzy finder |
| eza | `ls` moderne |
| bat | `cat` avec coloration |
| fd | `find` moderne |
| ripgrep | `grep` rapide |
| jq | JSON en ligne de commande |

## Éditeurs / TUI

| Outil | Rôle |
|---|---|
| neovim | éditeur |
| tmux (+ tpm, tmux2k) | multiplexeur de terminal |
| herdr | multiplexeur d'agents |
| lazygit | UI git |
| btop | moniteur système |
| taproom | UI Homebrew |
| glow | rendu Markdown |
| fastfetch | infos système |
| cmatrix | Matrix dans le terminal |
| claude | Claude Code |

## Dev

| Outil | Rôle |
|---|---|
| git | versionnage |
| uv | Python (paquets, venvs, outils) |
| graphify (via uv) | graphe de connaissances |
| node / npm | JavaScript |
| rustup / cargo, rustlings | Rust |
| tree-sitter (via cargo) | parsers pour nvim |
| typst | composition de documents |
| jk | CLI Jenkins |

## Images / médias

| Outil | Rôle |
|---|---|
| viu | images dans le terminal |
| ffmpeg | audio / vidéo |
| imagemagick | manipulation d'images |
| poppler | outils PDF |
| pngpaste | coller une image du presse-papier |

## Installation

```bash
brew install zsh-autosuggestions zsh-syntax-highlighting starship fzf eza bat fd ripgrep jq \
  neovim tmux herdr lazygit btop taproom glow fastfetch cmatrix \
  git uv node typst avivsinai/tap/jk viu ffmpeg imagemagick poppler pngpaste rustup
uv tool install graphifyy
cargo install tree-sitter-cli rustlings
```
