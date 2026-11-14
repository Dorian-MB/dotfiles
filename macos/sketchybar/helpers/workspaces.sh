#!/bin/bash

# AeroSpace workspaces sketchybar knows about, read from `persistent-workspaces`
# in aerospace.toml (the single source of truth). A workspace missing from that
# list gets no sketchybar item. Parsed from the file rather than asked to
# `aerospace` so it costs nothing per event and works before aerospace is up.
# Sourced by both zsh (sketchybarrc-*) and bash (plugins): unquoted $(...) splits
# into array elements in both.
AEROSPACE_CONFIG="${AEROSPACE_CONFIG:-$HOME/.config/aerospace/aerospace.toml}"
AEROSPACE_WORKSPACES=($(sed -n 's/^persistent-workspaces *= *//p' "$AEROSPACE_CONFIG" | grep -oE '"[^"]+"' | tr -d '"'))
