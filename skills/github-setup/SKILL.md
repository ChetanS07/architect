---
name: github-setup
description: Connect the repo to GitHub — sign in to gh, pick or create the repository, set origin, set the PR merge method, and make the first push. Use when the user asks to set up GitHub or push the repo to GitHub for the first time, or when /architect runs it.
---

Connect the local git repo to a GitHub repository the user owns or administers. The skill **stops** (ends without finishing, and says why) only where a step below says so; every other outcome continues to the next step. It never bypasses a git hook.

The root is the `root=` argument when one is given; otherwise `git rev-parse --show-toplevel`. If that fails, stop: "Not a git repo. Run `/git-setup` first."

## 1. Sign in to gh

Run `gh --version`. If it fails, stop and tell the user to install the GitHub CLI (`winget install GitHub.cli` on Windows, `brew install gh` on macOS, https://github.com/cli/cli#installation otherwise).

Run `gh auth status`. When it reports no account, or a token that is invalid or expired, ask: "gh is not signed in to GitHub. How do you want to sign in?"

- **I'll do it myself**: tell the user to type `! gh auth login --web --git-protocol https --scopes workflow` and to say when it finishes. Then re-run `gh auth status`.
- **Do it for me**: run `gh auth login --hostname github.com --web --git-protocol https --scopes workflow` in the background. Read its output for the one-time code and the URL (https://github.com/login/device), and tell the user: "Open `<url>`, enter `<code>`, approve gh, then tell me when it's done." Wait for the command to exit. If it exits with an error, or prints no code, fall back to the option above.

When signed in, make sure the token can push workflow files: if `.github/workflows/` exists in the root and `gh auth status` does not list the `workflow` scope, run `gh auth refresh -h github.com -s workflow` the same way (it also prints a code to relay). Without that scope GitHub rejects any push that contains a workflow file.

Run `gh auth setup-git` so `git push` uses the gh credentials.

Done when `gh api user --jq .login` prints the **username**. Tell the user which account is signed in.

## 2. Choose the repository

If `git remote get-url origin` already points at a GitHub repo, ask: "origin already points to `<url>`. Use that repository?" Yes makes it the **target repo**; skip to the check at the end of this step.

Otherwise ask: "Have you already created the GitHub repository for this project? Share its link or name, or say no and I'll create one."

- **Link or name given**: accept `https://github.com/<owner>/<name>` (with or without `.git`), `git@github.com:<owner>/<name>.git`, `<owner>/<name>`, or a bare `<name>` (owner is the username). That is the target repo.
- **No**: ask "Do you want me to create one?"
  - **No**: stop: "No GitHub repository to connect to."
  - **Yes**: ask for the repository name (suggest the root folder's name) and its visibility, private (recommended) or public. Run `gh repo create <username>/<name> --private` (or `--public`). If the name is taken, say so and ask for another. The new repo is the target repo.

Check the target repo with `gh repo view <owner>/<name> --json nameWithOwner,url,sshUrl,isEmpty,defaultBranchRef,viewerPermission`:

- **Not found**: say so and ask again from the top of this step (link, name, or create).
- **`viewerPermission` is not `ADMIN`**: the merge settings in step 4 need admin. Tell the user; they choose another repo or continue, and step 4 is then skipped.

Done when the target repo exists and its `nameWithOwner`, `isEmpty` and default branch (empty on a new repo) are recorded.

## 3. Set origin

The remote URL is the repo's `url` plus `.git`, or its `sshUrl` when `gh config get git_protocol` prints `ssh`.

- **No origin**: `git remote add origin <remote URL>`.
- **origin points at the target repo** (any URL form): leave it.
- **origin points elsewhere**: ask "origin points to `<old url>`. Replace it with `<remote URL>`?" Yes: `git remote set-url origin <remote URL>`. No: stop: "origin left pointing at `<old url>`."

Done when `git remote get-url origin` resolves to the target repo.

## 4. Set the merge method

Ask: "Which merge method should pull requests use? It becomes the only one allowed." Options:

- **Squash merge**: each PR lands as one commit. Mark it recommended when `docs/project-manifest/branching-and-pr.md` exists, since those standards squash-merge.
- **Merge commit**: keeps every PR commit plus a merge commit.
- **Rebase merge**: replays the PR commits onto the default branch, no merge commit.

Set the chosen method to `true`, the other two to `false`, and turn on deleting the head branch after merge:

```sh
gh api --method PATCH repos/<owner>/<name> \
  -F allow_squash_merge=<true|false> \
  -F allow_merge_commit=<true|false> \
  -F allow_rebase_merge=<true|false> \
  -F delete_branch_on_merge=true
```

Done when `gh api repos/<owner>/<name> --jq '[.allow_squash_merge,.allow_merge_commit,.allow_rebase_merge,.delete_branch_on_merge]'` shows exactly the chosen method `true` and `delete_branch_on_merge` `true`.

## 5. First push

The **target branch** is the target repo's default branch, or, on an empty repo, the current local branch (`git symbolic-ref --short HEAD`).

Ask: "GitHub is set up. Commit everything in the repo (files matched by `.gitignore` stay out) and push it to `<target branch>`?" No: skip to the report.

On yes:

1. **Branch.** If the current local branch differs from the target branch and has no upstream, rename it: `git branch -m <target branch>`. If it has an upstream, ask which branch to push instead of renaming.
2. **Commit.** Run `git add -A`, then `git status --short`. If nothing is staged and the branch already has commits, go to push. Otherwise commit. For the message, follow the title rules in `docs/project-manifest/templates/commit-conventions.md` when it exists; otherwise use `Initial commit`. When a pre-commit hook rejects the commit (gitleaks found a secret, for example), stop: show the hook's output and leave the files staged for the user to fix.
3. **Catch up with the remote.** Run `git fetch origin`. When `origin/<target branch>` exists and is not an ancestor of `HEAD` (the remote has commits, such as a README created with the repo), run `git rebase origin/<target branch>`. The local commits are unpushed, so rebasing them is safe. On a conflict, show the conflicting files and ask the user how to resolve each; when they want to back out, run `git rebase --abort` and stop.
4. **Push.** `git push -u origin <target branch>`. When the push is rejected, show the error and stop.
5. **Confirm.** `git fetch origin`, then `git status -sb`.

Done when `git status -sb` shows `<target branch>...origin/<target branch>` with no `ahead` or `behind`, and `git status --short` lists nothing except files the user chose to leave out.

## 6. Report

Tell the user in a few lines:

- The signed-in account, and the target repo's URL (and whether it was created now).
- origin's URL, and whether it was added, kept or replaced.
- The merge method allowed, and that head branches are deleted after merge (or that step 4 was skipped for lack of admin).
- What was pushed: the commit(s) and the branch, or that the push was skipped.
- Next: branch protection and required checks are still manual; see `docs/project-manifest/repo-setup.md` when it exists.
