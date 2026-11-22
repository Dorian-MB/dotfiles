---
name: savvy-flow
description: Orchestrated delivery flow. The session model plans, owns design, delegates implementation to tiered worker subagents (savvy-fable / savvy-heavy / savvy-medium / savvy-light) and adversarially reviews their output. Invoke with /savvy-flow <task>.
disable-model-invocation: true
argument-hint: <task description>
---

# Savvy Flow

You are the **orchestrator**. You think, plan, decide, and review. Workers execute. Never do a worker's job yourself, and never let a worker do yours.

Task from the user: $ARGUMENTS

## 0. Preconditions

- The flow is designed for a strong orchestrator model at high effort (Fable high is the reference setup). Do not try to detect or verify the session's model or effort — you cannot see the effort level. Whatever the session runs on is the user's deliberate choice; just orchestrate.
- Worker agents must exist: `savvy-fable`, `savvy-heavy`, `savvy-medium`, `savvy-light` (in `~/.claude/agents/`, or shipped with the savvy-flow plugin, in which case the Agent tool lists them as `savvy-flow:savvy-heavy` and so on). If the Agent tool does not list them, stop and tell the user.

## Progress bar

If the tool `mcp__savvy-progress__progress` is among your tools, keep it current. In the main session it is usually deferred: load it once with ToolSearch (`select:mcp__savvy-progress__progress`); skip this section silently only if it is neither listed nor deferred. Call it:
- after presenting the plan: `title` (a few words), `total` (number of worker tasks), `tasks` (`[{ title, tier, after }]` in plan order; `tier` without the `savvy-` prefix, `after` the numbers of the tasks it waits for), `phase: "delegate"` (or `"design"` while following `design.md`);
- each time a task is accepted in review: `done` (accepted so far); switch `phase` to `"review"` while reviewing;
- if re-planning changes the tasks: the new `tasks` and `total`;
- once at close: `finished: true`.

When delegating, pass the task's `title` verbatim as the Agent tool's `description` (a return round reuses it too): the agents panel matches runs to planned tasks by it.

## 1. Understand and plan (orchestrator only)

1. Understand the request in context: CLAUDE.md, recent git history, and the files involved. Everything you read stays in the most expensive context for the whole flow, so read yourself only the few files you must judge; for anything wider (more than a handful of files, searching for where something lives, mapping a module) use an Explore subagent with `model: haiku` (`sonnet` if the code is subtle) and ask it for conclusions with paths and line ranges, not file dumps.
   - If the working directory has no project (empty, or no source/manifests/CLAUDE.md), this is a **new project**: read `greenfield.md` (next to this file) and follow it first, then continue here from step 3 using PLAN.md as the task list.
2. Decide whether the task **touches design** (any visible UI, layout, visual hierarchy, copy that users see, interaction flow, colors/typography/spacing). If yes → read `design.md` (next to this file) and follow it before any implementation.
3. Break the work into **tasks** with:
   - a clear, self-contained brief (what, where, constraints, definition of done, how to verify);
   - explicit dependencies between tasks;
   - a **tier** and a **model** per task (section 3).
4. Present the plan to the user in a compact form: numbered tasks, tier, model, dependency order. If any reading of the request would lead to materially different work, ask before delegating. Otherwise proceed.

## 3. Tiering and model choice

Each task gets two independent choices: a **tier** (the worker agent: its rules, report format and default effort) and a **model** (the ceiling of judgment). Pick the cheapest combination that gets the task right the first time: a failed round costs more than a stronger model.

| Tier | Agent | Default model / effort | Use for |
|------|-------|------------------------|---------|
| Fable | `savvy-fable` | Fable / high | "Hardest problems": very complex logic (subtle algorithms, concurrency, many interacting states), hard bugs that resist ordinary debugging or survived a Heavy investigation; targeted design features, only when the user asks (`design.md`) |
| Heavy | `savvy-heavy` | Opus / high | "Understand, find, and do it right": unfamiliar or messy code, unclear root cause, non-obvious architecture, large contexts, anything where a wrong first approach is expensive; also delicate execution of a clear approach: multi-file refactors, fixes that must preserve invariants, logic with many edge cases, concurrency |
| Medium | `savvy-medium` | Sonnet / medium | Standard feature work, bug fixes with a known cause, changes confined to a few files with clear requirements |
| Light | `savvy-light` | Haiku / medium | Mechanical edits, renames, boilerplate, config, small isolated fixes, running builds/tests and reporting |

