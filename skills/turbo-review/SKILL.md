---
name: turbo-review
description: Use when the user types /turbo-review or asks to convene multiple external models at once for a task, research, or review — a "quorum" pass. Fans the same prompt out to codex, opencode, and a fresh claude in parallel (read-only, in the background), then synthesizes their verdicts — flagging consensus (high confidence) and disagreement (needs scrutiny). Use proactively before committing to a risky design, plan, or diff.
---

# turbo-review — convene the quorum

Run **all available external models at once** and synthesize them into one answer. Instead of asking a single outside model, fan the same task out to `codex` (GPT-5.5), `opencode` (DeepSeek/Kimi/Qwen), and a fresh `claude` in parallel, then reconcile their verdicts. Where they agree, you have high confidence; where they disagree, you have a precise list of things to scrutinize.

Use for: pressure-testing a **design/plan**, **reviewing a diff** before merge, or a **research** question worth more than one model's view. Triggered by `/turbo-review "..."`, "convene the quorum", "ask everyone", "запусти всех", or proactively before a costly/irreversible decision.

This skill composes the sibling skills `codex`, `opencode`, and `claude` — see each for per-CLI flag details.

## Principle: external models are read-only; the host writes

The external CLIs run **read-only** — they review, research, and propose, but never touch files. You (the host agent) synthesize their input and make any edits yourself. This keeps the diff coherent and conflict-free, and it's portable across host agents. Grant an external model write access only if the user explicitly asks (`-s workspace-write` for codex, `--permission-mode acceptEdits` for claude) — and then to only one of them.

## Workflow

### 1. Frame one shared prompt
Write a single, self-contained prompt every model will receive. Include:
- workspace path and task context;
- the design / plan / diff / question, stated plainly (paste the diff or point to the files);
- focus areas (correctness, regressions, hidden assumptions, simpler alternatives, tests, prod/infra risk);
- the output shape: **verdict, agreements/disagreements, blocking vs non-blocking issues, concrete fixes**.

### 2. Fan out in parallel (background)
Launch every available CLI at once, each writing to its own file. Skip any CLI that isn't installed — degrade gracefully (two views still beat one). Use a shared `<tag>` for the run:

```bash
# codex — GPT-5.5, read-only
codex exec -s read-only -o /tmp/quorum-<tag>-codex.md "<prompt>" > /tmp/quorum-<tag>-codex.log 2>&1 &

# opencode — free opencode Zen model by default (swap to a premium one you've configured)
opencode run "<prompt>" --model "opencode/deepseek-v4-flash-free" > /tmp/quorum-<tag>-opencode.log 2>&1 &

# claude — fresh headless context, read-only (plan mode)
claude -p "<prompt>" --permission-mode plan --output-format text > /tmp/quorum-<tag>-claude.md 2>&1 &

wait   # block until all of them finish
```

- **Claude Code:** prefer launching each as a separate Bash call with `run_in_background: true` so you're re-invoked as each finishes; then read each output file. The `&` … `wait` form above is the portable plain-shell equivalent for any host.
- Pick a unique `<tag>` per run. Each model can take minutes — running them concurrently makes the wall-clock the slowest single model, not the sum.

### 3. Collect
Read every output file:
- codex → `/tmp/quorum-<tag>-codex.md` (verdict) / `.log` (if it failed)
- opencode → `/tmp/quorum-<tag>-opencode.log` (verdict is at the end)
- claude → `/tmp/quorum-<tag>-claude.md`

### 4. Synthesize
Produce one consolidated answer:
- **Consensus** — points two or more models independently raise → high-confidence, act on these first.
- **Disagreements / unique findings** — surface them explicitly; this is where the quorum earns its keep. Adjudicate each against the actual code.
- **Reconcile against ground truth** — the models are outside opinions, not facts. Verify their claims against the real files before acting.
- Present: a clear verdict, the blocking issues, the non-blocking nits, and the concrete next actions. Attribute a point to a model when it matters.

### 5. Act
You (the host) implement the agreed changes. The external models stay read-only.

## Modes
- **Review** — paste/point at the diff; ask each model to find bugs, regressions, and risks before merge.
- **Research** — pose the open question; ask each model to investigate and recommend, with reasoning. Synthesize into one answer.
- **Task** — ask each model for its approach/plan; pick the strongest, graft the best ideas from the others, then implement it yourself.

## Notes
- The host agent itself counts as a vote — you needn't also run the CLI matching your own engine for independence. Running inside Claude Code, the `claude` pass is a fresh-context check rather than a different model; still useful, but `codex` + `opencode` add the most diversity.
- Always report which models actually ran, so a degraded run (a CLI was missing) isn't mistaken for full consensus.
