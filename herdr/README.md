# herdr

Config de herdr, le multiplexeur de terminal qui gère les espaces, les onglets et les panes d'agents.

- Fichier suivi : `config.toml`. Le dossier entier est lié à `~/.config/herdr` (`./install.sh herdr`).
- Les fichiers d'exécution (sessions, logs, sockets) sont dans le `.gitignore`.
- `kitty_graphics = true` : affiche les images (figures matplotlib de jupynb.nvim) dans les panes. Le terminal extérieur doit aussi supporter le protocole kitty (Ghostty : oui).

## Raccourcis clavier

Préfixe : **`Ctrl+w`**, puis la touche.

| Touche | Action |
|---|---|
| `t` | nouvel onglet |
| `1`…`9` | aller à l'onglet N |
| `Tab` | revenir au pane/onglet précédent |
| `Espace` | pane suivant |
| `a` / `Shift+a` | agent suivant / précédent |
| `Shift+t` | nouvel espace |
| `Shift+n` / `Shift+p` | espace suivant / précédent |
| `Shift+1`…`9` | aller à l'espace N |
| `(` | mode copie |

`Ctrl+w` est aussi le préfixe des fenêtres dans nvim. C'est voulu : dans un pane herdr, nvim reçoit `Ctrl+w` après le préfixe.
