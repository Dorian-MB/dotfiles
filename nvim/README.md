# Usage
This is a personal nvim config.


# Credit
- [ Neovim ](https://neovim.io/)
- [ NvChad distribution ](https://github.com/NvChad/NvChad.git)

# Installation

## Install Neovim

[ Install here ](https://github.com/neovim/neovim/blob/master/INSTALL.md)

**Neovim 0.12 or later is required** (the `main` branch of nvim-treesitter does
not work on 0.11). Check with `nvim --version` : distro packages are often too
old.

Exemple on Mac os :
```bash
brew install neovim
```

Exemple on Linux / WSL (no sudo, installs in `~/.local`) :
```bash
mkdir -p ~/.local/opt ~/.local/bin
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    | tar -xz -C ~/.local/opt
ln -sfn ~/.local/opt/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
```
`~/.local/bin` must come before `/usr/bin` in your `PATH`.

### Dependencies
```
External dependencies
├── Neovim >= 0.12
├── git
├── ripgrep
├── fd
├── rustup
├── uv
├── tree-sitter (the CLI, used to compile the parsers)
├── a C compiler (gcc or clang)
└── lazygit

Mason
├── pyright
├── ruff
├── lua-language-server
├── stylua
└── ...
```
Exemple:
```bash
brew install jesseduffield/lazygit/lazygit
brew install tree-sitter-cli
```

`tree-sitter` CLI on Linux / WSL :
```bash
curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz \
    | gunzip > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter
```
On WSL, do not use `npm install -g tree-sitter-cli` unless node is installed
inside WSL : the Windows `npm` installs the CLI on the Windows side, where
Neovim cannot see it. `which tree-sitter` must print a Linux path.

## Make a backup of your current Neovim files:
```bash
# required
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

## Or - Uninstall current Neovim config :
``` bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

Then open up neovim and let everything install.

### Install treesitter syntax
Restart Neovim and install the treesitter syntax <br>
Exemple :
```
:TSInstall python rust
```
The parsers listed in `lua/plugins/treesitter.lua` are installed automatically
at startup. To highlight a new language, add it to both lists in that file
(the `install` list and the `FileType` pattern).

### Troubleshooting : no syntax highlighting (plain colors)
The regex `syntax` plugin is disabled in `lua/configs/lazy.lua`, so highlighting
relies only on treesitter : a missing parser means no colors at all.

1. `nvim --version` : must be 0.12 or later.
2. `which tree-sitter` and `which gcc` : both must exist (Linux paths on WSL).
3. `ls ~/.local/share/nvim/site/parser/` : must contain `<lang>.so`. If it is
   empty, run `:TSUpdate` and read the error with `:messages`.
4. `:checkhealth nvim-treesitter` for the full report.

## Some Mapping :

- `<leader>` = space

**[x]**
- `p` - dont copy replaced text
- `<leader>p` - does

**[v]**
- `J`&`K` - move down/up the selected line

**[n, v]**
- `<leader>R` - find and replace current word
- `<leader>rr` - find and replace current word from the current position

**[n]**
- `<leader>G` - goto tabnew
- `<leader>u` - Undo tree
- `<leader>ds` - telescope document_symbols
- `<leader>ws` - telescope workspace_symbols
- `<leader>lg` - LazyGit
- `<leader>T` - switch with previous buffer
- `<leader>hh` - harpoon menu
- `<leader>ha` - harpoon add file
- `<leader>hx` - harpoon remove file
- `<leader>1..4` - harpoon go to file 1..4

## Notebooks (.ipynb)

Ouvrir un `.ipynb` affiche un vrai notebook (cellules, sorties, images) grace
au plugin local [`jupynb.nvim`](jupynb.nvim/README.md).

Dependances python (deja installees dans `~/.venvs/nvim`) :
```bash
pip install jupyter_client ipykernel matplotlib pandas
```
Les images passent par le protocole graphique kitty (Ghostty le supporte) et
ont besoin d'ImageMagick : `brew install imagemagick`.

`:checkhealth jupynb` verifie l'installation, `:Jupynb <Tab>` liste les
commandes.

**[n] dans un buffer notebook**
- `<C-CR>` - executer la cellule
- `<S-CR>` - executer et aller a la cellule suivante
- `<M-CR>` - executer et inserer une cellule en dessous
- `]c` / `[c` - cellule suivante / precedente
- `<leader>jr` / `<leader>jR` - executer la cellule / tout le notebook
- `<leader>ja` / `<leader>jb` - inserer une cellule au dessus / en dessous
- `<leader>jd` - supprimer la cellule
- `<leader>jm` - basculer code <-> markdown
- `<leader>jc` / `<leader>jC` - effacer la sortie / toutes les sorties
- `<leader>jo` - ouvrir la sortie complete dans un split
- `<leader>jk` - choisir le kernel (les `.venv` du projet sont proposes)
- `<leader>jx` / `<leader>ji` - redemarrer / interrompre le kernel



