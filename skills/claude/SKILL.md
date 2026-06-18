---
name: claude
description: Use when the user types /claude or asks for a fresh Claude pass, an independent second opinion, or a clean-context review/research from Claude itself. Spawns a new headless Claude (`claude -p`) in the background — a separate context that isn't anchored to the current conversation — and reports back its verdict.
---

# claude — fresh-context Claude pass

Summon a **new headless Claude** as an independent reviewer. Because it runs in a clean context with no exposure to your current reasoning, it's a genuine second pass — useful for catching things the in-session model has talked itself into. Use when the user writes `/claude "..."`, asks for a fresh Claude opinion, or when you want to sanity-check your own plan/diff without your own bias.

## Prerequisites

- `claude` CLI (Claude Code) installed and authenticated (`claude --version`).

## Default command

Run from the relevant workspace root. `-p` is non-interactive (no prompts); `--permission-mode plan` keeps it **read-only** — it reads and reasons over the repo but won't edit files, the right default for a review/research pass:

```bash
claude -p "<prompt>" --permission-mode plan --output-format text > /tmp/claude-<tag>.md 2>&1
```

- Pick a unique `<tag>` per call (a short topic slug).
- `--model <model>` to pick a specific Claude (e.g. `opus`, `sonnet`, `haiku`). For a true second opinion, consider a *different* model than the one you're running. Omit to use the configured default.
- `--add-dir <path>` to grant read access to extra directories; it otherwise works from the current directory.
- For a pure conceptual question that needs no repo access, you can drop `--permission-mode plan`.
- To let the fresh Claude actually make changes (rare, opt-in), use `--permission-mode acceptEdits` instead — only when the user explicitly asks.

## Execution (background + wait)

A real review can take a while, so run it in the background and wait — don't block the turn:

- **Claude Code:** Bash tool with `run_in_background: true`; you're re-invoked on exit, then read `/tmp/claude-<tag>.md`.
- **Other agents / plain shell:** background it (`... &`) and wait for exit, or run foreground with a generous timeout.

`--output-format text` writes the final answer straight to the file. (Use `--output-format json` and read `.result` if you want structured metadata.)

## Prompt shape

Give the fresh Claude everything it needs, since it has none of this conversation's context:
- the workspace path and task context;
- the idea / design / plan / diff to challenge, stated plainly;
- the exact question and focus areas (correctness, regressions, hidden assumptions, simpler alternatives, tests, production risk);
- the output shape: verdict, agreements/disagreements, blocking vs non-blocking, concrete fixes.

Ask it to challenge your approach, not rubber-stamp it.

## After it answers

Reconcile its response against the actual code before acting — it's a second opinion from a blank slate, not ground truth. Summarize the verdict and say which points you accept or reject, and why.
