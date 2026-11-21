#!/bin/bash
# Usage: handoff.sh <task-file> [--savvy]   open a fresh session that executes the task file
#        handoff.sh --clear [slug]          delete one task file (default: the most recent)
#        handoff.sh --clear-all             delete every task file of this project
set -euo pipefail
dir=.claude/tasks

case "${1:-}" in
  --clear-all)
    shopt -s nullglob; files=("$dir"/*.md)
    [ ${#files[@]} -gt 0 ] || { echo "handoff: aucun fichier de tâche dans $dir"; exit 0; }
    rm -- "${files[@]}"; printf 'handoff: supprimé %s\n' "${files[@]}"; exit 0 ;;
  --clear)
    if [ -n "${2:-}" ]; then file="$dir/$(basename "$2" .md).md"
    else file=$(ls -t "$dir"/*.md 2>/dev/null | head -1 || true); fi
    [ -n "$file" ] && [ -f "$file" ] || { echo "handoff: aucun fichier de tâche à supprimer (${2:-le plus récent})" >&2; exit 1; }
    rm -- "$file"; echo "handoff: supprimé $file"; exit 0 ;;
esac

file=${1:?usage: handoff.sh <task-file> [--savvy] | --clear [slug] | --clear-all}
mode=${2:-}
[ -f "$file" ] || { echo "handoff: task file not found: $file" >&2; exit 1; }
rel=${file#"$PWD"/}
slug=$(basename "$file" .md)

prompt="Lis $rel et exécute la tâche qu'il décrit."
[ "$mode" = "--savvy" ] && prompt="/savvy-flow $prompt"

if [ "${HERDR_ENV:-}" = 1 ] && command -v herdr >/dev/null; then
  pane=$(herdr tab create --cwd "$PWD" --label "$slug" --focus | jq -r '.result.root_pane.pane_id // empty')
  [ -n "$pane" ] || { echo "handoff: herdr tab create failed" >&2; exit 1; }
  # herdr types the command into the shell as one line: quote it ourselves
  herdr pane run "$pane" "$(printf '%q ' claude "$prompt")" >/dev/null
  echo "handoff: onglet '$slug' ouvert (pane $pane)"
else
  claude --bg "$prompt"
  echo "handoff: session en arrière-plan. Rejoindre : claude attach <id ci-dessus>"
fi
