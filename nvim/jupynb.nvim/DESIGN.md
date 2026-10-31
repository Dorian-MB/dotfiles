# jupynb.nvim — ce qui a été fait, et pourquoi

Notes de conception du plugin : les choix structurants, les alternatives
écartées, les pièges rencontrés et la façon dont tout a été vérifié.
Le mode d'emploi est dans [README.md](README.md).

---

## 1. Le point de départ

La demande : éditer des `.ipynb` dans Neovim avec de vraies cellules visibles,
façon VSCode, et une interface qui suit le thème existant (NvChad + catppuccin,
transparence activée, Ghostty comme terminal).

L'écosystème existant (celui qui était commenté dans `notebook.lua`) :

| Brique | Ce qu'elle fait | Pourquoi elle n'a pas été retenue telle quelle |
| --- | --- | --- |
| `jupytext.nvim` | convertit `.ipynb` ⇄ `py:percent` | **perd les sorties** à la sauvegarde ; cellules markdown transformées en commentaires |
| `molten-nvim` | exécution + sorties | impose son propre affichage (fenêtres flottantes), dépend de `pynvim` + `:UpdateRemotePlugins` |
| `NotebookNavigator` | navigation entre cellules `# %%` | ne résout ni le rendu ni la sauvegarde |

Aucune ne donnait la main sur ce qui faisait justement l'intérêt de la demande :
l'apparence des cellules et la fidélité du fichier `.ipynb`. D'où le choix
d'écrire un plugin dédié (~2 000 lignes Lua + un pont Python), en réutilisant
les briques là où elles sont bonnes : `image.nvim` pour les images,
`otter.nvim` pour le LSP, `render-markdown.nvim` pour les cellules markdown.

---

## 2. Le choix central : à quoi ressemble le buffer

C'est la décision dont tout le reste découle. Le fichier sur le disque reste du
JSON `.ipynb` ; ce qu'on édite est une **vue markdown** générée à l'ouverture :

```
``````python nb          ← cellule de code (fence de 6 backticks + sentinelle "nb")
import numpy as np
``````                   ← fence de fermeture

<!--nb-->                ← cellule markdown
# Titre
```

### Pourquoi du markdown plutôt que du `py:percent`

Un buffer `filetype=python` (approche jupytext) oblige à commenter le contenu
des cellules markdown (`# # Titre`), ce qui est laid et casse le rendu. Avec un
buffer markdown :

