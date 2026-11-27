---
name: cra
description: Compte rendu d'activité - résume en 10 points max le travail fait dans les conversations Claude Code du jour (ou de la veille). Invoke with /cra [hier|YYYY-MM-DD].
disable-model-invocation: true
argument-hint: "[hier|YYYY-MM-DD]"
---

# CRA

Arguments: $ARGUMENTS

1. **Date.** Empty → today (`date +%F`). `hier`, `veille` or `yesterday` → `date -d yesterday +%F`. A `YYYY-MM-DD` → that day.
2. **Extract.** Run `bash ~/.claude/skills/cra/extract.sh <date> <scratchpad>/cra-<date>` (scratchpad directory from your
   environment). It prints `<size> <path>` per session of that day: user prompts and assistant text only. Nothing
   printed → say there is no conversation that day and stop. Do not read the files yourself.
3. **Summarize with Haiku.** In one message, spawn one Agent per file (`subagent_type: general-purpose`,
   `model: haiku`); if there are more than 8 files, group the smallest ones so there are at most 8 agents. Prompt:
   > Lis <path(s)>. C'est l'extrait d'une ou plusieurs conversations entre un développeur et Claude Code. Le nom du
   > fichier, avant `__`, est le projet. Réponds en 2 à 4 lignes en français : ce qui a été fait ou décidé concrètement
   > (pas les questions sans suite, pas les résumés de journée déjà produits par /cra). Ni secret, ni IP, ni identifiant.
   > Si rien de concret, réponds « rien ».

   Wait for all of them (Yield).
4. **Write the CRA** from their answers only, in French:
   - at most 10 bullet points, about 15 words each;
   - passive voice, no subject pronoun (« Les données ont été analysées… », never « Il a analysé… »), neutral tone,
     general: no file names, commands, IPs or identifiers;
   - merge related work, drop « rien », order by importance;
   - title line: `Compte rendu du <JJ/MM>`.

   Output only that list, then one line saying it comes from the Claude Code conversations only.
