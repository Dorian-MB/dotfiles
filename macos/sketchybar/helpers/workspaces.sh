#!/bin/bash

# Single source of truth for the list of AeroSpace workspaces sketchybar
# should know about. Keep this in sync with the `workspace X` bindings in
# aerospace.toml. A workspace not in this list will never get a sketchybar
# item, even if you switch to it in AeroSpace.
export AEROSPACE_WORKSPACES=(1 2 3 4 A C E Q S Z)
