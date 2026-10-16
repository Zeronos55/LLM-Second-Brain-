#!/usr/bin/env bash
# Compare (and optionally update) the vault's copies of the files this repo owns:
#   docs/vault-CLAUDE.md    -> <vault>/CLAUDE.md
#   .claude/agents/*.md     -> <vault>/.claude/agents/*.md
#
#   scripts/sync-vault.sh                    report drift only (read-only)
#   scripts/sync-vault.sh --apply            copy repo versions into the vault (old copies kept as *.bak)
#   scripts/sync-vault.sh --apply --force    also overwrite files that were edited inside the vault
#
# The repo is the source of truth; the vault holds copies. --apply records a hash of
# every file it writes in <vault>/.claude/sync-state. A vault file that no longer matches
# its recorded hash (or was never synced) was edited in the vault: it is reported as
# EDITED IN VAULT and left alone, so merge those edits into the repo first, then --force.
#
# Vault path: $VAULT_PATH, else /d/LLM (Git Bash), else D:/LLM.
# index.md and log.md are live vault files seeded once from their templates,
# so this script only checks that they exist, never overwrites.
set -u

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
apply=0
force=0
for arg in "$@"; do
  case "$arg" in
    --apply) apply=1 ;;
    --force) force=1 ;;
    *) echo "Usage: $0 [--apply [--force]]" >&2; exit 2 ;;
  esac
done

vault="${VAULT_PATH:-}"
if [ -z "$vault" ]; then
  for c in /d/LLM D:/LLM; do [ -d "$c" ] && vault="$c" && break; done
fi
if [ -z "$vault" ] || [ ! -d "$vault" ]; then
  echo "Vault not found. Set VAULT_PATH, e.g. VAULT_PATH=/d/LLM $0" >&2
  exit 2
fi

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# The vault CLAUDE.md is everything below the first line of the template that is exactly '---'.
template="$repo/docs/vault-CLAUDE.md"
awk 'f{print} /^---[[:space:]]*$/ && !f{f=1}' "$template" | sed '1{/^[[:space:]]*$/d}' | tr -d '\r' > "$tmp/CLAUDE.md"
[ -s "$tmp/CLAUDE.md" ] || { echo "Could not extract template body from $template" >&2; exit 2; }

state="$vault/.claude/sync-state"   # lines: <sha256> <path relative to vault>
newstate="$tmp/sync-state"
if [ -f "$state" ]; then cp "$state" "$newstate"; else : > "$newstate"; fi

hash_of() { tr -d '\r' < "$1" | sha256sum | cut -d' ' -f1; }
recorded_hash() { awk -v p="$1" '$2 == p {print $1}' "$newstate"; }
record() {   # record <relpath> <hash>
  awk -v p="$1" '$2 != p' "$newstate" > "$newstate.tmp"
  echo "$2 $1" >> "$newstate.tmp"
  mv "$newstate.tmp" "$newstate"
}

echo "Vault: $vault"
status=0

# sync_file <repo source> <path relative to vault>
sync_file() {
  local src=$1 rel=$2 target="$vault/$2" write=0
  if [ ! -f "$target" ]; then
    echo "$rel: MISSING in vault"
    write=1
  elif diff -q <(tr -d '\r' < "$target") <(tr -d '\r' < "$src") >/dev/null; then
    echo "$rel: in sync"
    [ "$apply" -eq 1 ] && record "$rel" "$(hash_of "$target")"
    return
  elif [ "$(hash_of "$target")" = "$(recorded_hash "$rel")" ]; then
    echo "$rel: DIFFERS, repo has the newer version (< vault, > repo)"
    write=1
  else
    echo "$rel: EDITED IN VAULT since the last sync (or never synced) — merge those edits into the repo first (< vault, > repo)"
    [ "$force" -eq 1 ] && write=1
  fi
  [ -f "$target" ] && diff <(tr -d '\r' < "$target") <(tr -d '\r' < "$src") | head -40

  if [ "$apply" -eq 1 ] && [ "$write" -eq 1 ]; then
    mkdir -p "$(dirname "$target")"
    [ -f "$target" ] && cp "$target" "$target.bak"
    tr -d '\r' < "$src" > "$target"
    record "$rel" "$(hash_of "$target")"
    echo "$rel: updated from repo (previous copy saved as $(basename "$rel").bak if one existed)"
  else
    status=1
  fi
}

sync_file "$tmp/CLAUDE.md" "CLAUDE.md"
for agent in "$repo"/.claude/agents/*.md; do
  sync_file "$agent" ".claude/agents/$(basename "$agent")"
done

# Agents that exist only in the vault are not managed by the repo; flag them so they get moved over.
for agent in "$vault"/.claude/agents/*.md; do
  [ -f "$agent" ] || continue
  [ -f "$repo/.claude/agents/$(basename "$agent")" ] || echo ".claude/agents/$(basename "$agent"): in vault only — add it to the repo if it should be kept"
done

if [ "$apply" -eq 1 ]; then
  mkdir -p "$vault/.claude"
  cp "$newstate" "$state"
fi

for f in index.md log.md; do
  [ -f "$vault/$f" ] || echo "$f: missing in vault, seed it from docs/vault-${f%.md}-template.md"
done

if [ "$status" -ne 0 ]; then
  if [ "$apply" -eq 0 ]; then
    echo "Run with --apply to update the vault copies."
  elif [ "$force" -eq 0 ]; then
    echo "Files EDITED IN VAULT were left alone. Merge their changes into the repo, then rerun with --apply --force."
  fi
fi
exit "$status"
