# Login shells only. Homebrew must come first: .zshrc calls `brew --prefix`.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
