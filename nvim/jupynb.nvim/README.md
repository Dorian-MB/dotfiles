# jupynb.nvim

Des notebooks Jupyter (`.ipynb`) dans Neovim, avec de **vraies cellules** :
barre d'en-tête par cellule, barre latérale de cellule active, sorties
affichées sous la cellule (texte, erreurs colorées, images), exécution par un
vrai kernel Jupyter, et sauvegarde directe au format `.ipynb`.

Tout est dérivé du thème courant (base46/NvChad, ou n'importe quel
colorscheme) : aucune couleur n'est codée en dur.

```
   Python  [3]                                        ✓ 0.4s
 ▊ import numpy as np
 ▊ import matplotlib.pyplot as plt
 ▊
 ▊ plt.plot(x, np.sin(x))

   ▏ [<matplotlib.lines.Line2D at 0x…>]
   ▏ ███████████  (figure inline, protocole kitty)

   Markdown
 ▏ # Analyse
 ▏ Le texte markdown est rendu normalement.
```

## Comment ça marche

Le fichier sur le disque reste un `.ipynb` standard. À l'ouverture, le
notebook est transformé en un buffer « markdown » :

| Cellule   | Texte du buffer                                  | Affichage                    |
| --------- | ------------------------------------------------ | ---------------------------- |
| code      | ` ``````python nb ` … ` `````` `                 | barre d'en-tête + code       |
| markdown  | `<!--nb-->` puis le markdown brut                | barre d'en-tête + markdown   |
| raw       | `<!--nb:raw-->` puis le texte                    | barre d'en-tête + texte      |

Conséquences utiles :

- **Coloration syntaxique native** : treesitter injecte le parser Python dans
  les blocs de code, et le markdown des cellules markdown est rendu comme du
  markdown (compatible `render-markdown.nvim`).
- **Édition normale** : c'est un buffer Neovim ordinaire, tous les mouvements,
  macros, `undo`, télescope, etc. fonctionnent.
- **Aucune perte** : les métadonnées, `execution_count`, ids de cellules et
  sorties (y compris les images, ré-encodées en base64) sont réécrits dans le
  `.ipynb` à la sauvegarde, avec le même formatage que Jupyter (indentation 1,
  clés triées) pour garder des diffs git propres.

Les lignes de marqueurs (` `````` `, `<!--nb-->`) sont recouvertes par la barre
d'en-tête ; la ligne de fermeture est affichée comme une ligne vide qui sépare
les cellules.

## Exécution

Un pont Python (`python/jupynb_bridge.py`) parle à un kernel Jupyter via
`jupyter_client`. Il ne faut **pas** `pynvim` : la communication se fait en
JSON par ligne sur stdin/stdout.

- un kernel par notebook, démarré à la première exécution ;
- `stdout`/`stderr` en direct, résultats, `display_data`, `clear_output` ;
- erreurs avec traceback coloré (les séquences ANSI d'IPython sont converties
  en highlights) ;
- `input()` est relayé vers `vim.ui.input` ;
- les figures sont écrites sur disque puis affichées par `image.nvim`
  (protocole graphique kitty — supporté par Ghostty, kitty, WezTerm).

## Commandes

`:Jupynb <sous-commande>` (complétion sur `<Tab>`) :

| Sous-commande                      | Effet                                     |
| ---------------------------------- | ----------------------------------------- |
| `run`, `run-advance`               | exécute la cellule courante               |
| `runall`, `runabove`, `runbelow`   | exécute un ensemble de cellules           |
| `insert above\|below [type]`       | insère une cellule                        |
| `delete`, `split`, `merge`         | édition de la structure                   |
| `move up\|down`                    | déplace la cellule                        |
| `type code\|markdown\|raw`         | change le type de la cellule              |
| `next`, `prev`                     | navigation entre cellules                 |
| `clear`, `clearall`                | efface les sorties                        |
| `output`                           | ouvre la sortie complète dans un split    |
| `kernel`, `restart`, `interrupt`, `shutdown` | gestion du kernel               |
| `status`                           | résumé du notebook et du kernel           |
| `images`                           | bascule l'affichage des images            |
| `fix`                              | répare/normalise la structure du buffer   |

## Raccourcis (buffer local)

| Touche        | Action                                   |
| ------------- | ---------------------------------------- |
| `<C-CR>`      | exécuter la cellule                      |
| `<S-CR>`      | exécuter puis aller à la suivante         |
| `<M-CR>`      | exécuter puis insérer une cellule dessous |
| `]c` / `[c`   | cellule suivante / précédente            |

Et sous le préfixe (`<leader>j` par défaut) :

