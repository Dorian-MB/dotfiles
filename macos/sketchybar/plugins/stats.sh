#!/usr/bin/env bash

# Shared by the laptop and desktop bars. $1 is the metric (cpu, gpu or ram) and
# $2 the property carrying the load color:
#   laptop  -> icon.color        (accent on the icon, dark pill)
#   desktop -> background.color  (accent on the whole pill)
METRIC="$1"
ACCENT_PROP="${2:-icon.color}"

source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"

case "$METRIC" in
cpu)
    # ps instead of top: top needs two samples, so 1s and far more CPU per run.
    # %cpu is a decaying average, summed over all cores.
    PERCENT=$(ps -A -o %cpu= | LC_ALL=C awk -v cores="$(sysctl -n hw.logicalcpu)" \
        '{ sum += $1 } END { p = sum / cores; printf "%.0f", (p > 100 ? 100 : p) }')
    LABEL="${PERCENT}%"
    ;;
gpu)
    PERCENT=$(ioreg -r -d 1 -c IOAccelerator |
        grep -o -E '"Device Utilization %"=[0-9]+' | head -1 | cut -d= -f2)
    LABEL="${PERCENT}%"
    ;;
ram)
    # Same formula as "Memory Used" in Activity Monitor:
    # app memory + wired + compressed.
    read -r LABEL PERCENT < <(vm_stat | LC_ALL=C awk -v total="$(sysctl -n hw.memsize)" '
        /page size of/         { page = $8 }
        /^Anonymous pages/     { anon = $3 }
        /^Pages purgeable/     { purgeable = $3 }
        /^Pages wired down/    { wired = $4 }
        /occupied by compressor/ { compressed = $5 }
        END {
            used = (anon - purgeable + wired + compressed) * page
            printf "%.1fG %.0f", used / 1024 ^ 3, used * 100 / total
        }')
    ;;
esac

if [ -z "$PERCENT" ]; then
    exit 0
fi

if [ "$PERCENT" -ge 85 ]; then
    COLOR=$CAT_RED
elif [ "$PERCENT" -ge 60 ]; then
    COLOR=$CAT_YELLOW
else
    COLOR=$CAT_GREEN
fi

sketchybar --set $NAME label="$LABEL" "$ACCENT_PROP"=$COLOR
