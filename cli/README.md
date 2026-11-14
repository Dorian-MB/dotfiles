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

### macOS

```bash
brew install zsh-autosuggestions zsh-syntax-highlighting starship fzf eza bat fd ripgrep jq \
  neovim tmux herdr lazygit btop taproom glow fastfetch cmatrix \
  git uv node typst avivsinai/tap/jk viu ffmpeg imagemagick poppler pngpaste rustup
uv tool install graphifyy
cargo install tree-sitter-cli rustlings
```

### Linux / WSL (Debian / Ubuntu)

```bash
sudo apt update
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting fzf eza bat fd-find ripgrep jq \
  tmux btop fastfetch cmatrix git nodejs npm ffmpeg imagemagick poppler-utils build-essential
# Debian renomme bat et fd
mkdir -p ~/.local/bin
ln -sf "$(command -v batcat)" ~/.local/bin/bat
ln -sf "$(command -v fdfind)" ~/.local/bin/fd

curl -sS https://starship.rs/install.sh | sh
curl -LsSf https://astral.sh/uv/install.sh | sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

uv tool install graphifyy
cargo install tree-sitter-cli rustlings viu typst-cli
```

- **neovim** : voir [`nvim/README.md`](../nvim/README.md) (la version apt est trop vieille, il faut >= 0.12).
- **lazygit**, **glow** : prends le binaire dans leurs releases GitHub (`apt` ne les a que sur les Ubuntu récents).
- **eza**, **fastfetch** : seulement dans `apt` à partir d'Ubuntu 24.04 / Debian 13, sinon `cargo install eza`.
- **herdr**, **taproom**, **jk** : pas de paquet `apt` ; installe [Homebrew sur Linux](https://docs.brew.sh/Homebrew-on-Linux) et utilise la commande macOS.
- **pngpaste** : macOS uniquement (sous Linux : `xclip -selection clipboard -t image/png -o > img.png`).
