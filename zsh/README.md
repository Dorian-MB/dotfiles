# zsh

Config du shell : prompt starship, coloration syntaxique, autosuggestions, alias `eza`, raccourcis `fzf`.

| Fichier | Lien | Rôle |
|---|---|---|
| `.zprofile` | `~/.zprofile` | shells de login : Homebrew (`brew shellenv`) |
| `.zshenv` | `~/.zshenv` | tous les shells : `PATH` de uv (`~/.local/bin`) et cargo |
| `.zshrc` | `~/.zshrc` | shells interactifs : tout le reste |

Les trois vont ensemble : `.zshrc` appelle `brew --prefix`, qui vient de `.zprofile`.
Installation : `./install.sh zsh` depuis la racine du dépôt.

Secrets : `.zshrc` source `~/.zshrc_secret` s'il existe. Ce fichier reste **hors du dépôt** (voir le README racine).

Dépendances : `brew install starship eza fzf fd bat zsh-syntax-highlighting zsh-autosuggestions`.

## Raccourcis clavier

Mode emacs (`set -o emacs`).

| Touche | Action |
|---|---|
| `Ctrl+→` / `Alt+→` | mot suivant |
| `Ctrl+←` / `Alt+←` | mot précédent |

## Fonctions

| Commande | Action |
|---|---|
| `fcd` | choisir un dossier avec `fd` + `fzf`, puis `cd` dedans |
| `fvi [motif]` | choisir un fichier avec `fd` + `fzf` (aperçu `bat`), l'ouvrir dans nvim |
| `cd` | lance `ll` après chaque `cd`, seulement dans un terminal interactif |

## Alias

| Alias | Commande |
|---|---|
| `ls`, `ll`, `la`, `lt` | `eza` (simple, liste + git, avec cachés, arbre à 2 niveaux) |
| `lls`, `las`, `lts` | pareil avec la taille totale des dossiers |
| `l` | le vrai `ls` |
| `vi` | `nvim` (`vi12` : Homebrew, `vi11` : `/opt/nvim`) |
| `py` | `python` (le venv actif, sinon `~/.venvs/nvim`) |
| `activate-base-env` | active `~/.venvs/base/venv3.14` |
| `cl`, `cc` | `clear`, `claude` |
| `dot`, `cdvi`, `cdd`, `cdai`, `cdi` | `cd` vers dotfiles, dotfiles/nvim, CODE, AI, CV |

Pas d'`alias python=…`, c'est voulu : un alias passerait devant le `PATH` d'un venv activé.
