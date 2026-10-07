#!/usr/bin/env bash
# SessionStart: report (never merge) whether the remote has work this session lacks.
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
timeout 20 git fetch origin --quiet 2>/dev/null || exit 0

branch=$(git symbolic-ref --short -q HEAD) || exit 0
out=""

if up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null); then
  n=$(git rev-list --count "HEAD..$up")
  [ "$n" -gt 0 ] && out+="- $branch is $n commit(s) behind $up. Pull/merge before editing."$'\n'
fi

for ref in origin/main $(git for-each-ref --format='%(refname:short)' 'refs/remotes/origin/claude/*' 'refs/remotes/origin/local/*'); do
  [ "$ref" = "origin/$branch" ] && continue
  # only branches with recent activity (last 2 days); skip stale ones
  ts=$(git log -1 --format=%ct "$ref" 2>/dev/null) || continue
  [ $(( $(date +%s) - ts )) -gt 172800 ] && continue
  n=$(git rev-list --count "HEAD..$ref" 2>/dev/null) || continue
  if [ "$n" -gt 0 ]; then
    out+="- $ref has $n commit(s) not in HEAD:"$'\n'
    out+=$(git log --format='    %h %an: %s' -n 3 "HEAD..$ref")$'\n'
  fi
done

if [ -n "$out" ]; then
  echo "Git sync report (other session may have pushed changes):"
  printf '%s' "$out"
  echo "Merge the relevant branch into this one before editing."
fi
exit 0
