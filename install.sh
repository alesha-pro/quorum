#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Quorum installer — symlink the skills into your agents' skill directories.

Usage:
  ./install.sh              Detect installed agents and link all skills (idempotent)
  ./install.sh --uninstall  Remove symlinks that point back into this repo
  ./install.sh --help       Show this help

Links into the shared ~/.agents/skills (read by Claude Code, Codex and opencode)
plus each detected agent's native skills dir. Restart the agent afterwards.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SRC="$SCRIPT_DIR/skills"

UNINSTALL=0
case "${1:-}" in
  --uninstall|-u) UNINSTALL=1 ;;
  --help|-h) usage; exit 0 ;;
  "") ;;
  *) echo "unknown arg: $1" >&2; usage; exit 2 ;;
esac

[ -d "$SRC" ] || { echo "error: no skills/ directory at $SRC" >&2; exit 1; }

# Candidate skill dirs. The shared ~/.agents/skills is read by Claude Code,
# Codex and opencode; the rest are each agent's native fallback.
targets=("$HOME/.agents/skills")
if command -v claude   >/dev/null 2>&1; then targets+=("$HOME/.claude/skills"); fi
if command -v codex    >/dev/null 2>&1; then targets+=("$HOME/.codex/skills"); fi
if command -v opencode >/dev/null 2>&1; then targets+=("$HOME/.config/opencode/skills"); fi

# Canonicalize a (possibly symlinked) directory path; empty if it doesn't exist.
canonical() { (cd "$1" 2>/dev/null && pwd -P) || true; }

seen=" "
for t in "${targets[@]}"; do
  mkdir -p "$t"
  real="$(canonical "$t")"
  # de-dupe: ~/.claude/skills is commonly a symlink to ~/.agents/skills
  case "$seen" in *" $real "*) continue ;; esac
  seen="$seen$real "

  echo "→ $t"
  for skill in "$SRC"/*/; do
    [ -f "$skill/SKILL.md" ] || continue
    skill="${skill%/}"
    name="$(basename "$skill")"
    dest="$t/$name"

    if [ "$UNINSTALL" = 1 ]; then
      if [ -L "$dest" ] && [ "$(canonical "$dest")" = "$(canonical "$skill")" ]; then
        rm "$dest" && echo "  removed $name"
      fi
      continue
    fi

    if [ -L "$dest" ]; then
      ln -sfn "$skill" "$dest" && echo "  linked  $name"
    elif [ -e "$dest" ]; then
      echo "  skipped $name (exists and is not a symlink — left untouched)"
    else
      ln -s "$skill" "$dest" && echo "  linked  $name"
    fi
  done
done

echo
if [ "$UNINSTALL" = 1 ]; then
  echo "Uninstalled. Restart your agent (or start a new session)."
else
  cat <<'EOF'
Done. Restart your agent (or start a new session) so it rescans skills.

Try it:
  /turbo-review "review my staged diff before I merge"
  /codex        "challenge this plan: ..."
  /opencode     "research: ..."
  /claude       "fresh-eyes pass on this design: ..."
EOF
fi
