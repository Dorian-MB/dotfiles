# Plugins Claude Code

Plugins installés (scope user). Après une install ou une mise à jour : `/reload-plugins` ou redémarrer Claude Code.
Install : voir `agents/claude`.

## ponytail — `ponytail@ponytail`
Mode « dev senior paresseux » : force la solution la plus simple qui marche (YAGNI, stdlib d'abord, pas d'abstraction non demandée). Skills + hook au démarrage + bande au-dessus du prompt.

| Commande | Effet |
|---|---|
| `/ponytail [lite\|full\|ultra\|off]` | Niveau d'intensité, ou off |
| `/ponytail band [on\|off]` | Afficher/masquer la bande |
| `/ponytail-review` | Revue du diff (bugs, sécu, charge, code à couper) ; cible : `uncommitted`, `staged`, `branch`, lien PR |
| `/ponytail-audit` | Même revue sur tout le repo |
| `/ponytail-debt` | Liste les commentaires `shortcut:` laissés pour plus tard |
| `/ponytail-gain` | Gains mesurés (code, coût, vitesse) |
| `/ponytail-help` | Aide-mémoire |

## skins — `skins@hellosverre-mods`
Mod qui redessine le transcript : lignes d'outils avec icônes et durées, diffs, tableaux, code et Mermaid en cartes, bande d'usage, 16 thèmes.

| Commande | Effet |
|---|---|
| `/skin` | Réglages avec aperçu live |
| `/skin <nom>` · `/skin list` | Changer de skin, lister skins et réglages |
| `/skin off` · `on` | Revenir à l'affichage d'origine / réactiver |
| `/skin calm` · `calm off` | Sans animation, sorties repliées |
| `/skin copy` · `copy code` | Copier la dernière réponse / le dernier bloc de code |
| `/skin pin` · `unpin` | Skin propre à ce dossier |
| `/skin help` | Toutes les commandes |

Demander « fais-moi un skin… » à Claude utilise la skill `skin-designer`.

## pane-glass — `pane-glass@dotfiles` (mod perso, `agents/pane-glass`)
Mod : chaque panneau de plugin (`/skin`, `/filetree`, `/replay`…) s'ouvre avec un fond transparent, pour garder l'opacité/le flou du terminal. Rien à configurer.

## session-band — `session-band@claude-kit`
Mod : une bande au-dessus du prompt avec n° de tour, tok/s, coût du tour et de la session, compte à rebours du cache (1 h) et remplissage du contexte. Cadre orange à 20 min de l'expiration du cache, rouge à 10 ; notification à 10 et 5 min.

- `/session_data` : afficher/masquer la bande
- `/session_data demo <minutes>` : simuler le temps de cache restant
- Notification macOS avec titre : construire une fois `notifier/build.sh` dans le dossier du plugin (sinon notification Claude Code basique)

## filetree — `filetree@claude-code-filetree`
Mod : arbre de fichiers façon IDE dans un panneau, avec statut git, et animation sur les fichiers que Claude lit/modifie.

- `/filetree` : afficher/masquer · `/filetree open` : ouvrir/ramener devant · `/filetree <chemin>` : épingler un dossier
- Touches (`agents/keybindings.json`, lié dans `~/.claude/`) : `alt+o` va dans l'arbre, `alt+i` (ou Échap) revient au prompt, `alt+x` ferme l'arbre (rouvrir : `/filetree`). alt+h/l pris par AeroSpace ; ne pas relancer `/filetree keys`.
- Dans l'arbre : touches nvim, `z` saut de dossier (façon zoxide), `s`/`i` recherche par nom, `q` recherche dans le contenu, `d` diff

## cache-tax — `cache-tax@claude-code-mods`
Mod : garde le cache de prompt (1 h) chaud pendant les pauses, et demande confirmation avant un envoi « à froid » en affichant le coût estimé de réécriture. Les pings consomment des tokens.

- `/keepwarm` : garder chaud 6 h · `/keepwarm 90m` : fenêtre plus courte · `/keepwarm off` : arrêter
- `/keepwarm always [24h]` : fenêtre minimale glissante sur chaque tour
- `/cache-tax` : estimation du cache, fenêtre active, coûts à froid de la session
- Au retour à froid (contexte ≥ 50k tokens) : **Send anyway** ou **Don't send**

## replay-theater — `replay-theater@claude-code-playground-mods`
Mod exemple d'Anthropic : après un tour, rejoue une par une les modifications de fichiers faites par Claude (Edit/Write), avec leur diff. Ne fait qu'observer, ne bloque rien.

- Après un tour avec modifications : `r` ou le bouton **Replay** au-dessus du prompt, ou `/replay`
- Panneau : boutons Prev / Next / Close

## blast-radius — `blast-radius@claude-code-playground-mods` (désinstallé)
Désinstallé : il retient la commande dans un panneau, sans notification, facile à rater (refus silencieux après 10 min).

Mod exemple d'Anthropic : bloque les commandes shell risquées et montre ce qu'elles toucheraient avant de les lancer. **Proceed** exécute, **Cancel** refuse (Claude voit la raison).

Commandes surveillées : `rm -r/-f/-rf` (fichiers + taille), `git reset --hard`, `git checkout -- .`/`git restore .`, `git clean`, `git push --force` (commits perdus côté remote), migrations (`manage.py migrate`, `db:migrate`, `alembic upgrade`, `prisma migrate`). Le reste passe normalement.

À savoir : si une commande de Claude semble figée, regarder s'il y a un panneau Proceed/Cancel en attente.
