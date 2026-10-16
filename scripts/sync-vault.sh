#!/usr/bin/env bash
# Compare (and optionally update) the vault's CLAUDE.md against docs/vault-CLAUDE.md.
#
#   scripts/sync-vault.sh            report drift only (read-only)
#   scripts/sync-vault.sh --apply    overwrite the vault CLAUDE.md (old copy kept as CLAUDE.md.bak)
#
# Vault path: $VAULT_PATH, else /d/LLM (Git Bash), else D:/LLM.
# Only CLAUDE.md is synced. index.md and log.md are live vault files seeded once
# from their templates, so this script only checks that they exist, never overwrites.
set -u

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
template="$repo/docs/vault-CLAUDE.md"
apply=0
[ "${1:-}" = "--apply" ] && apply=1

vault="${VAULT_PATH:-}"
if [ -z "$vault" ]; then
  for c in /d/LLM D:/LLM; do [ -d "$c" ] && vault="$c" && break; done
fi
if [ -z "$vault" ] || [ ! -d "$vault" ]; then
  echo "Vault not found. Set VAULT_PATH, e.g. VAULT_PATH=/d/LLM $0" >&2
  exit 2
fi

# The vault copy is everything below the first line that is exactly '---'.
body=$(mktemp); trap 'rm -f "$body"' EXIT
awk 'f{print} /^---[[:space:]]*$/ && !f{f=1}' "$template" | sed '1{/^[[:space:]]*$/d}' | tr -d '\r' > "$body"
[ -s "$body" ] || { echo "Could not extract template body from $template" >&2; exit 2; }

echo "Vault: $vault"
target="$vault/CLAUDE.md"
status=0

if [ ! -f "$target" ]; then
  echo "CLAUDE.md: MISSING in vault"
  status=1
elif diff -q <(tr -d '\r' < "$target") "$body" >/dev/null; then
  echo "CLAUDE.md: in sync"
else
  echo "CLAUDE.md: DIFFERS from template (< vault, > template)"
  diff <(tr -d '\r' < "$target") "$body" | head -40
  status=1
fi

if [ "$status" -ne 0 ] && [ "$apply" -eq 1 ]; then
  [ -f "$target" ] && cp "$target" "$target.bak"
  cp "$body" "$target"
  echo "CLAUDE.md: updated from template (previous copy saved as CLAUDE.md.bak if one existed)"
  status=0
fi

for f in index.md log.md; do
  [ -f "$vault/$f" ] || echo "$f: missing in vault, seed it from docs/vault-${f%.md}-template.md"
done

[ "$status" -ne 0 ] && [ "$apply" -eq 0 ] && echo "Run with --apply to update the vault copy."
exit "$status"
