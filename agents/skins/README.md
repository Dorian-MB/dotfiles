# skins

Patch pour le mod [skins](https://github.com/hellosverre/claude-skins) (`skins@hellosverre-mods`), qui redessine le transcript de Claude Code.

- `transparent.patch` : dans le thème `catppuccin`, passe `surface` et `zebra` à `transparent`. Les tableaux n'ont plus de bandes opaques et laissent voir le fond du terminal.

Le cache du plugin est écrasé à chaque mise à jour : il faut **réappliquer le patch après chaque mise à jour**.

```bash
for d in ~/.claude/plugins/cache/hellosverre-mods/skins/*/; do (cd "$d" && git apply ~/dotfiles/agents/skins/transparent.patch); done
```

Puis redémarrer Claude Code et lancer `/skin catppuccin`.

Pas de raccourcis clavier.
