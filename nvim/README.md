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

## Mappings

- `<leader>` = `space`
- Modes : **n** normal, **i** insert, **v** visual, **x** visual (sans select), **o** operateur, **t** terminal
- *(NvChad)* = mapping par defaut de NvChad, garde tel quel
- `<leader>wK` liste tous les mappings actifs (which-key), `<leader>ch` ouvre le cheatsheet NvChad

### General
| Mode | Touche | Action |
|------|--------|--------|
| i | `jk` | sortir du mode insert (`<Esc>`) |
| n, i, v | `<C-s>` | sauvegarder |
| n | `<C-c>` | copier tout le fichier *(NvChad)* |
| n | `<Esc>` | effacer le surlignage de recherche *(NvChad)* |
| n | `<leader>n` / `<leader>rn` | toggle numeros / numeros relatifs *(NvChad)* |
| n | `<leader>u` | undotree |
| n, v | `<leader>/` | commenter la ligne / la selection *(NvChad)* |
| n, x | `<leader>fm` | formatter le fichier (conform, aussi fait a la sauvegarde) *(NvChad)* |
| n | `<leader>th` | choisir un theme *(NvChad)* |

### Deplacement
| Mode | Touche | Action |
|------|--------|--------|
| n | `<C-d>` / `<C-u>` | demi-page bas / haut, curseur recentre (`zz`) |
| n, x, o | `<leader>s` | flash : sauter vers un caractere (labels) |
| n, x, o | `<leader>S` | flash : selectionner un noeud treesitter |
| o | `r` | flash remote (ex : `yr` + label = yank a distance) |
| n, x, o | `f` `t` `F` `T` | flash : versions avec labels des sauts natifs |

### Edition
| Mode | Touche | Action |
|------|--------|--------|
| v | `J` / `K` | descendre / monter les lignes selectionnees (re-indentees) |
| x | `P` | coller sur la selection sans ecraser le presse-papier (natif nvim) |
| x | `p` | coller sur la selection, le texte remplace va dans le presse-papier (natif) |

### Surround (nvim-surround)
| Mode | Touche | Action |
|------|--------|--------|
| n | `ys<motion><c>` | entourer : `ysiw)` le mot, `ys$"` jusqu'a la fin de ligne |
| n | `yss<c>` | entourer la ligne |
| n | `cs<old><new>` | changer : `cs('` -> `(x)` devient `'x'` |
| n | `ds<c>` | supprimer : `ds"` -> `"x"` devient `x` |
| v | `S<c>` | entourer la selection |

`(` `{` `[` ajoutent un espace a l'interieur, `)` `}` `]` non. `t` = balise HTML
(`ysiwt` puis `div`).

### Mode insert (style readline / Ghostty `option-as-alt`)
| Mode | Touche | Action |
|------|--------|--------|
| i | `<M-b>` / `<M-f>` | mot precedent / fin du mot |
| i | `<M-BS>` / `<M-Del>` | supprimer jusqu'au debut / a la fin du mot |
| i | `<C-BS>` / `<C-Del>` | supprimer jusqu'au debut / a la fin de la ligne |
| i | `<C-b>` / `<C-e>` | debut / fin de ligne *(NvChad)* |
| i | `<C-h>` `<C-j>` `<C-k>` `<C-l>` | deplacer le curseur gauche / bas / haut / droite *(NvChad)* |

### Commandes `[` / `]`
| Mode | Touche | Action |
|------|--------|--------|
| n | `[c` / `]c` | cellule notebook precedente / suivante (jupynb, buffers `.ipynb`, remplace le `[c` diff natif) |
| n | `[d` / `]d` | diagnostic LSP precedent / suivant (natif nvim) |
| n | `[q` / `]q` | entree quickfix precedente / suivante, ex : apres `<C-q>` dans telescope (natif nvim) |
| n | `[b` / `]b` | buffer precedent / suivant (natif nvim, comme `<S-Tab>` / `<Tab>`) |

Liste complete des `[` / `]` natifs : [vim.md](vim.md).

### Rechercher / remplacer
| Mode | Touche | Action |
|------|--------|--------|
| n | `<leader>R` | remplacer le mot sous le curseur dans tout le fichier (confirmation) |
| n | `<leader>rr` | idem, de la ligne courante a la fin |
| n | `<leader>rf` | `:.,$s///gc` vide, de la ligne courante a la fin |
| v | `<leader>R` | remplacer la selection dans tout le fichier |
| v | `<leader>rr` | remplacer la selection de la ligne courante a la fin |

### Buffers, fenetres, onglets
| Mode | Touche | Action |
|------|--------|--------|
| n, i | `<C-Tab>` | revenir au fichier precedent (`:e #`) |
| n | `<leader>T` | revenir au fichier precedent (`:e #`) |
| n | `<Tab>` / `<S-Tab>` | buffer suivant / precedent *(NvChad)* |
| n | `<leader>b` | nouveau buffer *(NvChad)* |
| n | `<leader>x` | fermer le buffer *(NvChad)* |
| n | `<leader>G` | nouvel onglet (`:tabnew`) |
| n | `<C-h>` `<C-j>` `<C-k>` `<C-l>` | changer de fenetre *(NvChad)* |
| n | `<C-n>` / `<leader>e` | nvim-tree toggle / focus *(NvChad)* |

### Harpoon
| Mode | Touche | Action |
|------|--------|--------|
| n | `<leader>hh` | menu harpoon |
| n | `<leader>ha` | ajouter le fichier |
| n | `<leader>hx` | retirer le fichier |
| n | `<leader>1` .. `<leader>4` | aller au fichier 1..4 |

