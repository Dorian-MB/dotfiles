# windows

Config du poste Windows (+ WSL). Depuis WSL, `./install.sh` (ou `./install.sh windows`) **copie** ces fichiers
vers le dossier Windows : les applis Windows ne suivent pas les liens symboliques de WSL. Un fichier déjà là et
différent est gardé en `.bak` avant d'être remplacé ; relance le script après avoir modifié un fichier ici.
`/etc/wsl.conf` demande `sudo`. Le dossier Windows est trouvé via `cmd.exe` (sinon `WINHOME=/mnt/c/Users/<toi>`).

| Dossier | Outil | Destination |
|---|---|---|
| [`glaze/`](glaze) | GlazeWM, gestionnaire de fenêtres en tuiles | `%USERPROFILE%\.glzr\glazewm\config.yaml` |
| [`yasb/`](yasb) | YASB, barre du haut | `%USERPROFILE%\.config\yasb\` |
| [`wezterm/`](wezterm) | WezTerm, ouvre directement WSL | `%USERPROFILE%\.wezterm.lua` |
| [`wsl/`](wsl) | WSL 2 (Ubuntu) | `%USERPROFILE%\.wslconfig`, `/etc/wsl.conf` |

Les raccourcis de GlazeWM sont proches de ceux d'AeroSpace (`Alt+h/j/k/l`, `Alt+lettre` pour les espaces).

`glaze/config.yaml` et `yasb/yasb_colors.css` sont en fins de ligne **CRLF** : garde-les ainsi si tu les modifies depuis macOS (voir `.gitattributes`).
