#!/usr/bin/env bash
# macOS preferences (picked from mathiasbynens/dotfiles .macos). Idempotent.
#   ./defaults.sh          apply
#   ./defaults.sh --undo   back to the macOS defaults (same as defaults-undo.sh)
# Keyboard and Spaces settings take effect after logging out.

set -u
undo=0; [ "${1:-}" = "--undo" ] && undo=1

# domain  key  type  value
SETTINGS=(
  "NSGlobalDomain InitialKeyRepeat -int 15"
  "NSGlobalDomain ApplePressAndHoldEnabled -bool false"
  "NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false"
  "NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false"
  "NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false"
  "NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false"
  "NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true"
  "NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true"
  "NSGlobalDomain NSWindowShouldDragOnGesture -bool true"
  "com.apple.desktopservices DSDontWriteNetworkStores -bool true"
  "com.apple.desktopservices DSDontWriteUSBStores -bool true"
  "com.apple.finder AppleShowAllFiles -bool true"
  "com.apple.finder _FXShowPosixPathInTitle -bool true"
  "com.apple.screencapture location -string $HOME/Pictures/Screenshots"
  "com.apple.screencapture disable-shadow -bool true"
  "com.apple.spaces spans-displays -bool true"
  # Already set on the current Mac before this script: uncomment on a new Mac.
  # Kept commented so defaults-undo.sh leaves them alone.
  # "NSGlobalDomain KeyRepeat -int 1"
  # "NSGlobalDomain AppleShowAllExtensions -bool true"
  # "NSGlobalDomain _HIHideMenuBar -bool true"
  # "com.apple.finder ShowPathbar -bool true"
  # "com.apple.finder FXPreferredViewStyle -string Nlsv"
  # "com.apple.finder FXDefaultSearchScope -string SCcf"
  # "com.apple.dock autohide -bool true"
  # "com.apple.dock mru-spaces -bool false"
  # "com.apple.dock expose-group-apps -bool true"
)

for entry in "${SETTINGS[@]}"; do
  read -r domain key type value <<<"$entry"
  if [ $undo = 1 ]; then
    defaults delete "$domain" "$key" 2>/dev/null && echo "reset  $domain $key"
  else
    defaults write "$domain" "$key" "$type" "$value" && echo "set    $domain $key = $value"
  fi
done

if [ $undo = 1 ]; then
  chflags hidden ~/Library && echo "hidden ~/Library"
else
  mkdir -p ~/Pictures/Screenshots
  chflags nohidden ~/Library && echo "shown  ~/Library"
fi

killall Finder SystemUIServer 2>/dev/null
echo "done; log out and back in for the keyboard and Spaces settings"
