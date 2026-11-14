# YASB

Config de la barre [YASB](https://github.com/amnweb/yasb) (Windows), qui accompagne [GlazeWM](../glaze).

| Fichier | Rôle |
|---|---|
| `config.yaml` | la barre et ses widgets |
| `styles.css` | apparence des widgets |
| `yasb_colors.css` | palette de couleurs (fins de ligne **CRLF**, à conserver) |

- Destination : `%USERPROFILE%\.config\yasb\`
- YASB recharge tout seul la config et le CSS quand les fichiers changent.
- Elle pilote GlazeWM : `start_command`, `stop_command` et `reload_command` dans `config.yaml`.
- Widgets : espaces GlazeWM, horloge, météo (Open-Meteo), pomodoro, notes, todo, notifications, CPU / RAM / disque / GPU, luminosité, volume, Bluetooth, Wi-Fi / Ethernet, zone de notification, corbeille, fonds d'écran, menu d'extinction, lanceur d'apps.
- `config.yaml` est exclu du graphe graphify (`.graphifyignore`) : ses centaines de clés noyaient le vrai code.

## Raccourcis clavier

| Touche | Action |
|---|---|
| `Alt+Espace` | ouvrir / fermer le lanceur d'apps (Quick Launch) |

Les autres actions se font à la souris, sur les widgets.
