#!/usr/bin/env bash

# Battery is here bcause the ICON_COLOR doesn't play well with all background colors

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
    exit 0
fi

case ${PERCENTAGE} in
[8-9][0-9] | 100)
    ICON=""
    ICON_COLOR=$CAT_GREEN
    ;;
7[0-9])
    ICON=""
    ICON_COLOR=$CAT_YELLOW
    ;;
[4-6][0-9])
    ICON=""
    ICON_COLOR=$CAT_PEACH
    ;;
[1-3][0-9])
    ICON=""
    ICON_COLOR=$CAT_MAROON
    ;;
[0-9])
    ICON=""
    ICON_COLOR=$CAT_RED
    ;;
esac

if [ -n "$CHARGING" ]; then
    ICON=""
    ICON_COLOR=$CAT_YELLOW
fi

sketchybar --set $NAME \
    icon=$ICON \
    label="${PERCENTAGE}%" \
    icon.color=${ICON_COLOR}
