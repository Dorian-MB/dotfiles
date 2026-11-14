# AeroSpace

Config du gestionnaire de fenêtres en tuiles [AeroSpace](https://github.com/nikitabobko/AeroSpace).

- Fichier : `aerospace.toml`. Le dossier est lié à `~/.config/aerospace` (`./install.sh macos/aerospace`).
- Installation : `brew install nikitabobko/tap/aerospace FelixKratz/formulae/borders`
- Démarre à la connexion et recharge sa config tout seul quand le fichier change.
- Au démarrage, lance `borders` (bordure turquoise autour de la fenêtre active).
- Le Finder est toujours flottant.

## Lien avec SketchyBar

- `exec-on-workspace-change` envoie `aerospace_workspace_change` à SketchyBar, qui met à jour les pastilles des espaces.
- `persistent-workspaces` est la **seule** liste des espaces affichés dans la barre : `sketchybar/helpers/workspaces.sh` la lit directement. Garde-la sur **une seule ligne**.

## Clavier AZERTY

`key-mapping` échange `q↔a` et `w↔z` : les touches écrites dans le fichier sont les lettres **AZERTY** que tu vois sur le clavier. Pour les symboles, le tableau donne la touche physique d'un Mac AZERTY.

## Raccourcis clavier

Mode principal :

| Touche | Action |
|---|---|
| `Alt+h/j/k/l` | focus à gauche / en bas / en haut / à droite |
| `Alt+Shift+h/j/k/l` | déplacer la fenêtre |
| `Alt+1…4`, `Alt+a/c/d/e/q/s/z` | aller à l'espace 1…4, A, C, D, E, Q, S, Z |
| `Alt+Shift+` (même touche) | envoyer la fenêtre vers cet espace |
| `Alt+Tab` | revenir à l'espace précédent |
| `Alt+Shift+Tab` | envoyer l'espace sur l'écran suivant |
| `Alt+:` (touche `: /`) | disposition en tuiles (horizontale ↔ verticale) |
| `Alt+;` (touche `; .`) | disposition en accordéon (horizontale ↔ verticale) |
| `Alt+-` | rétrécir la fenêtre |
| `Alt+=` | agrandir la fenêtre |
| `Alt+f` | basculer flottant ↔ tuile |
| `Alt+Shift+f` | plein écran |
| `Alt+Shift+m` | entrer en mode **service** |

Mode service (chaque touche revient ensuite au mode principal) :

| Touche | Action |
|---|---|
| `Échap` | recharger la config |
| `r` | remettre à plat la disposition de l'espace |
| `f` | basculer flottant ↔ tuile |
| `Retour arrière` | fermer toutes les fenêtres sauf l'active |
| `Alt+Shift+h/j/k/l` | regrouper avec la fenêtre voisine dans cette direction |

`Alt+d` (espace D) a un raccourci mais n'est pas dans `persistent-workspaces` : il n'a donc pas de pastille dans la barre.
