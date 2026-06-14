---
name: "acp"
description: "Run an add/commit/push workflow in the current git repository."
---

# ACP Skill

## When to use
- Execute a standard add/commit/push flow for repository changes.
- Handle the `acp` shortcut workflow in this workspace.
- Ensure status check, message alignment, commit creation, and push are performed in one pass.

## Workflow
1. Check `git status` and confirm repository state.
2. Review diff briefly so the commit message reflects actual changes.
3. Stage all changes with `git add .`.
4. Create a commit with a concise Conventional Commit-style message.
   - If the user passed text after `/acp`, use it as guidance for the message.
   - If no explicit text is provided, infer a short conventional message from the diff.
   - Do not add co-author trailers unless explicitly requested.
5. Push the current branch to upstream remote.
6. Report commit hash and push result.

## No-op behavior
- If there are no changes to commit, report that there is nothing to do and skip commit/push.

## Safety notes
- Do not amend commits unless explicitly asked.
- Do not skip the status review unless the user explicitly asks for a raw commit attempt.
- Never invent a branch name or remote; use current branch and configured upstream.
- If remote push fails, return the exact git output and next recovery suggestion.