| Touche | Action                    | Touche | Action                     |
| ------ | ------------------------- | ------ | -------------------------- |
| `r`    | exécuter                  | `a`    | insérer une cellule au-dessus |
| `R`    | exécuter tout             | `b`    | insérer une cellule en dessous |
| `A`    | exécuter au-dessus        | `d`    | supprimer la cellule       |
| `B`    | exécuter en dessous       | `m`    | code ⇄ markdown            |
| `c`    | effacer la sortie         | `s`    | couper la cellule au curseur |
| `C`    | effacer toutes les sorties| `J`    | fusionner avec la suivante |
| `o`    | sortie complète           | `<` `>`| déplacer la cellule        |
| `k`    | choisir le kernel         | `x`    | redémarrer le kernel       |
| `i`    | interrompre               | `F`    | réparer la structure       |

## Installation (lazy.nvim)

```lua
{
  "jupynb.nvim",
  dir = vim.fn.stdpath "config" .. "/jupynb.nvim",
  lazy = false,
  dependencies = {
    "3rd/image.nvim",                              -- images (optionnel)
    "jmbuhr/otter.nvim",                           -- LSP dans les cellules (optionnel)
    "MeanderingProgrammer/render-markdown.nvim",   -- rendu markdown (optionnel)
  },
  opts = {},
}
```

Côté Python (un seul environnement suffit, celui de `vim.g.python3_host_prog`) :

```bash
pip install jupyter_client ipykernel
```

`:checkhealth jupynb` vérifie tout (python, kernels, parsers treesitter,
ImageMagick, terminal compatible).

## Options

```lua
require("jupynb").setup {
  python = nil,          -- interpréteur du pont (défaut : vim.g.python3_host_prog)
  kernel = {
    auto_start = true,
    name = nil,          -- force un kernelspec
    timeout = 60,
    startup = { python = "%matplotlib inline" },
    discover_venvs = true, -- propose .venv/bin/python dans le sélecteur
  },
  ui = {
    header = true,        -- barre d'en-tête de cellule
    gap = false,          -- ligne virtuelle vide au-dessus de chaque cellule
    statuscolumn = true,  -- barre latérale de cellule (style VSCode)
    active_bg = true,     -- fond léger sur la cellule courante
    wrap = true,          -- retour à la ligne dans les notebooks
    reveal_output = true, -- fait défiler la sortie dans le champ de vision
    max_output_lines = 24,
    max_output_width = 800,
    icons = { ... },
  },
  images = { enabled = true, max_height = 24, max_width = 120 },
  lsp = { otter = true },
  save = { strip_outputs = false },
  keymaps = { enabled = true, prefix = "<leader>j" },
  highlights = {},       -- surcharge n'importe quel groupe JupynbXxx
}
```

### Groupes de highlight

`JupynbHeader`, `JupynbHeaderActive`, `JupynbHeaderIcon`, `JupynbHeaderLabel`,
`JupynbHeaderCount`, `JupynbHeaderOk`, `JupynbHeaderError`,
`JupynbHeaderRunning`, `JupynbBar`, `JupynbBarActive`, `JupynbBarMd`,
`JupynbBarMdActive`, `JupynbCellActive`, `JupynbOutBorder`, `JupynbOutText`,
`JupynbOutStderr`, `JupynbOutErrName`, `JupynbOutErrText`, `JupynbAnsi*`.

Ils sont recalculés à chaque `ColorScheme`.

## Statusline

```lua
require("jupynb").status()  -- "  Python 3 (ipykernel)"
```

## Affichage des figures

Un terminal ne peut dessiner une image que là où l'écran est réellement
affiché : tant que les lignes virtuelles d'une sortie restent sous le bas de
la fenêtre, aucune figure n'apparaît. Après une exécution, jupynb fait donc
défiler juste ce qu'il faut pour amener la sortie dans le champ de vision
(sans bouger le curseur), puis redemande le rendu des images une fois l'écran
remis en page. `ui.reveal_output = false` désactive ce défilement — dans ce
cas il faut scroller soi-même pour voir les figures.

### Multiplexeurs (tmux, herdr, …)

Les séquences graphiques traversent Neovim → multiplexeur → terminal. Un
multiplexeur qui ne les relaie pas les avale, et aucune figure n'apparaît :

| Multiplexeur | À configurer                                                                 |
| ------------ | ---------------------------------------------------------------------------- |
| tmux         | `set -g allow-passthrough on` dans `tmux.conf`, puis redémarrer le serveur    |
| herdr        | `kitty_graphics = true` sous `[experimental]` dans `~/.config/herdr/config.toml`, puis `herdr server reload-config` |

jupynb détecte ces deux cas : il affiche alors le placeholder texte au lieu de
réserver des lignes vides, et dit une fois par session ce qu'il faut changer.
`:checkhealth jupynb` le rappelle aussi.

## Limites connues

- Le rendu HTML (tableaux pandas) retombe sur `text/plain` : un terminal ne
  sait pas afficher du HTML.
- Les images nécessitent un terminal compatible kitty graphics + ImageMagick.
- Éditer une ligne de marqueur peut casser la structure : `:Jupynb fix` la
  reconstruit à partir du modèle.
