#!/usr/bin/env zsh

# The Catppuccin logo item: clicking it fully reloads sketchybar.
case "$SENDER" in
"mouse.clicked")
    sketchybar --remove '/.*/'
    source "$HOME/.config/sketchybar/sketchybarrc"
    ;;
esac