### Telescope
| Mode | Touche | Action |
|------|--------|--------|
| n | `<leader>ff` / `<leader>fa` | fichiers / tous les fichiers (caches, ignores) *(NvChad)* |
| n | `<leader>fg` | live grep |
| n | `<leader>fw` | grep du mot sous le curseur (NvChad : live grep) |
| n | `<leader>fz` | recherche floue dans le buffer *(NvChad)* |
| n | `<leader>fb` | buffers *(NvChad)* |
| n | `<leader>fo` | fichiers recents *(NvChad)* |
| n | `<leader>fh` | pages d'aide *(NvChad)* |
| n | `<leader>fc` | commandes |
| n | `<leader>fr` | reprendre la derniere recherche |
| n | `<leader>fd` | diagnostics |
| n | `<leader>fB` | liste des pickers telescope (builtin) |
| n | `<leader>ma` | marks *(NvChad)* |
| n | `<leader>ds` | symboles du document LSP (NvChad : diagnostics loclist) |
| n | `<leader>ws` | symboles du workspace LSP |
| n | `<leader>pt` | terminaux caches *(NvChad)* |

### LSP (buffers avec un serveur attache)
| Mode | Touche | Action |
|------|--------|--------|
| n | `gd` / `gD` | definition / declaration *(NvChad)* |
| n | `<leader>D` | definition du type *(NvChad)* |
| n | `<leader>ra` | renommer (NvRenamer) *(NvChad)* |
| n | `K` | documentation (natif nvim) |
| n | `grr` `gri` `gra` `grn` | references / implementation / code action / renommer (natif nvim) |
| n | `[d` / `]d` | diagnostic precedent / suivant (natif nvim) |
| n | `<leader>wa` `<leader>wr` `<leader>wl` | ajouter / retirer / lister les dossiers du workspace *(NvChad)* |

### Completion (blink.cmp)
| Mode | Touche | Action |
|------|--------|--------|
| i | `<CR>` | accepter |
| i | `<Tab>` / `<S-Tab>` | suggestion suivante / precedente, saut dans le snippet |
| i | `<C-space>` | ouvrir le menu / la doc |
| i | `<C-e>` | fermer le menu |

### Git
| Mode | Touche | Action |
|------|--------|--------|
| n | `<leader>lg` | LazyGit |
| n | `<leader>gb` | branches (telescope) |
| n | `<leader>gt` | git status (telescope) *(NvChad)* |
| n | `<leader>cm` | commits (telescope) *(NvChad)* |

### Terminal
| Mode | Touche | Action |
|------|--------|--------|
| n, i, t | `<A-i>` | terminal flottant |
| n, i, t | `<A-o>` | terminal horizontal (meme terminal que `<A-h>`) |
| n, t | `<A-h>` / `<A-v>` | terminal horizontal / vertical *(NvChad)* |
| t | `<C-x>` | sortir du mode terminal *(NvChad)* |

### Mappings supprimes
| Touche | Avant | Raison |
|--------|-------|--------|
| `<leader>h` | NvChad : nouveau terminal horizontal | libere pour harpoon (`<leader>h*`), `vim.keymap.del` dans `mappings.lua` |
| `<leader>v` | NvChad : nouveau terminal vertical | supprime (`<A-v>` reste) |
| `<leader>fb` (custom) | telescope builtin | deplace sur `<leader>fB`, `<leader>fb` redevient buffers |
| `p` (visual) | coller sans ecraser le presse-papier | inutile : `P` natif fait pareil |
| `<leader>p` (visual) | coller et copier le texte remplace | inutile : c'est le `p` natif |
| `<leader>gd` | gitsigns `diffthis HEAD` | supprime avec le plugin git diff |
| `<leader>cd` / `<leader>cu` / `<leader>M` | notebook-navigator : cellule suivante / precedente / executer | remplace par jupynb.nvim (voir plus bas) |
| `<C-a>` / `<C-b>` / `<C-:>` | notebook-navigator : cellule au dessus / en dessous / commenter | remplace par jupynb.nvim |
| `<C-e>` / `<C-a>` (insert) | minuet-ai : accepter la suggestion / la ligne | plugin desactive (`enabled = false`) |

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

**[n] dans un buffer notebook** (locaux au buffer)
| Mode | Touche | Action |
|------|--------|--------|
| n, i | `<C-CR>` | executer la cellule |
| n, i | `<S-CR>` | executer et aller a la cellule suivante |
| n, i | `<M-CR>` | executer et inserer une cellule en dessous |
| n | `]c` / `[c` | cellule suivante / precedente |
| n | `<leader>jr` / `<leader>jR` | executer la cellule / tout le notebook |
| n | `<leader>jA` / `<leader>jB` | executer toutes les cellules au dessus / en dessous |
| n | `<leader>ja` / `<leader>jb` | inserer une cellule au dessus / en dessous |
| n | `<leader>jd` | supprimer la cellule |
| n | `<leader>jm` | basculer code <-> markdown |
| n | `<leader>js` | couper la cellule au curseur |
| n | `<leader>jJ` | fusionner avec la cellule suivante |
| n | `<leader>j<` / `<leader>j>` | monter / descendre la cellule |
| n | `<leader>jc` / `<leader>jC` | effacer la sortie / toutes les sorties |
| n | `<leader>jo` | ouvrir la sortie complete dans un split (`q` pour fermer) |
| n | `<leader>jk` | choisir le kernel (les `.venv` du projet sont proposes) |
| n | `<leader>jK` | kernel depuis le chemin d'un env python |
| n | `<leader>jx` / `<leader>ji` | redemarrer / interrompre le kernel |
| n | `<leader>jF` | reparer la structure du notebook |
