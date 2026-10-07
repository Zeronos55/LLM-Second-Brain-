# Working agreement for Claude sessions

This repo is worked on from a **local** Claude session and a **cloud** Claude session, one at a time.
Neither session sees the other's changes unless they go through git, so git is the handoff.

## Branches
- Local sessions: `local/<topic>`. Cloud sessions: the assigned `claude/<id>` branch.
- Never commit directly to `main`; merge via PR. Never force-push.

## Session start
- A hook prints a "Git sync report" if the remote has commits this branch lacks.
  If it does, merge the named branch before editing.

## After significant work
- When you finish a significant change (new/edited doc, new file, restructure), say so and
  offer to commit and push. A hook also reminds the user about uncommitted or unpushed work.

## Handoff
- Leaving a side: "commit and push everything", then confirm no unpushed-work reminder remains.
- Cloud -> local: `claude --teleport <session-id>`, or fetch and merge the cloud branch.
- Local -> cloud: push the branch, then start the cloud session from it (or have it fetch and merge first).
