#!/usr/bin/env bash
# Usage: extract.sh <YYYY-MM-DD> <out_dir>
# Writes one text file per Claude Code session active that day (user prompts + assistant text only,
# no tools/thinking), and prints "<size> <path>" for each. Streams with jq: low RAM (WSL 4 GB).
set -euo pipefail
day=$1 out=$2
mkdir -p "$out"
find ~/.claude/projects -maxdepth 2 -name '*.jsonl' -newermt "$day" | while read -r f; do
    proj=$(basename "$(dirname "$f")" | sed 's/^-home-[^-]*-//')
    dst="$out/${proj}__$(basename "$f" .jsonl).txt"
    jq -r --arg d "$day" '
        select((.type == "user" or .type == "assistant") and (.isSidechain | not) and .timestamp != null)
        | select((.timestamp[:19] + "Z" | fromdateiso8601 | strflocaltime("%F")) == $d)
        | (.message.content | if type == "string" then . else map(select(.type == "text") .text) | join("\n") end) as $t
        | select($t != "" and ($t | test("^<(local-command|command-|system-reminder|task-notification)") | not))
        | "[\(.type)] \($t[:1500])"' "$f" >"$dst" 2>/dev/null || true
    [[ -s $dst ]] && echo "$(stat -c %s "$dst") $dst" || rm -f "$dst"
done