**Model**: pass it as the Agent tool's `model` parameter, which overrides the agent's default; omit it to keep the default above. Choose per task, not per tier:

| Model | Cost | Good enough when |
|-------|------|------------------|
| `haiku` | lowest | the brief spells out every edit, or the task is run-and-report; no judgment calls |
| `sonnet` | low | ordinary code in a known pattern, clear requirements, a few files |
| `opus` | high | real judgment: unfamiliar code, delicate invariants, wide changes |
| `fable` | highest | only what Opus has failed at or clearly cannot do |

Heuristics:
- Start from the tier's default model. Move it down when the brief removes the difficulty (a precise Heavy-written brief can often be implemented on `sonnet`; a long but repetitive Heavy task may run on `sonnet`), up when the code is large or unfamiliar (a Light task in a huge unknown file may need `sonnet`).
- The user may constrain models in the task ("workers on sonnet", "no fable", "opus only"): that overrides the defaults and these heuristics. Without access to `fable`, use `opus` for the Fable tier.
- Uncertain between two tiers or two models → take the higher one. Exception: Fable (tier or model) is a reserve; pick it only when the task clearly meets its criteria, otherwise Heavy / `opus`.
- A task that needs both insight and a delicate implementation is two tasks: Heavy investigates and produces a precise brief, then Heavy (often on `sonnet`) or Medium implements it.
- A task that is mostly investigation with an unclear outcome is Heavy; split "investigate" and "implement" if the investigation result changes the plan.
- Never delegate final judgment (section 5) to any tier. Design is delegated only as `design.md` allows: to `savvy-fable`, on the user's explicit request.

## 4. Delegate

- Use the Agent tool with `subagent_type` = the tier agent name exactly as the Agent tool lists it (`savvy-heavy` or `savvy-flow:savvy-heavy`), and `model` = the model chosen in section 3 when it differs from the agent's default. Run independent tasks in parallel in one message; chain dependent ones.
- Each brief must be self-contained: the worker has no access to this conversation. Include the decided design specs, constraints from CLAUDE.md that matter, and the exact verification expected.
- Point the worker at the code precisely so it does not re-explore: file paths **with line ranges** and the names of the functions/types involved, as found during planning. Do not paste code into the brief: you would write it as expensive output tokens, and the worker reads it more cheaply itself.
- Keep briefs tight. Do not paste the whole plan; paste this task.
- Do not implement in parallel with workers. While they run, prepare the next briefs or the review checklist.

## 5. Adversarial review (orchestrator only)

Treat every worker report as a claim to be checked, not a fact.

For each returned task:
1. Read the actual changes, not just the report: start with `git diff --stat`, then read the diff of the files that matter (`git diff -- <path>`), not whole files. Open surrounding code only where the diff alone cannot settle a question.
2. Check against the brief: scope creep, missing parts, silent assumptions, design deviations.
3. Look for what a careful reviewer would catch: edge cases, error paths, broken invariants, regressions in neighbouring code, missing verification.
4. Re-check the verification when the report is vague or the task is risky, without pulling logs into your context: delegate the run to `savvy-light` (`model: haiku`; `sonnet` when a failure must be diagnosed, not just reported), with the exact commands, asking for pass/fail and only the failing lines. Run it yourself only when it is a single command with short output.
5. Outcome per task:
   - **Accept**;
   - **Return**: when the same tier and model stay right, continue the same worker with `SendMessage` (load it with ToolSearch `select:SendMessage` if it is deferred; its context is intact, so it does not re-read the code) and send only the precise list of defects. Spawn a new worker only to move to a higher tier or model (a defect from missing judgment means the model was too small); then the brief is self-contained again, plus the defect list. Never re-explain the whole task;
   - **Escalate**: take over only for design fixes or one-line corrections where a round trip would cost more than the fix.

Cap at two return rounds per task; after that, re-plan or ask the user.

## 6. Close

Report to the user in the session's usual style: what changed and where, what was verified, what was left out and why, follow-ups noticed but not touched. Mention which tiers and models ran, one line, no per-task narration.
