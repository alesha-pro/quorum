---
name: codex
description: Use when the user types /codex or asks for an external review, second opinion, sanity-check, or "ask codex" (RU «спроси codex», «внешнее мнение», «ревью от codex»). Also use proactively to pressure-test your own ideas, designs, plans, or diffs with an independent outside model before committing to them. Runs the codex CLI non-interactively in the background via `codex exec` and reports back its verdict.
---

# codex — external second opinion

Summon a fresh **Codex CLI** (OpenAI) as an independent outside model to challenge an idea, design, plan, or diff before acting on it. Use when the user writes `/codex "..."`, asks to involve codex, or whenever you want a second opinion that isn't anchored to your own reasoning.

## Prerequisites

- `codex` CLI installed and authenticated (`codex --version`).
- The default model is whatever the user's Codex config selects (e.g. `gpt-5.5`, `xhigh` reasoning) — strong for review. Do **not** override the model unless asked.

## Default command

Run from the relevant workspace root. Capture the clean final answer with `-o`; stdout also carries hook noise and a token-usage line, so never parse stdout for the answer:

```bash
codex exec -s read-only -o /tmp/codex-<tag>.md "<prompt>" > /tmp/codex-<tag>.log 2>&1
```

- Pick a unique `<tag>` per call (a short topic slug).
- `-s read-only` lets codex read the repo to ground its opinion but never modifies files — the right default for a review / second-opinion pass.
- `--skip-git-repo-check` if the workspace is not a git repo.
- `-C <dir>` to root codex somewhere other than the current directory.
- `-m <model>` to override the model — only on request.

## Execution (background + wait)

Codex with high reasoning takes minutes on a real review, so run it in the background and wait for it to finish — don't block the turn:

- **Claude Code:** launch via the Bash tool with `run_in_background: true`; you're re-invoked on exit. Then read `/tmp/codex-<tag>.md` for the verdict, and `/tmp/codex-<tag>.log` if it failed (non-zero exit or empty answer file).
- **Other agents / plain shell:** background it (`... &`) and wait for the process to exit, or run in the foreground with a generous timeout (codex is non-interactive and won't prompt).

Never treat streamed/partial stdout as the final answer — wait for exit and read the `-o` file.

## Prompt shape

Give codex enough to form an independent view:
- the workspace path and task context;
- the idea / design / plan / diff you want challenged, stated plainly;
- the exact question and focus areas (correctness, regressions, hidden assumptions, simpler alternatives, infra/production risk, tests);
- the output shape you want: verdict, where it agrees/disagrees, blocking vs non-blocking issues, concrete fixes.

Ask codex to **challenge** the idea and surface flaws and alternatives — the goal is an outside perspective, not validation. Default to read-only; use `-s workspace-write` only if the user explicitly wants codex to implement changes.

## After it answers

Reconcile codex's response against the actual code and facts before acting — it's an external opinion, not ground truth. Summarize the verdict and state plainly which points you agree with, which you reject, and why.
