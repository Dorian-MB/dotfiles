# zsh

Config du shell : prompt starship, historique partagé, complétion, coloration syntaxique, autosuggestions,
alias `eza`, raccourcis `fzf`, `zoxide`.

| Fichier | Lien | Rôle |
|---|---|---|
| `.zprofile` | `~/.zprofile` | shells de login : Homebrew (`brew shellenv`) |
| `.zshenv` | `~/.zshenv` | tous les shells : `PATH` de uv (`~/.local/bin`) et cargo |
| `.zshrc` | `~/.zshrc` (macOS) | shells interactifs : tout le reste |
| `.zshrc_windows` | `~/.zshrc` (Linux / WSL) | pareil sans Homebrew : `PATH` local, plugins apt dans `/usr/share` |
| `.zshrc_alias` | `~/.zshrc_alias` | les alias, partagés par les deux `.zshrc` |

Sur macOS, les trois vont ensemble : `.zshrc` utilise `$HOMEBREW_PREFIX`, défini par `.zprofile`.
Installation : `./install.sh zsh` depuis la racine du dépôt (choisit le bon `.zshrc` selon `uname`).
À la main, toujours des chemins absolus : un lien relatif se résout depuis `~` et casse.

Dépendances WSL : `sudo apt install zsh eza fzf fd-find bat zoxide zsh-syntax-highlighting zsh-autosuggestions`,
puis `ln -s "$(which fdfind)" ~/.local/bin/fd` et `ln -s "$(which batcat)" ~/.local/bin/bat`.
`fzf --zsh` demande fzf >= 0.48 ; zoxide n'est chargé que s'il est installé (sinon `cargo install zoxide`).

Secrets : `.zshrc` source `~/.zshrc_secret` s'il existe. Ce fichier reste **hors du dépôt** (voir le README racine).

Dépendances : `brew install starship eza fzf fd bat zoxide zsh-syntax-highlighting zsh-autosuggestions`.

Historique : `~/.zsh_history`, 50 000 lignes, partagé entre les terminaux ouverts, sans doublons.
Une commande tapée avec une espace devant n'est pas enregistrée (pratique pour un secret).

## Raccourcis clavier

Mode emacs (`set -o emacs`).

| Touche | Action |
|---|---|
| `Ctrl+→` / `Alt+→` | mot suivant |
| `Ctrl+←` / `Alt+←` | mot précédent |
| `Ctrl+R` | chercher dans l'historique (fzf) |
| `Ctrl+T` | insérer un chemin de fichier (fzf) |
| `Alt+C` | `cd` dans un sous-dossier (fzf) |

## Fonctions

| Commande | Action |
|---|---|
| `fcd` | choisir un dossier avec `fd` + `fzf`, puis `cd` dedans |
| `fvi [motif]` | choisir un fichier avec `fd` + `fzf` (aperçu `bat`), l'ouvrir dans nvim |
| `cd` | lance `ll` après chaque `cd`, seulement dans un terminal interactif |
| `z <motif>` / `zi` | zoxide : aller dans le dossier fréquent qui correspond / le choisir avec fzf |

## Alias

| Alias | Commande |
|---|---|
| `ls`, `ll`, `la`, `lt` | `eza` (simple, liste + git, avec cachés, arbre à 2 niveaux) |
| `lls`, `las`, `lts` | pareil avec la taille totale des dossiers |
| `l` | le vrai `ls` |
| `vi` | `nvim` (sur Mac seulement : `vi12` Homebrew, `vi11` `/opt/nvim`) |
| `py` | `python` (le venv actif, sinon `~/.venvs/nvim`) |
| `activate-base-env` | active `~/.venvs/base/venv3.14` |
| `cl`, `cc` | `clear`, `claude` |
| `dot`, `cdvi`, `cdd`, `cdai`, `cdi` | `cd` vers dotfiles, dotfiles/nvim, CODE, AI, CV |

Pas d'`alias python=…`, c'est voulu : un alias passerait devant le `PATH` d'un venv activé.
