---
name: setup-ci
description: Create a GitHub Actions CI pipeline that runs the project's checks, tests and build on every pull request, with the check list chosen from the stack and approved by the user. Use when the user asks to set up or add CI, or when step 3 of branching-and-pr.md finds no CI workflow.
---

Write one GitHub Actions workflow that runs the project's checks on every pull request. The stack decides what to recommend; the user decides what runs. Nothing is written until the user approves the **final list**. This skill never commits: when `branching-and-pr.md` step 3 called it, that workflow commits the file.

## 1. Find the repo and existing CI

Walk up from the working directory to the nearest directory containing `.git`; that is the root. If none is found, stop and tell the user CI needs a git repo (`/git-setup` creates one).

Find the default branch: `git symbolic-ref --short refs/remotes/origin/HEAD` with `origin/` stripped; failing that, whichever of `main` or `master` exists locally; failing that, ask.

Read every file in `.github/workflows/`. A workflow that runs on `pull_request` and runs lint, tests or a build counts as **existing CI**; a secret-scan-only workflow (such as git-setup's `secret-scan.yml`) does not. If existing CI is found, ask: "`<file>` already runs `<jobs>` on pull requests. Extend it, replace it, or stop?" Stop ends the skill.

Done when the root, the default branch, and the target (new `ci.yml`, or the existing file to extend or replace) are known.

## 2. Identify the stack

Read `docs/project-manifest/tech-stack-and-low-level-design.md`. From it, record the **stack profile**:

- Language and runtime version
- Framework
- Package manager
- Test framework, and test kinds (unit, integration, end to end)
- Linter, formatter, type checker
- Build output (bundle, binary, container image, none)
- Services tests need (database, cache, queue)
- Layout: single app, or a monorepo with which packages

**File missing**: ask the user directly, listing every field above as one question: "No `tech-stack-and-low-level-design.md` was found. To pick CI checks I need: <fields>. Answer what you know; say `unsure` for the rest."

**File present but silent on a field**: fill it from the repo itself (`package.json` scripts and dependencies, `pyproject.toml`, `go.mod`, lockfiles, config files such as `.eslintrc*` or `ruff.toml`). Ask about whatever is still unknown, in one question.

Done when every field has a value, `none`, or `unsure` from the user.

## 3. Recommend and confirm the final list

Build the recommended list from the stack profile using [`references/stack-checks.md`](references/stack-checks.md). Each item is one CI job: its name, the exact command, and one line on why. Use the command the repo already defines (a `package.json` script, a `Makefile` target, a `tox` env) over the reference's default. An item with `unsure` behind it is still listed, marked `(assumed)`.

Show the list and ask: "CI will run these on every pull request. Reply `yes` to approve, or tell me what to change, add or remove."

Keep a **change log** of every request the user makes. On any reply other than a plain approval:

1. Apply every requested change to the list, and add each to the change log.
2. Show the updated list in full, with the change log beneath it, and ask the same question again.

Repeat until the user approves the list unchanged. That list is the **final list**.

Done when the user has said `yes` to the final list as shown, with no pending change.

## 4. Write the workflow

Write `.github/workflows/ci.yml` (or edit the target from step 1) following the workflow shape in [`references/stack-checks.md`](references/stack-checks.md). Every item on the final list becomes exactly one job, named as on the list, and nothing outside the final list goes in.

Pin each action to its latest major tag, found with `git ls-remote --tags https://github.com/<owner>/<action>`; leave a comment where a lookup failed.

Then check the file: it parses as YAML (`python -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" <file>`, or `actionlint` when installed), and every command it runs exists in the repo (the script, target or tool is defined or installed by an earlier step).

Done when the file is written, parses, and each final-list item maps to one job.

## 5. Report

Tell the user in a few lines:

- The workflow file and its jobs, one line each.
- Where the stack came from: the manifest file, the repo, or the user's answers.
- Items marked `(assumed)` that the user should verify.
- That the job names are the status checks to mark required in branch protection (https://github.com/ChetanS07/architect/blob/main/docs/repo-setup.md), after CI has run once on a PR.
- That nothing was committed.
