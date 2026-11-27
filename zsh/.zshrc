# One file for macOS (Homebrew) and Linux/WSL (apt). Only four lines differ: marked "macOS/WSL".

# macOS/WSL: on the Mac ~/.local/bin already comes from .zshenv; a WSL ~/.zshenv may not set it
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.venvs/nvim/bin:$PATH"
# macOS/WSL: WSLg runs an X server but DISPLAY is not set; TUIs (rainfrog) need it to reach the Windows clipboard
[[ -z $DISPLAY && -S /tmp/.X11-unix/X0 && -d /mnt/wslg ]] && export DISPLAY=:0
# export PATH="/opt/nvim/bin:$PATH"

# Rainfrog
export EDITOR=nvim

# import secret key
[ -f ~/.zshrc_secret ] && source ~/.zshrc_secret

# import alias
[ -f ~/.zshrc_alias ] && source ~/.zshrc_alias

# StarShip (after PATH: on WSL starship lives in ~/.local/bin)
eval "$(starship init zsh)"

# History
HISTFILE=~/.zsh_history HISTSIZE=50000 SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space

# macOS/WSL: Ubuntu's /etc/zsh/zshrc already runs compinit, macOS doesn't
(( $+functions[compdef] )) || { autoload -Uz compinit && compinit }

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

# macOS/WSL: plugins live in Homebrew's share (no `brew` call: $HOMEBREW_PREFIX is set by .zprofile) or apt's
for _zplug in $HOMEBREW_PREFIX/share /opt/homebrew/share /usr/share; do [[ -d $_zplug/zsh-autosuggestions ]] && break; done
source $_zplug/zsh-autosuggestions/zsh-autosuggestions.zsh
# Syntax highlighting: must be sourced last (plugin requirement)
source $_zplug/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset _zplug
# Disable underline
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
