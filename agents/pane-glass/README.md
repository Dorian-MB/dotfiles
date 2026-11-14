# pane-glass

Mod Claude Code maison : chaque pane de plugin (`/skin`, `/filetree`, `/replay`…) s'ouvre avec un fond **transparent**, ce qui laisse voir l'opacité et le flou du terminal.

| Fichier | Rôle |
|---|---|
| `.claude-plugin/plugin.json` | manifeste du plugin |
| `hooks/hooks.json` | déclare le module de hooks |
| `hooks/register.ts` | met `backgroundColor: 'transparent'` sur `ui.open` quand le pane n'impose pas de couleur |

Installation (marketplace locale `agents/.claude-plugin/marketplace.json`) :

```bash
claude plugin marketplace add ~/dotfiles/agents
claude plugin install pane-glass@dotfiles
```

Pas de raccourcis clavier.
