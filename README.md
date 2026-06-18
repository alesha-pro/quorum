<p align="center">
  <img src="assets/quorum-banner.png" alt="Quorum — convene a quorum of AI models from your terminal" width="100%">
</p>

# Quorum

**Convene a quorum of AI models from your terminal.** A set of portable [Agent Skills](https://opencode.ai/docs/skills/) that let any coding agent summon *other* AI CLIs — OpenAI **Codex**, **opencode** (DeepSeek / Kimi / Qwen), and a fresh **Claude** — as an independent panel for review, research, and hard calls. Plus **`turbo-review`**: one command that runs them all at once and synthesizes the verdicts.

> Where the models agree, you have high confidence. Where they disagree, you get a precise list of things to look at.

## Why

A single model — even a great one — has blind spots and talks itself into things. A second opinion from a *different* model, in a *clean context*, catches what the in-session model glossed over. Quorum makes that one keystroke, and `turbo-review` turns it into a panel vote.

## The skills

| Skill | What it does | Backing CLI |
|---|---|---|
| `codex` | Independent second opinion / review from GPT‑5.5 | `codex exec` |
| `opencode` | External review or research pass | `opencode run` (DeepSeek / Kimi / Qwen) |
| `claude` | Fresh-context Claude pass — a clean-slate second look | `claude -p` |
| **`turbo-review`** | **Flagship.** Fans the task out to all available models in parallel, then synthesizes consensus vs. disagreement | all of them |
| `codex-imagegen` | *(supplementary)* Generate image assets via Codex's native imagegen | `codex exec` |

External passes are **read-only** by default: they review, research and propose; your host agent synthesizes and makes the edits. The diff stays coherent, and nothing is touched without you.

## Requirements

Each skill needs its CLI on your `PATH` — install only the ones you want; `turbo-review` uses whichever are present and skips the rest.

- [`codex`](https://developers.openai.com/codex) — for `codex` and `codex-imagegen`
- [`opencode`](https://opencode.ai) — for `opencode` (free models built in, or bring your own provider)
- [`claude`](https://claude.com/claude-code) — for `claude`

## Install

These are standard Agent Skills (`SKILL.md` folders), so they work in **Claude Code**, **Codex**, and **opencode** alike.

### Quick install (all agents)

```bash
git clone https://github.com/alesha-pro/quorum
cd quorum
./install.sh
```

`install.sh` symlinks each skill into the shared `~/.agents/skills` directory (read by all three agents) plus the native skills dir of every agent it detects. Restart your agent — or start a new session — afterwards. Undo any time with `./install.sh --uninstall`.

### Manual install

Symlink (or copy) the skill folders into your agent's skills directory:

| Agent | Skills directory |
|---|---|
| Claude Code | `~/.claude/skills/` |
| OpenAI Codex | `~/.agents/skills/` or `~/.codex/skills/` |
| opencode | `~/.config/opencode/skills/` (also reads `~/.agents/skills/`) |

```bash
ln -s "$PWD/skills/turbo-review" ~/.claude/skills/turbo-review
```

### Claude Code plugin

Prefer the plugin manager? This repo is also a Claude Code marketplace:

```text
/plugin marketplace add alesha-pro/quorum
/plugin install quorum@quorum
```

Installed via the plugin, the skills are namespaced (`/quorum:turbo-review`, `/quorum:codex`, …). Installed as loose skills, they're bare (`/turbo-review`, `/codex`, …).

## Use

```text
/turbo-review   "review my staged diff before I merge — correctness, regressions, prod risk"
/codex          "challenge this migration plan: <plan>"
/opencode       "research the trade-offs of X vs Y for our use case"
/claude         "fresh-eyes pass on this design — what am I missing?"
/codex-imagegen "a 32x32 transparent pixel-art coin sprite → ./assets/coin.png"
```

Your agent will also reach for these on its own — running `turbo-review` before a risky change, or asking `codex` to pressure-test a plan — because that's what the skill descriptions tell it to do.

## Configuration

- **opencode model** — defaults to the **free** `opencode/deepseek-v4-flash-free` (opencode Zen, no API key). Run `opencode models` to see what's available to you and pass `--model` for a stronger one you've configured; details in [`skills/opencode/SKILL.md`](skills/opencode/SKILL.md).
- **codex model** — defaults to your Codex config (e.g. `gpt-5.5`, `xhigh`). Override per call with `-m`.
- **claude model** — defaults to your Claude Code config; pick a specific one with `--model`.

## Compatibility

| | Claude Code | Codex | opencode |
|---|:---:|:---:|:---:|
| Loads `SKILL.md` skills | ✅ | ✅ | ✅ |
| Quick install via `install.sh` | ✅ | ✅ | ✅ |
| Plugin marketplace | ✅ | — | — |

## License

MIT © alesha-pro
