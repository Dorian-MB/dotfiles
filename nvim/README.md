# Usage
This is a personal nvim config.


# Credit
- [ Neovim ](https://neovim.io/)
- [ NvChad distribution ](https://github.com/NvChad/NvChad.git)

# Installation

## Install Neovim

[ Install here ](https://github.com/neovim/neovim/blob/master/INSTALL.md)

Exemple on Mac os :
```bash
brew install neovim
```

### Dependencies
```
External dependencies
├── Neovim
├── git
├── ripgrep
├── fd
├── rustup
├── uv
├── tree-sitter
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
```

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



