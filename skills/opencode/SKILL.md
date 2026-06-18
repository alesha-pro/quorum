---
name: opencode
description: Use when the user types /opencode or asks to run opencode for an external review, research pass, or second opinion. Runs the opencode CLI non-interactively in the background and reports back its verdict. Defaults to a strong reasoning model and supports alternates on request.
---

# opencode — external pass

Summon a fresh **opencode CLI** run as an independent outside model for a review, research pass, or second opinion. Use when the user writes `/opencode "..."` or asks to involve opencode.

## Prerequisites

- `opencode` CLI installed (`opencode --version`).
- The default below uses opencode's **free** `opencode/deepseek-v4-flash-free` (the opencode Zen free tier) — no API key, just `opencode auth login`. Swap in any model you have configured — see [Model selection](#model-selection).

## Default command

Run from the relevant workspace root:

```bash
opencode run "<prompt>" --model "opencode/deepseek-v4-flash-free" > /tmp/opencode-<tag>.log 2>&1
```

- Pick a unique `<tag>` per call (a short topic slug).
- opencode streams tool usage before its final verdict — the final answer is at the **end** of the log. Read the whole file but report the concluding verdict.
- `--dir <path>` to root opencode elsewhere; `--format json` for machine-readable events.

### Model selection

Run `opencode models` to list everything available to you, then pass `--model "<provider>/<model>"`.

**Free (opencode Zen — no API key):**
- `opencode/deepseek-v4-flash-free` — DeepSeek V4 Flash (the default)
- alternatives: `opencode/nemotron-3-ultra-free`, `opencode/mimo-v2.5-free`, `opencode/north-mini-code-free`

**Premium (needs your own provider auth via `opencode auth login`)** — stronger; the author's picks:
- DeepSeek: `--model "deepseek/deepseek-v4-pro" --variant "max"`
- Kimi: `--model "moonshot/kimi-k2.7-code" --variant "max"`
- Qwen: `--model "qwen/qwen3.6-plus" --variant "max"`

`--variant "max"` only applies to providers that support variants — drop it for the free models.

## Execution (background + wait)

The external model can take a while, so run it in the background and wait — don't block the turn:

- **Claude Code:** Bash tool with `run_in_background: true`; you're re-invoked on exit, then read `/tmp/opencode-<tag>.log`.
- **Other agents / plain shell:** background it (`... &`) and wait for exit, or run foreground with a generous timeout.

Don't treat partial streamed output as final — wait for the process to exit, then summarize the concluding answer.

## Prompt shape

Include:
- repo/workspace path and current task context;
- whether the request is read-only or may edit files (default read-only unless the user explicitly asks opencode to implement changes);
- focus areas: correctness, regressions, tests, infra risk, production behavior, or the research questions;
- requested output shape: verdict, blocking issues, non-blocking issues, recommended fixes.

## After it answers

Check important findings against local code before recommending changes. Summarize the verdict, noting where you agree or disagree.
