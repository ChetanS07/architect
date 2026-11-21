---
name: git-setup
description: Initialize git and install .gitattributes, .gitignore, gitleaks secret scanning, .editorconfig and README.md, filling in whatever is missing. Use when the user asks to set up git or secret scanning for a repo, or when /architect runs it.
---

Make the current repo a git repo with a baseline kit: `.gitattributes`, `.gitignore`, gitleaks (config plus a pre-commit hook), `.editorconfig` and `README.md`. Each item is **missing** (create it from `templates/` beside this file), **partial** (merge in only what is absent) or **present** (leave it). The repo's existing content always stands; this skill only adds. It never commits.

## 1. Find or create the repo

Walk up from the working directory through its parents looking for `.git` (a directory, or a file in a worktree or submodule).

- **Found in the working directory**: that is the repo root. Already initialized.
- **Found in a parent**: ask "This folder is inside the git repo at `<parent>`. Set up that repo, or initialize a separate repo here?" Use the parent, or initialize here, per the answer.
- **Not found**: initialize here. If `git config --get init.defaultBranch` prints a value, run `git init`; otherwise run `git init -b main`.

If `git` itself is missing, stop and tell the user to install it.

Then find the **default branch**. Don't use the checked-out branch of an existing repo: it may be a feature branch.

- **Initialized now**: `git symbolic-ref --short HEAD`.
- **Already existed, with an `origin`**: `git symbolic-ref --short refs/remotes/origin/HEAD` with the `origin/` prefix stripped. If that fails, `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` when `gh` is installed and signed in.
- **Otherwise**: the one of `main` or `master` that exists locally (`git rev-parse --verify --quiet refs/heads/<name>`). If both or neither exist, ask: "Which branch is this repo's default branch?"

Done when `git -C <root> rev-parse --show-toplevel` prints the root, and you have recorded whether it was initialized now or already existed, and the default branch.

## 2. Detect the stack

Each source below selects gitignore blocks from `templates/gitignore/`. Take the union of all of them.

1. **Marker files** at the root, listed in `references/stack-markers.md`.
2. **The Markdown files in `docs/project-manifest/`**, if that folder exists. They may describe the stack before any code is written. Select the block for each framework, language or platform they name, using the same mapping as `references/stack-markers.md` (for example Next.js selects `nextjs` and `node`, FastAPI selects `python`, Flutter selects `dart`). Skip the generic standards `/manifest-setup` installs (`coding-standards.md`, `folder-structure.md`, `folder-structure-scaffold.md`, `branching-and-pr.md`, `templates/`, `design-system.md`, and `repo-setup.md` left by older installs): the frameworks in their examples describe no project.

If a doc names a framework or language that has no matching block, skip it and mention it in the report. Don't ask about it.

Ask only when both sources come up empty: "No stack was detected. Which stack does this project use? Options: <options>", where `<options>` is the list at the end of `references/stack-markers.md`. Select the blocks from the answer. The user may name more than one.

Done when you have the list of selected blocks (possibly empty, only when the user answers none).

## 3. Install each item

Work through every item below and give each an outcome: created, merged (with what was added), or present.

### .gitattributes

- Missing: copy `templates/gitattributes` to `.gitattributes`.
- Exists: for each attribute line in the template, compare its pattern (the first token). Append the lines whose pattern does not appear in the file, under a `# Added by git-setup` comment. A pattern the repo already sets keeps the repo's attributes.

### .gitignore

The wanted lines are `templates/gitignore/base` followed by each selected block.

- Missing: write `.gitignore` from the wanted lines, blocks separated by a blank line.
- Exists: append the wanted lines that are not already in the file (exact match after trimming whitespace), keeping each block's `# ---` heading above its added lines. Skip a block entirely when all its lines are present.

Then run `git ls-files -ci --exclude-standard`. If it lists files (tracked but now ignored, such as a committed `.env`), report them; untracking them is the user's call.

### .editorconfig

- Missing: copy `templates/editorconfig` to `.editorconfig`.
- Exists: present. The repo's formatting rules stand.

### gitleaks

Four parts, each checked on its own:

