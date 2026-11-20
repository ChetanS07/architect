# Branching and PR guidelines

Applies to every git write: branch, commit, push, PR, rebase, merge, conflict resolution. Read-only inspection is out of scope.

## Terms

- **`<default>`**: the repo's default branch. Look it up with `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, falling back to `git symbolic-ref --short refs/remotes/origin/HEAD` (strip `origin/`).
- **Shared**: any branch that exists on the remote. Once pushed, a branch is shared, whoever else uses it.
- **Hard stop**: an action you pause on and ask the human about, listed under Hard stops. A human approval covers the one action it names, in the current session only.

## Precedence

Repo rules beat this file. Before the first write, check for each and follow it where it conflicts:

- `CONTRIBUTING.md`
- `.github/CODEOWNERS`
- `.github/pull_request_template.md`
- `git config commit.template`
- Branch protection: `gh api repos/:owner/:repo/branches/<default>/protection`. A 404 means you lack admin access, so treat protection as unknown, not absent.

When a repo rule overrides this file, name the rule that won in your next reply.

## Workflow

Trunk-based: `<default>` is always deployable, and work lands through short-lived branches off it. Each step ends on its **done** line; reach it before moving on.

Steps 1, 2, 3, and 5 each apply a conventions file from `templates/`. Read the named file at the start of its step.

1. **Start the branch.** The working tree must be clean; if it holds changes you did not make, ask the human. Then `git fetch origin && git switch --no-track -c <type>/<short-description> origin/<default>`, named per [`templates/branch-conventions.md`](templates/branch-conventions.md).
   Done: `git status -sb` shows the new branch, clean, tracking nothing yet.

2. **Commit as each piece works.** Every commit follows [`templates/commit-conventions.md`](templates/commit-conventions.md). Stage files by name, then read `git diff --cached` for secrets (`.env`, keys, tokens) before committing. When a pre-commit hook fails, fix the cause and commit again.
   Done: every piece of working code is in a commit, and the staged diff was read before each one.

3. **Push and open a draft PR early.** `git push -u origin <branch>`, then `gh pr create --draft --base <default> --title "<title>" --body-file <file>`, with the title and body written per [`templates/pr-template.md`](templates/pr-template.md).
   Done: `gh pr view` shows a draft PR from this branch.

4. **Keep pushing.** Commit follow-up work on the same branch and `git push`. CI and reviewers see only pushed commits. If `<default>` has moved, merge `origin/<default>` into the branch (the branch is shared now, so merge rather than rebase).
   Done: `git status -sb` shows the branch level with its upstream.

5. **Mark ready and hand off.** Measure size per the Size section of [`templates/branch-conventions.md`](templates/branch-conventions.md). Then run `gh pr ready` and report the PR link to the human. A separate workflow owns all checks (lint, type-check, tests, build), so your step ends once the PR is marked ready.
   Done: the PR is marked ready, and the human has the link.

6. **Answer review.** Fix each comment in new commits on the branch, push, and reply to each thread with what changed. Then repeat step 5.
   Done: every review thread has a reply or a fix, and the PR is marked ready again.

## Hard stops

Ask the human before any of these:

- Pushing directly to `<default>`.
- Merging any PR, including your own, or bypassing protection (`gh pr merge --admin`). The human merges, by squash-merge.
- Force-pushing a shared branch, `--force-with-lease` included, or any other rewrite of shared history (amend, rebase).
- Any command carrying `--force`, `-f`, or `--no-verify`.
- `git reset --hard` or `git clean -fd` where they would discard commits or changes that exist nowhere else.
- Deleting any branch, locally or on the remote. A separate workflow cleans up branches after merge.
- Marking ready a PR over 1500 lines of diff (see `templates/branch-conventions.md`).

## Recovery

- **Merge conflict**: list the conflicting files and show the conflicting hunks, then ask the human how to resolve each.
- **Commit landed on local `<default>`**: keep it local. Run `git branch <type>/<name>` to save the commit on a new branch, then `git reset --hard origin/<default>` on `<default>` (the commit now lives on the new branch, so this discards nothing). Continue from step 3 on the new branch.
- **Secret pushed**: halt all git activity and report to the human at once. The human rotates the credential; leave the branch and history as they are, since rewriting history cannot undo a leak.

## Not covered

CI and PR checks, and branch cleanup after merge (separate workflows own both), release tagging and versioning, deployment, monorepo tooling, production hotfixes, submodules. For any of these, ask the human for the workflow.
