---
name: handoff
description: Hand a task off to a fresh Claude Code session in a new terminal tab, with only the context from this conversation that the task needs. Invoke with /handoff [--savvy] <task>.
disable-model-invocation: true
argument-hint: "[--savvy] <task> | --clear [slug] | --clear-all"
---

# Handoff

Arguments: $ARGUMENTS

**Cleanup modes** (no task file is written, nothing is launched): if the arguments start with `--clear-all`, run `bash ~/.claude/skills/handoff/handoff.sh --clear-all`; if they start with `--clear`, run `bash ~/.claude/skills/handoff/handoff.sh --clear [slug]` (the slug only if the user gave one; without it the most recent task file is deleted). Report the output in one line and stop.

The goal is cost: the new session starts with a tiny context instead of this whole conversation. Keep your own work here minimal.

1. **Parse.** If the arguments contain the token `--savvy`, remove it: mode is savvy. The rest, verbatim, is the task. If the task is empty, ask the user for it and stop.
2. **Write the task file** at `.claude/tasks/<slug>.md` in the current working directory (`<slug>`: 2-5 kebab-case words from the task; if the file exists, append `-2`, `-3`...). Content:

   ```markdown
   # Tâche
   <the task, verbatim, not rephrased>

   # Contexte utile
   - ...
   ```

   The `# Contexte utile` section holds **only facts from this conversation that the task needs** and that the new session could not cheaply rediscover: decisions taken and why, files with line ranges and function names, constraints the user stated, options already rejected, verification expected. If the task continues work already started here, add one bullet `Fait : … / Reste : …`. No summary of the conversation, nothing generic, nothing already in CLAUDE.md, no code pasted, nothing invented. Do not copy plans, specs, issues, commits or diffs: reference them by path, hash or URL. Never write secrets (API keys, tokens, passwords) or personal data: say where they live instead. Under ~300 words.
   **If nothing in this conversation is useful for the task, omit the whole section**: the file then holds only `# Tâche`.
3. **Launch** right away, without asking for confirmation: `bash ~/.claude/skills/handoff/handoff.sh .claude/tasks/<slug>.md` followed by `--savvy` in savvy mode. Report the task file path and the script output in one line each. Do not start the task yourself.
