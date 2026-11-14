# WSL

Config de WSL 2 (Ubuntu).

| Fichier | Destination | Contenu |
|---|---|---|
| `.wslconfig` | `%USERPROFILE%\.wslconfig` (Windows) | 3 Go de RAM, 2 Go de swap, mémoire rendue progressivement à Windows |
| `wsl.conf` | `/etc/wsl.conf` (dans Ubuntu, avec `sudo`) | systemd activé, utilisateur par défaut `dorianmariani`, `PATH` Windows ajouté |

Les changements ne s'appliquent qu'après `wsl --shutdown`.

systemd est nécessaire au serveur SSH utilisé par [WezTerm](../wezterm).

Pas de raccourcis clavier.
