# savvy-flow

Copie modifiée du skill **savvy-flow** de claude-kit. La session principale planifie, découpe le travail, le confie à des sous-agents de niveaux différents, puis relit leur résultat.

Modifications par rapport à l'original : l'orchestrateur choisit le modèle de chaque tâche, `light` utilise Haiku par défaut et `medium` Sonnet. **Ne pas** installer aussi `savvy-flow@claude-kit`.

| Fichier | Rôle |
|---|---|
| `skills/savvy-flow/SKILL.md` | instructions de l'orchestrateur |
| `agents/savvy-fable.md` | Fable, effort high : logique très complexe, bugs coriaces |
| `agents/savvy-heavy.md` | Opus, effort xhigh : code inconnu ou désordonné, multi-fichiers |
| `agents/savvy-careful.md` | Opus, effort high : refactors délicats, beaucoup de cas limites |
| `agents/savvy-medium.md` | Sonnet, effort medium : fonctionnalités standard |
| `agents/savvy-light.md` | Haiku, effort low : éditions mécaniques, config, lancer les tests |

Installation (copie, pas de lien) :

```bash
mkdir -p ~/.claude/skills ~/.claude/agents
cp -R ~/dotfiles/agents/savvy-flow/skills/savvy-flow ~/.claude/skills/
cp ~/dotfiles/agents/savvy-flow/agents/*.md ~/.claude/agents/
```

## Utilisation

| Commande | Action |
|---|---|
| `/savvy-flow <tâche>` | lance le flux orchestré sur la tâche |

Si le mod `savvy-progress` (claude-kit) est installé, une barre de progression suit les tâches.
