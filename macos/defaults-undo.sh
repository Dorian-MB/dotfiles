#!/usr/bin/env bash
# Revert everything defaults.sh sets, back to the macOS defaults.
exec "$(dirname "$0")/defaults.sh" --undo
