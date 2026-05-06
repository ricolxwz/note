# Add, Commit, and Push

Run an add/commit/push workflow for the current repository.

1. Check the current git status.
2. Review the diff so the commit message matches the actual changes.
3. Stage all changes with `git add .`.
4. Create a commit with a concise conventional-style message.
   - If the user provided text after `/acp`, use it as the commit message or as guidance for the message.
   - Do not add co-author trailers unless the user explicitly asks.
5. Push the current branch to its upstream remote.
6. Report the commit hash and whether the push succeeded.

If there are no changes to commit, say so and skip commit/push.
