#!/usr/bin/env bash
# Stop: remind the user (read-only) when work is uncommitted or unpushed.
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
branch=$(git symbolic-ref --short -q HEAD) || exit 0
case "$branch" in main|master) exit 0;; esac

dirty=$(git status --porcelain | wc -l | tr -d ' ')
if git rev-parse --verify -q '@{u}' >/dev/null; then
  unpushed=$(git rev-list --count '@{u}..HEAD')
elif git rev-parse --verify -q origin/main >/dev/null; then
  unpushed=$(git rev-list --count origin/main..HEAD)
else
  unpushed=0
fi

state="$branch:$dirty:$unpushed"
statefile="$(git rev-parse --git-dir)/push-reminder.state"

if [ "$dirty" -eq 0 ] && [ "$unpushed" -eq 0 ]; then
  rm -f "$statefile"; exit 0
fi
[ "$(cat "$statefile" 2>/dev/null)" = "$state" ] && exit 0   # already reminded for this state
echo "$state" > "$statefile"

msg="Unpushed work on $branch: $unpushed unpushed commit(s), $dirty uncommitted file(s). Ask Claude to commit and push before switching sides."
printf '{"systemMessage": "%s"}\n' "$msg"
exit 0
