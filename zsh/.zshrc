# StarShip
eval "$(starship init zsh)"

# import secret key
[ -f ~/.zshrc_secret ] && source ~/.zshrc_secret

# import alias
[ -f ~/.zshrc_alias ] && source ~/.zshrc_alias

# History
HISTFILE=~/.zsh_history HISTSIZE=50000 SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space

# Completion (macOS doesn't run compinit by default; brew shellenv already adds its fpath)
autoload -Uz compinit && compinit

# Activate autosuggestions ($HOMEBREW_PREFIX comes from .zprofile, no `brew` call)
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export PATH="$HOME/.venvs/nvim/bin:$PATH"
# export PATH="/opt/nvim/bin:$PATH"

# Rainfrog
export EDITOR=nvim

# set -o vi
set -o emacs
# Ctrl/Alt + flèches : mot suivant / précédent (sans ça zsh affiche ";5C")
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word


# ls after cd (interactive terminal only: `eza --git` blocks scripts/agents that cd)
chpwd() {
  [[ -o interactive && -t 1 ]] && ll
}

# fcd -> Cherche un dossier et se déplace (cd) dedans directement
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf +m)
  [ -n "$dir" ] && cd "$dir"
}
# fvi -> Cherche un fichier avec fd + fzf et l'ouvre dans vi
fvi() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf \
    --query="$1" \
    --select-1 \
    --exit-0 \
    --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}')

  [ -n "$file" ] && vi "$file"
}

# fzf: Ctrl+R history, Ctrl+T file, Alt+C cd
source <(fzf --zsh)
# zoxide: `z <part of name>` jumps to a frequent directory
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Syntax highlighting: must be sourced last (plugin requirement)
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Disable underline
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
