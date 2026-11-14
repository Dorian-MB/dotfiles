# macos

Config propre au Mac. Chaque sous-dossier est lié dans `~/.config/` (`./install.sh macos`).

| Dossier | Outil | Rôle |
|---|---|---|
| [`aerospace/`](aerospace) | AeroSpace | gestionnaire de fenêtres en tuiles, espaces de travail |
| [`sketchybar/`](sketchybar) | SketchyBar | barre du haut (espaces, app active, stats, heure, batterie) |
| [`ghostty/`](ghostty) | Ghostty | terminal principal |
| [`wezterm/`](wezterm) | WezTerm | terminal secondaire |

AeroSpace et SketchyBar fonctionnent ensemble : à chaque changement d'espace, AeroSpace envoie l'événement `aerospace_workspace_change` à SketchyBar.

Thème commun : Catppuccin Macchiato. Police : `JetBrainsMono Nerd Font`.
