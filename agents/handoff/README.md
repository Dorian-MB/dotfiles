# handoff

Confie une tâche à une **nouvelle session Claude Code**, dans un nouvel onglet herdr. La session actuelle reste intacte, et la nouvelle démarre avec un contexte minimal : seulement la tâche et ce qui, dans la conversation, lui est utile.

| Commande | Action |
|---|---|
| `/handoff <tâche>` | Nouvelle session qui lit le fichier de tâche et l'exécute |
| `/handoff --savvy <tâche>` | Pareil, mais la tâche est exécutée par `/savvy-flow` |
| `/handoff --clear [slug]` | Supprime un fichier de tâche (par défaut, le plus récent) |
| `/handoff --clear-all` | Supprime tous les fichiers de tâche du projet |

Déroulement : Claude écrit `.claude/tasks/<slug>.md`, puis ouvre l'onglet tout de suite, sans demander de validation (il affiche le chemin du fichier). Hors de herdr, la session démarre en arrière-plan (`claude --bg`), et on la rejoint avec `claude attach <id>`.

| Fichier | Rôle |
|---|---|
| `skills/handoff/SKILL.md` | Instructions : quoi garder du contexte, format du fichier |
| `skills/handoff/handoff.sh` | Ouvre l'onglet herdr et lance `claude` (la commande est protégée avec `printf %q`, car `herdr pane run` ne protège pas les arguments) |

Installation (lien symbolique : les modifications du dépôt sont actives tout de suite) :

```bash
mkdir -p ~/.claude/skills
rm -rf ~/.claude/skills/handoff  # retire une ancienne copie
ln -s ~/dotfiles/agents/handoff/skills/handoff ~/.claude/skills/handoff
```

Les fichiers `.claude/tasks/*.md` restent dans le projet : ajoute `.claude/tasks/` au `.gitignore`, et nettoie-les avec `--clear` ou `--clear-all`.