1. **Config.** If neither `.gitleaks.toml` nor `.gitleaks.config.toml` exists, copy `templates/gitleaks.toml` to `.gitleaks.toml`.
2. **Pre-commit hook.** Pick the first hook manager that applies:
   - **pre-commit framework** (`.pre-commit-config.yaml` exists): if no hook with `id: gitleaks` is listed, add a `repos` entry for `https://github.com/gitleaks/gitleaks` with hook `id: gitleaks`. Set `rev` to the highest `v8.x.y` tag from `git ls-remote --tags https://github.com/gitleaks/gitleaks`. Hook command for the README: `pre-commit install`.
   - **Husky** (`.husky/` exists): if `.husky/pre-commit` does not mention `gitleaks`, merge the template body into it (see "Merging into an existing hook" below), creating the file if needed. Hook command: the repo's existing install script (usually `npm install`).
   - **Plain git hooks** (otherwise): use `.githooks/pre-commit`. If it is missing, copy `templates/pre-commit-hook.sh` there; if it exists without `gitleaks`, merge the template body into it (see below). Run `git config core.hooksPath .githooks` (if `core.hooksPath` is already set to another directory, put the hook there instead and leave the setting). Run `git update-index --add --chmod=+x .githooks/pre-commit` so the hook is executable on every clone. This stages the file. Hook command: `git config core.hooksPath .githooks`.

   **Merging into an existing hook.** Take the template body without its shebang. Don't blindly append it: a hook that already ends the script (for example `exec npx lint-staged` or `exit 0`) would never reach the scan. Instead, insert the body directly before the first line that ends the script unconditionally: an `exit` or `exec` at the top level, not inside an `if`, `case`, loop or function. If there is no such line, append the body at the end. Keep any lines that set up the hook above the inserted body (the shebang, `set -e`, and lines that source another file such as `. "$(dirname -- "$0")/_/husky.sh"`). The template body only exits when gitleaks finds a secret, so placing it before existing commands never skips them.
3. **Binary.** Run `gitleaks version`. If it fails, ask "gitleaks is not installed, so the hook will skip the scan. Install it now with `<command>`?" where `<command>` is:
   - **Windows**: `winget install gitleaks.gitleaks`.
   - **macOS**: `brew install gitleaks`.
   - **Linux**: `brew install gitleaks` if `brew` is on the PATH. Otherwise install the release binary into `~/.local/bin` (no sudo needed):
     ```sh
     VERSION=<gitleaks-version without the leading v>   # e.g. 8.30.1, from the ls-remote lookup in part 4
     case "$(uname -m)" in x86_64) ARCH=x64 ;; aarch64|arm64) ARCH=arm64 ;; armv7l) ARCH=armv7 ;; armv6l) ARCH=armv6 ;; i386|i686) ARCH=x32 ;; esac
     mkdir -p ~/.local/bin
     curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/gitleaks_${VERSION}_linux_${ARCH}.tar.gz" | tar -xz -C ~/.local/bin gitleaks
     ```
     If `uname -m` matches none of these, fall back to pointing the user at https://github.com/gitleaks/gitleaks/releases.

   Install only on yes. Afterwards run `gitleaks version` again to confirm. On Linux, if it still fails because `~/.local/bin` is not on the PATH, tell the user to add it (for example `export PATH="$HOME/.local/bin:$PATH"` in their shell profile).
4. **CI workflow.** Skip this part, and say so in the report, when `git remote get-url origin` points somewhere other than GitHub. When there is no `origin` (the command fails), treat it as GitHub: install the workflow and note in the report that no remote was set. Otherwise, if no file in `.github/workflows/` mentions `gitleaks`, copy `templates/gitleaks-workflow.yml` to `.github/workflows/secret-scan.yml`, replacing:
   - `<default-branch>`: the default branch recorded in step 1.
   - `<gitleaks-version>`: the highest `v8.x.y` tag from `git ls-remote --tags https://github.com/gitleaks/gitleaks`, kept as is (for example `v8.30.1`); the container image uses the same tags.

   The job is named `secret-scan`, the check name the plugin's repo-setup checklist (https://github.com/ChetanS07/architect/blob/main/docs/repo-setup.md) marks as required in branch protection.

Gitleaks counts as present when the config, the hook, the binary and the CI workflow all are.

### README.md

Any existing `README` file at the root (any case, any extension) counts as present. Leave its content alone; if it lacks the hook command from the gitleaks step, mention that in the report.

When missing, write `README.md` from `templates/README.md`, replacing its placeholders as the comment at the top of the template describes. Remove that comment from the written file, and leave no `<...>` placeholder in it.

Done when all five items have an outcome.

## 4. Report

Tell the user in a few lines:

- Whether git was initialized now or already existed, and the default branch.
- Each item's outcome: created, merged (list what was added), or present.
- Which stack blocks were selected and where they came from (marker files, docs, or the user). Also list any frameworks or languages named in the docs that had no matching block.
- Tracked files that the new `.gitignore` now ignores, if any.
- Whether the gitleaks binary is installed, and whether the CI workflow was added (noting when no remote was set) or skipped (non-GitHub remote).
- That nothing was committed (and that `.githooks/pre-commit` is staged, if it was).
