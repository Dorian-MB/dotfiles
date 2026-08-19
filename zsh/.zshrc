# StarShip
eval "$(starship init zsh)"

# Activate syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

##NVIM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# export PATH="$PATH:/Users/dorian/Library/Python/3.9/bin"
export PATH="$HOME/.venvs/nvim/bin:$PATH"
export KAGGLE_API_TOKEN=KGAT_095768fe0f9c599df4081fa5995143fd
# export PATH="/opt/nvim/bin:$PATH"
export PATH="/opt/homebrew/bin/nvim:$PATH"

# For nvim/avante
export TURBOFIELDFARE_API_KEY=local

# set -o vi
set -o emacs


# alias l="ls -l"
# alias ls=ls
# alias la="ls -A"
# alias lA="ls -la"
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --header --git --group-directories-first'
alias la='eza -la --icons --header --git --group-directories-first'
alias lt='eza -l --icons --tree --level=2'

alias vi=nvim
alias vi12="/opt/homebrew/bin/nvim"
alias vi11="/opt/nvim/bin/nvim"

alias cl=clear
alias cc=claude
alias cdd="cd ~/Documents/CODE/"
alias cdai="cd ~/AI/turbo-fieldfare/"
alias cdvi="cd ~/dotfiles/nvim/"
alias dot="cd ~/dotfiles"

alias python="$HOME/.venvs/nvim/bin/python"
alias py=python
alias pip="$HOME/.venvs/nvim/bin/python -m pip"


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


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