- **treesitter injecte le parser Python** dans les blocs de code (vérifié :
  captures `keyword.import`, `keyword.function` à l'intérieur des cellules) ;
- les cellules markdown sont du markdown de premier niveau, donc coloré
  nativement et compatible avec `render-markdown.nvim` (titres, puces, tables) ;
- le reste (mouvements, macros, undo, telescope) fonctionne sans rien de spécial.

Le prix à payer : l'indentation Python n'est plus automatique. C'est réglé par
un `indentexpr` maison qui délègue à `GetPythonIndent()` quand le curseur est
dans une cellule de code.

Le filetype est `jupynb` (pas `markdown`) pour ne pas hériter des autocommandes
markdown de la config (formatage à la sauvegarde, notamment) ; le parser est
enregistré explicitement via `vim.treesitter.language.register("markdown", "jupynb")`.

### Pourquoi 6 backticks et une sentinelle `nb`

Une cellule de code peut contenir ` ``` ` (docstring, doc markdown), et une
cellule markdown peut contenir un bloc ```` ```python ````. Deux garde-fous :

- la fence d'une cellule fait `max(6, plus longue suite de backticks + 1)`
  caractères — donc un ` ``` ` interne ne ferme jamais la cellule ;
- l'info string se termine par `nb` : un bloc fencé écrit par l'utilisateur
  dans une cellule markdown n'est jamais confondu avec une cellule. Treesitter
  continue d'injecter Python parce que le *premier* mot de l'info string reste
  le langage.

Ces marqueurs ne sont jamais visibles : la ligne d'ouverture est recouverte par
la barre d'en-tête, la ligne de fermeture est recouverte par des espaces et sert
d'espace inter-cellules.

### Alternatives écartées

- **`conceal_lines`** (Neovim 0.11+) pour masquer complètement les marqueurs :
  la ligne existe toujours pour `j`/`k` (curseur qui « saute »), et surtout les
  `virt_lines` d'une ligne masquée ne s'affichent plus — or c'est exactement là
  que sont accrochées les sorties.
- **Pas de marqueurs du tout** (frontières déduites par extmarks seuls) :
  impossible à réparer après une édition destructrice. Les marqueurs rendent la
  structure reconstructible, d'où `:Jupynb fix`.

---

## 3. Identité des cellules : le piège des extmarks

Les sorties, le compteur d'exécution et le statut vivent **à côté** du texte,
dans un modèle Lua. Pour les garder attachés à la bonne cellule pendant que
l'utilisateur édite, chaque cellule est ancrée par un extmark posé sur sa ligne
d'en-tête ; à chaque `sync()`, la structure relue est réconciliée avec ces
ancres.

Deux comportements d'extmarks ont demandé un traitement explicite :

1. **Gravité.** Avec `right_gravity = false`, insérer une cellule *au-dessus*
   d'une autre laissait l'ancre de l'ancienne sur place : la nouvelle cellule
   héritait de l'identité (et des sorties) de sa voisine. Avec
   `right_gravity = true`, c'est corrigé — mais une ancre placée au début d'une
   plage *remplacée* saute à la fin du remplacement, ce qui cassait le
   changement de type, le split et le merge.

   → Les opérations qui réécrivent une cellule re-plantent l'ancre elles-mêmes
   (`Doc:pin`), juste avant la resynchronisation.

2. **Collision.** En supprimant une cellule, son ancre et celle de la suivante
   se retrouvent sur la même ligne ; la mauvaise gagnait. → `Doc:unpin` retire
   l'ancre de ce qui va disparaître (suppression, fusion) avant l'édition.

C'est ce qui permet de déplacer, couper, fusionner une cellule sans jamais
perdre sa figure ou son `[3]`. Une suite de tests dédiée le verrouille.

---

## 4. Exécution : un pont Python, pas `pynvim`

`python/jupynb_bridge.py` parle à un kernel Jupyter via `jupyter_client` et
communique avec Neovim en **JSON par ligne sur stdin/stdout** (`vim.system`).

Pourquoi pas le mécanisme `rplugin`/`pynvim` (celui de molten) :

- pas de `:UpdateRemotePlugins` à relancer, pas de `pynvim` obligatoire ;
- le processus est cloisonné : il ne peut pas bloquer l'interface ;
- l'interpréteur du pont est indépendant du kernel — le pont peut tourner dans
  `~/.venvs/nvim` et piloter un kernel d'un `.venv` de projet.

Points de conception notables :

- **Un kernel par notebook**, démarré à la première exécution, `cwd` = dossier
  du notebook.
- **`%matplotlib inline` au démarrage** (configurable). Vérifié expérimentalement :
  sans ce magic, `plt.show()` bascule sur le backend macOS et **bloque le kernel**
  (la cellule reste en cours indéfiniment).
- **Les images ne transitent pas par le canal.** Le pont décode le base64,
  écrit un PNG dans un dossier temporaire et n'envoie que le chemin (+ dimensions
  via PIL). Le base64 est reconstruit uniquement à la sauvegarde.
- **`execute_reply` peut arriver avant les sorties** : la réponse vient du canal
  shell, les sorties du canal iopub. Les sorties sont donc toujours acceptées
  après la réponse, et tout ce qui dépend de « la cellule a fini » (le
  défilement, notamment) est déclenché par les sorties, pas seulement par la réponse.
- `input()` est relayé vers `vim.ui.input`, `clear_output(wait=True)` est
  honoré, les tracebacks ANSI sont convertis en highlights.

---

## 5. Rendu : ce qui donne l'aspect « VSCode »

| Élément | Mécanisme | Pourquoi celui-là |
| --- | --- | --- |
| Barre d'en-tête | `virt_text` en `overlay` sur la ligne de fence + `line_hl_group` | recouvre le marqueur et colore toute la ligne, sans consommer de ligne réelle |
| Statut / durée | second extmark en `right_align` | reste à droite quelle que soit la largeur |
| Barre latérale de cellule | fonction `'statuscolumn'` | zéro extmark, calculée seulement pour les lignes visibles, et placée **contre le texte** (un signe serait à gauche des numéros) |
| Cellule active | `line_hl_group` par ligne, plafonné à 400 lignes | visible sans casser la transparence du thème |
| Sorties | `virt_lines` sur la ligne de fermeture | suivent le texte automatiquement lors des éditions |
| Espace inter-cellules | la fence de fermeture recouverte d'espaces | une seule ligne vide entre cellules, sans ligne virtuelle supplémentaire |

Écarté : un `nvim_set_decoration_provider` avec extmarks éphémères (plus
efficace en théorie) — les `virt_lines` n'y sont pas supportées, or c'est le
support des sorties.

### Couleurs

Rien n'est codé en dur. `theme.lua` construit une palette à partir de base46
(NvChad) quand il est présent, sinon des groupes standards (`Normal`,
`Comment`, `Function`, `DiagnosticError`…), puis mélange les teintes
(`blend`) pour fabriquer fonds de barre, cellule active, bordures de sortie.
La transparence est détectée (`Normal.bg == nil`) et les surfaces sont
assombries/éclaircies selon la luminance du fond. Tout est recalculé sur
`ColorScheme`, et chaque groupe `JupynbXxx` reste surchargeable via `opts.highlights`.

---

## 6. Sauvegarde : rester un vrai `.ipynb`

`BufWriteCmd` reconstruit le notebook depuis le modèle et l'écrit avec un
encodeur JSON maison qui **imite exactement `json.dumps(nb, indent=1,
sort_keys=True)`** — le format de nbformat. Objectif : qu'un notebook sauvé par
Neovim ne produise pas un diff git géant face à un notebook sauvé par Jupyter
ou VSCode.

Sont préservés : métadonnées du notebook et des cellules, `execution_count`,
ids nbformat (schéma ≥ 4.5), clés inconnues des cellules, sorties (images
ré-encodées en base64 depuis le disque), `text` des streams sous forme de liste
de lignes. `save.strip_outputs = true` permet l'inverse (notebook propre pour
git).

Garde-fous : un fichier illisible n'est jamais écrasé silencieusement (le
buffer bascule sur le JSON brut et `:w` réécrit ce JSON), et un `.ipynb`
inexistant crée un notebook vide plutôt qu'une erreur.

---

## 7. Images : la partie la plus subtile

Le rendu passe par `image.nvim` (protocole graphique kitty, supporté par
Ghostty). Trois décisions :

1. **C'est jupynb qui réserve la place**, pas `image.nvim`
   (`with_virtual_padding = false`). Les lignes vides font partie du bloc de
   sortie, donc le texte et la figure restent dans le bon ordre ; la position
   dans le bloc est passée via `render_offset_top`.
2. **Identifiants stables** par (cellule, index de sortie) : à chaque rendu
   l'image est *déplacée* plutôt que retransmise — pas de scintillement quand
   on tape dans le buffer, et pas de fuite d'images fantômes.
3. **Dimensions lues dans le PNG** (chunk IHDR) quand le notebook vient du
   disque : le `.ipynb` ne stocke aucune taille, et une taille par défaut
   donnait un rapport d'aspect faux.

### Le bug « pas d'image » — et ce qu'il a appris

Un terminal ne peut dessiner que sur des lignes **réellement affichées**. Après
une exécution, les lignes virtuelles de la sortie tombent souvent sous le bas de
la fenêtre : `image.nvim` abandonne (`image is below viewport`) et rien
n'apparaît tant qu'on ne défile pas. S'ajoutait un problème de timing : le
rendu était demandé avant que Neovim n'ait remis l'écran en page, donc
`screenpos()` renvoyait une position périmée.

Trois correctifs :

- `reveal_output` : après exécution, on défile **juste ce qu'il faut** pour
  amener la sortie dans le champ de vision, sans bouger le curseur (plafonné par
  `scrolloff`). C'est le comportement de Jupyter/VSCode.
- un rafraîchissement différé (40 ms) qui force une mise en page avant de
  redessiner les images ;
- la cible du défilement est résolue **au déclenchement** (cellule sous le
  curseur), sinon un « run all » emmenait la vue sur la dernière cellule exécutée.

Détail qui a coûté du temps : `nvim_win_text_height()` ne compte pas les
`virt_lines` attachées *sous* une ligne. La hauteur du bloc de sortie est donc
mémorisée par le plugin (`cell.out_height`) au lieu d'être déduite de l'API.

### Multiplexeurs

Les séquences graphiques traversent Neovim → multiplexeur → terminal. tmux les
avale sans `allow-passthrough`, herdr ne les rend qu'avec un flag expérimental.
Le plugin détecte les deux cas (`$TMUX` + `tmux show -Apv allow-passthrough`,
`$HERDR_PANE_ID` + lecture de `config.toml`), retombe alors sur le placeholder
texte plutôt que de laisser un trou blanc, et dit une fois par session quoi
changer. `:checkhealth jupynb` le rappelle.

---

## 8. LSP dans les cellules

`otter.nvim` crée des buffers cachés à partir des blocs injectés et y branche le
LSP — il s'appuie donc exactement sur la même injection treesitter que la
coloration, ce qui le rend gratuit ici.

Une garde a été ajoutée : otter n'est activé que si un serveur *activé* pour le
langage peut **réellement** démarrer. `executable()` ne suffit pas — un serveur
livré sous forme de script JavaScript est « exécutable » alors que son
interpréteur manque, et le seul symptôme est un `exit code 127` à chaque
ouverture de notebook. Le test lit donc le shebang du lanceur et vérifie
l'interpréteur.

---

## 9. Ce qui a été modifié dans la config

| Fichier | Changement |
| --- | --- |
| `jupynb.nvim/` | le plugin : 14 modules Lua, le pont Python, README + DESIGN, un notebook de démo |
| `lua/plugins/notebook.lua` | remplacé (molten commenté → spec du plugin + `image.nvim`, `otter.nvim`, `render-markdown.nvim`) |
| `lua/mappings.lua` | bloc de raccourcis notebook commenté → renvoi vers les raccourcis locaux au buffer |
| `README.md` | section « Notebooks (.ipynb) » |
| `lazy-lock.json` | +4 entrées ; les 9 plugins que `Lazy! sync` avait mis à jour au passage ont été remis à leurs commits verrouillés |
| `~/.config/tmux/tmux.conf` | `set -gq allow-passthrough on` (sinon tmux avale les images) |
| `~/.config/herdr/config.toml` | `[experimental] kitty_graphics = true` |

Le plugin a son propre `.stylua.toml` (2 espaces, style plugin Neovim) pour que
le formateur de la config (4 espaces) ne le reformate pas à chaque sauvegarde.

---

## 10. Comment tout a été vérifié

Sans accès au terminal graphique, il a fallu construire les outils de mesure :

| Harnais | Ce qu'il prouve |
| --- | --- |
| 9 suites Lua headless | structure, round-trip `.ipynb`, opérations sur les cellules, préservation des sorties, perfs |
| pilotage du pont en Python | exécution réelle : pandas/polars, matplotlib, erreurs, streaming, `input()`, interruption, `clear_output`, restart |
| client UI via `pynvim` | capture de la **grille d'écran** avec les couleurs : c'est ainsi que l'apparence a été validée (barres, en-têtes, fonds, icônes) |
| pty avec dimensions **en pixels** (`TIOCSWINSZ`) | capture des séquences du protocole kitty : prouve qu'une image est réellement transmise et placée |
| tmux lancé dans ce pty | prouve que le passthrough fonctionne avec la config corrigée |

Bugs trouvés par ces harnais, entre autres : sources aplaties (double découpage),
sorties perdues au chargement (ancres posées après la resynchronisation),
gravité des extmarks, identité perdue à la fusion, ANSI nettoyé avant d'être
interprété, glyphes Nerd Font perdus à l'écriture des fichiers (d'où les
échappements `\u{...}`), cache de taille de cellule indexé alors qu'il valait
`false`, et le comportement de `nvim_win_text_height` décrit plus haut.

Repères de performance (300 cellules, 1 499 lignes) : ouverture 15 ms,
resynchronisation 0,3 ms, rendu complet 1,5 ms, sauvegarde 4 ms, `statuscolumn`
50 appels 0,13 ms. Coût au démarrage de Neovim : ~3 ms.

---

## 11. Limites connues et pistes

- Le HTML riche (tableaux pandas stylés) retombe sur `text/plain` : un terminal
  ne rend pas du HTML. Une conversion HTML → texte tabulaire serait possible.
- Éditer une ligne de marqueur casse la structure ; `:Jupynb fix` la
  reconstruit depuis le modèle, mais une cellule fusionnée par erreur ne peut
  pas être re-séparée automatiquement.
- Pas de debugger (`debugpy` est installé, le protocole DAP passerait par le
  même pont).
- Pas de complétion fournie par le kernel (`complete_request` existe déjà côté
  pont, il ne manque qu'une source `blink.cmp`).
- Le plugin est autonome : il peut être sorti de la config et publié comme dépôt
  à part sans modification.
