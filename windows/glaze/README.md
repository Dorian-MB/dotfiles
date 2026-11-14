# GlazeWM

Config du gestionnaire de fenêtres en tuiles [GlazeWM](https://github.com/glzr-io/glazewm) (Windows).

- Fichier : `config.yaml` → `%USERPROFILE%\.config\` (voir le README racine)
- Fins de ligne **CRLF**, à conserver (voir `.gitattributes`).
- La barre est [YASB](../yasb) : elle démarre et arrête GlazeWM elle-même.

## Raccourcis clavier

| Touche | Action |
|---|---|
| `Alt+h/j/k/l` ou `Alt+flèches` | focus à gauche / en bas / en haut / à droite |
| `Alt+Shift+h/j/k/l` ou `Alt+Shift+flèches` | déplacer la fenêtre |
| `Alt+1…9`, `Alt+a/z/e/q/s/c/g` | aller à l'espace 1…9, A, Z, E, Q, S, C, G |
| `Alt+Shift+` (même touche) | envoyer la fenêtre vers cet espace et y aller |
| `Alt+n` / `Alt+p` | espace actif suivant / précédent |
| `Alt+Tab` | dernier espace utilisé |
| `Alt+v` | changer le sens du découpage |
| `Alt+f` | basculer flottant (centré) |
| `Alt+t` | basculer tuile |
| `Alt+Shift+f` | plein écran |
| `Alt+m` | réduire la fenêtre |
| `Alt+Shift+w` | fermer la fenêtre |
| `Alt+Entrée` | ouvrir `cmd` |
| `Alt+r` | mode **redimensionnement** |
| `Alt+Shift+p` | mettre GlazeWM en pause / reprendre |
| `Alt+Shift+r` | recharger la config |
| `Alt+Shift+F4` | quitter GlazeWM |

Mode redimensionnement :

| Touche | Action |
|---|---|
| `h` / `l` ou `←` / `→` | largeur −2 % / +2 % |
| `k` / `j` ou `↑` / `↓` | hauteur +2 % / −2 % |
| `Échap` ou `Entrée` | sortir du mode |
