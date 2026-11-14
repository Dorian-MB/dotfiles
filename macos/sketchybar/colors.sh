#!/bin/bash

# Catppuccin Macchiato tones. Single source of truth for every color used by
# the bar: sketchybarrc-*, plugins/* and plugins-laptop/* all source this file
# instead of hardcoding hex values.

# --- Surfaces ---------------------------------------------------------------
export CAT_BASE=0xff24273a       # dark text/icon on an accent-colored pill
export CAT_TEXT=0xffcad3f5       # light text/icon on a dark pill
export CAT_SURFACE1=0x99494d64   # unfocused-but-occupied workspace pill
export CAT_ITEM_BG=0x9924273a    # default item background
export CAT_BAR_BG=0x30000000     # bar background (laptop)
export CAT_BAR_BG_ALT=0x40000000 # bar background (desktop)
export CAT_CLEAR=0x00000000      # fully transparent
export CAT_WHITE=0xffffffff

# --- Accents ----------------------------------------------------------------
export CAT_GREEN=0xffa6da95      # focused workspace / front_app accent
export CAT_PEACH=0xfff5a97f      # logo / accent pill
export CAT_YELLOW=0xffeed49f     # warning / paused / charging
export CAT_RED=0xffed8796        # clock / critical battery
export CAT_MAROON=0xffee99a0     # low battery
export CAT_BLUE=0xff8aadf4       # volume
