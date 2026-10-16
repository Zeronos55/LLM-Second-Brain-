#!/usr/bin/env bash
# Vault SessionStart hook (read-only). Copied into <vault>/.claude/hooks/ by scripts/sync-vault.sh;
# edit it in the planning repo, never in the vault.
#
# Warns when the vault's CLAUDE.md or agents differ from the planning repo, so an agent
# never runs on a stale copy without anyone noticing. It only reports; syncing is done
# from a repo session ("sync the vault").
#
# Repo path: $LLM_REPO, else /d/LLM-repo (Git Bash), else D:/LLM-repo.
vault="${CLAUDE_PROJECT_DIR:-$(pwd)}"

repo="${LLM_REPO:-}"
if [ -z "$repo" ]; then
  for c in /d/LLM-repo D:/LLM-repo; do [ -d "$c" ] && repo="$c" && break; done
fi

json_escape() { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk '{printf "%s\\n", $0}'; }
say() {   # shown to the user and given to Claude as context
  local text; text=$(printf '%s' "$1" | tr -d '\r' | json_escape)
  printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$text" "$text"
}

if [ -z "$repo" ] || [ ! -f "$repo/scripts/sync-vault.sh" ]; then
  say "Vault drift check skipped: planning repo not found. Set LLM_REPO to its path (e.g. /d/LLM-repo)."
  exit 0
fi

msg=""
# The comparison uses the repo's working tree, so say when that checkout is behind GitHub.
if timeout 15 git -C "$repo" fetch origin main --quiet 2>/dev/null; then
  behind=$(git -C "$repo" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
  [ "$behind" -gt 0 ] && msg+="The planning repo checkout is $behind commit(s) behind origin/main, so this check may be out of date."$'\n'
fi

report=$(VAULT_PATH="$vault" bash "$repo/scripts/sync-vault.sh" 2>&1)
rc=$?
problems=$(printf '%s\n' "$report" | tr -d '\r' | grep -E ': (MISSING|DIFFERS|EDITED IN VAULT|in vault only)|not registered' | sed 's/ (< vault, > repo)//; s/^/- /')

if [ "$rc" -eq 2 ]; then
  msg+="Vault drift check failed: $(printf '%s' "$report" | head -3)"$'\n'
elif [ -n "$problems" ]; then
  msg+="Vault rules/agents differ from the planning repo:"$'\n'"$problems"$'\n'
  msg+="Agents in this session may run on stale instructions. Before relying on them, open a session in the planning repo and ask it to \"sync the vault\". Do not edit CLAUDE.md or .claude/ here."$'\n'
fi

[ -n "$msg" ] && say "$msg"
exit 0
