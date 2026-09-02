#!/bin/bash

# Drives the aerospace.workspace.* sketchybar items:
#   - shows a workspace only if it has at least one open window, or is the
#     currently focused workspace ("open"/"close" happens automatically)
#   - shows up to 3 app icons per workspace so you can see what's inside
#   - left-clicking a workspace focuses it in AeroSpace
#
# Called two ways:
#   1. Fast path, from aerospace.toml's exec-on-workspace-change, with
#      FOCUSED_WORKSPACE/PREV_WORKSPACE env vars set: just swaps the
#      highlight colors, no `aerospace` CLI calls at all.
#   2. Full path, from sketchybar's aerospace_workspace_change/
#      front_app_switched events: recomputes which workspaces are occupied
#      and their app icons.

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/workspaces.sh"

# need to add this to yout aerospace.toml :
# exec-on-workspace-change = ['/bin/bash', '-c', 'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE']
# ─── Fast path: workspace switch (color-only update) ─────────────────────────
if [ -n "$FOCUSED_WORKSPACE" ] && [ -n "$PREV_WORKSPACE" ] \
   && [ "$FOCUSED_WORKSPACE" != "$PREV_WORKSPACE" ]; then
  sketchybar --animate sin 8 \
    --set aerospace.workspace.$PREV_WORKSPACE \
      background.color=$CAT_SURFACE1 \
      icon.color=$CAT_TEXT \
      label.color=$CAT_TEXT \
    --set aerospace.workspace.$FOCUSED_WORKSPACE \
      background.color=$CAT_GREEN \
      icon.color=$CAT_BASE \
      label.color=$CAT_BASE
fi

# ─── Full path: recompute occupancy + app icons ───────────────────────────────
source "$CONFIG_DIR/helpers/icon_map.sh"

CURRENT_WORKSPACE="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
[ -z "$CURRENT_WORKSPACE" ] && exit 0

# One aerospace call gets every window across every workspace.
ALL_WINDOWS=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null)

args=(--animate sin 8)

for ws in "${AEROSPACE_WORKSPACES[@]}"; do
  APPS=$(printf '%s\n' "$ALL_WINDOWS" | awk -F'|' -v w="$ws" '$1==w {print $2}')

  if [ -n "$APPS" ] || [ "$ws" = "$CURRENT_WORKSPACE" ]; then
    ICON_STRIP=""
    APP_COUNT=0
    while IFS= read -r APP; do
      [ -z "$APP" ] && continue
      APP_COUNT=$((APP_COUNT + 1))
      [ $APP_COUNT -gt 3 ] && break
      __icon_map "$APP"
      if [ -n "$icon_result" ] && [ "$icon_result" != ":default:" ]; then
        ICON_STRIP="${ICON_STRIP}${icon_result} "
      fi
    done <<< "$APPS"

    ICON_STRIP="${ICON_STRIP% }"
    [ -z "$ICON_STRIP" ] && ICON_STRIP="$ws"

    if [ "$ws" = "$CURRENT_WORKSPACE" ]; then
      BG_COLOR=$CAT_GREEN; TEXT_COLOR=$CAT_BASE
    else
      BG_COLOR=$CAT_SURFACE1; TEXT_COLOR=$CAT_TEXT
    fi

    args+=(
      --set aerospace.workspace.$ws drawing=on
      --set aerospace.workspace.$ws icon="$ICON_STRIP"
      --set aerospace.workspace.$ws icon.color="$TEXT_COLOR"
      --set aerospace.workspace.$ws label="$ws"
      --set aerospace.workspace.$ws label.color="$TEXT_COLOR"
      --set aerospace.workspace.$ws background.color="$BG_COLOR"
    )
  else
    args+=(--set aerospace.workspace.$ws drawing=off)
  fi
done

sketchybar "${args[@]}" 2>/dev/null
