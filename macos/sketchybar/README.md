# SketchyBar

Barre du haut avec [SketchyBar](https://github.com/FelixKratz/SketchyBar), couleurs Catppuccin Macchiato.

- Le dossier est lié à `~/.config/sketchybar` (`./install.sh macos/sketchybar`). Tous les scripts passent par ce chemin.
- Installation : `brew install FelixKratz/formulae/sketchybar`, puis `brew services start sketchybar`.
- Polices : `JetBrainsMono Nerd Font`, et `helpers/sketchybar-app-font.ttf` (icônes d'apps des espaces) à installer.

## Contenu

| Élément | Où | Script |
|---|---|---|
| logo (cliquer = recharger la barre) | gauche | `plugins/reload.sh` |
| espaces AeroSpace (icônes des apps ouvertes) | gauche | `plugins/aerospace_workspaces.sh` |
| app au premier plan | gauche | `plugins/front_app.sh` |
| RAM (gauche de l'encoche), CPU / GPU (droite) | centre | `plugins/stats.sh` |
| volume, batterie, heure | droite | `plugins/volume.sh`, `plugins-laptop/battery.sh`, `plugins/clock.sh` |

Un espace n'est affiché que s'il contient une fenêtre ou s'il est actif. La pastille de l'espace actif est verte.

## Fichiers

| Fichier | Rôle |
|---|---|
| `sketchybarrc` | point d'entrée : charge la barre laptop |
| `sketchybarrc-laptop` | barre utilisée (avec l'encoche) |
| `sketchybarrc-desktop` | autre style pour écran externe, gardé exprès. Échanger les deux lignes `source` de `sketchybarrc` pour l'utiliser |
| `colors.sh` | toutes les couleurs (`CAT_*`), source unique |
| `helpers/workspaces.sh` | liste des espaces, lue dans `aerospace.toml` (`persistent-workspaces`) |
| `helpers/icon_map.sh` | nom d'app → glyphe de `sketchybar-app-font` (fichier généré) |
| `helpers/sketchybar-app-font.*` | police d'icônes d'apps |
| `plugins/` | scripts communs aux deux barres |
| `plugins-laptop/` | scripts propres au laptop (batterie) |

## Souris

| Action | Effet |
|---|---|
| clic sur le logo | recharge toute la barre |
| clic sur un espace | va sur cet espace dans AeroSpace |

Pas de raccourcis clavier (ceux des espaces sont dans [`../aerospace`](../aerospace)).
