# Sourced by every zsh (interactive or not). Keep it to PATH/env only.

# uv
export PATH="$HOME/.local/bin:$PATH"

# rust / cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
