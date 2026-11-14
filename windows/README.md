# windows

Config du poste Windows (+ WSL). Rien n'est lié automatiquement : `install.sh` ne gère que le Mac, ces fichiers se copient à la main.

| Dossier | Outil | Destination |
|---|---|---|
| [`glaze/`](glaze) | GlazeWM, gestionnaire de fenêtres en tuiles | `%USERPROFILE%\.config\` (voir le README racine) |
| [`yasb/`](yasb) | YASB, barre du haut | `%USERPROFILE%\.config\yasb\` |
| [`wezterm/`](wezterm) | WezTerm, ouvre directement WSL | `%USERPROFILE%\.wezterm.lua` |
| [`wsl/`](wsl) | WSL 2 (Ubuntu) | `%USERPROFILE%\.wslconfig`, `/etc/wsl.conf` |

Les raccourcis de GlazeWM sont proches de ceux d'AeroSpace (`Alt+h/j/k/l`, `Alt+lettre` pour les espaces).

`glaze/config.yaml` et `yasb/yasb_colors.css` sont en fins de ligne **CRLF** : garde-les ainsi si tu les modifies depuis macOS (voir `.gitattributes`).
