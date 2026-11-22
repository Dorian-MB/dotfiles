# savvy-flow

Copie modifiée du skill **savvy-flow** de claude-kit. La session principale planifie, découpe le travail, le confie à des sous-agents de niveaux différents, puis relit leur résultat.

Modifications par rapport à l'original : l'orchestrateur choisit le modèle de chaque tâche, `light` utilise Haiku par défaut et `medium` Sonnet. **Ne pas** installer aussi `savvy-flow@claude-kit`.

| Fichier | Rôle |
|---|---|
| `skills/savvy-flow/SKILL.md` | instructions de l'orchestrateur |
| `skills/savvy-flow/greenfield.md` | étapes nouveau projet, lues seulement si le dossier est vide |
| `skills/savvy-flow/design.md` | règles de design, lues seulement si la tâche touche l'UI |
| `agents/savvy-fable.md` | Fable, effort high : logique très complexe, bugs coriaces |
| `agents/savvy-heavy.md` | Opus, effort high : code inconnu ou désordonné, multi-fichiers, refactors délicats, beaucoup de cas limites |
| `agents/savvy-medium.md` | Sonnet, effort medium : fonctionnalités standard |
| `agents/savvy-light.md` | Haiku, effort medium : éditions mécaniques, config, lancer les tests |

Installation (liens symboliques : les modifications du dépôt sont actives tout de suite) :

```bash
mkdir -p ~/.claude/skills ~/.claude/agents
rm -rf ~/.claude/skills/savvy-flow  # retire une ancienne copie
ln -s ~/dotfiles/agents/savvy-flow/skills/savvy-flow ~/.claude/skills/savvy-flow
ln -sf ~/dotfiles/agents/savvy-flow/agents/*.md ~/.claude/agents/
```

## Utilisation

| Commande | Action |
|---|---|
| `/savvy-flow <tâche>` | lance le flux orchestré sur la tâche |

