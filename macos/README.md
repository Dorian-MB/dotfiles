# macos

Config propre au Mac. Chaque sous-dossier est lié dans `~/.config/` (`./install.sh macos`).

| Dossier | Outil | Rôle |
|---|---|---|
| [`aerospace/`](aerospace) | AeroSpace | gestionnaire de fenêtres en tuiles, espaces de travail |
| [`sketchybar/`](sketchybar) | SketchyBar | barre du haut (espaces, app active, stats, heure, batterie) |
| [`ghostty/`](ghostty) | Ghostty | terminal principal |
| [`wezterm/`](wezterm) | WezTerm | terminal secondaire |

## Réglages système

`./defaults.sh` applique des préférences macOS (repeat clavier, plus de guillemets/tirets/correction auto, plus de `.DS_Store` sur réseau/USB, fichiers cachés et `~/Library` visibles, captures dans `~/Pictures/Screenshots` sans ombre, ctrl+cmd+glisser pour déplacer une fenêtre, un seul jeu d'espaces pour tous les écrans pour AeroSpace). La liste est en haut du script. `./defaults-undo.sh` remet tout aux valeurs par défaut de macOS.

En bas de la liste, en commentaire, il y a les réglages que ce Mac avait déjà avant le script (repeat rapide, extensions visibles, barre de menu cachée, barre de chemin et vue liste dans le Finder, recherche dans le dossier courant, Dock masqué, espaces qui ne se réorganisent pas tout seuls, fenêtres groupées par app dans Mission Control). Sur un nouveau Mac, décommente-les avant de lancer le script. Comme ils sont en commentaire, `defaults-undo.sh` n'y touche pas. Pour le clavier et les espaces, il faut se déconnecter.

AeroSpace et SketchyBar fonctionnent ensemble : à chaque changement d'espace, AeroSpace envoie l'événement `aerospace_workspace_change` à SketchyBar.

Thème commun : Catppuccin Macchiato. Police : `JetBrainsMono Nerd Font`.
