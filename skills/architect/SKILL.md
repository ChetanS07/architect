---
name: architect
description: Set up a project end to end — bootstrap git, install the standards, add CI, set up GitHub.
disable-model-invocation: true
---

Run this plugin's four **stages** in order. Each stage is a sibling skill that writes its own files and asks its own questions. `setup-git`, `setup-manifest` and `setup-ci` never commit; only `setup-github` commits, pushes, and changes the GitHub remote. This skill picks the root, runs the stages in order, and reports the outcome. It never commits or pushes itself.

| # | Stage | Skill | Runs when |
|---|-------|-------|-----------|
| 1 | Git baseline | `architect:setup-git` | always |
| 2 | Standards | `architect:setup-manifest` | always |
| 3 | CI pipeline | `architect:setup-ci` | stage 1 is done, since CI needs a git repo; it reads the stack from the standards stage 2 installs |
| 4 | GitHub | `architect:setup-github` | stages 1 and 2 are done, since it builds on the repo and standards they create; it also commits stage 3's workflow when that stage ran |

Every stage is safe to re-run: each only adds, and asks before replacing. An interrupted run is recovered by running `/architect` again, or the unfinished stage alone.

## 1. Find the root

Walk up from the working directory looking for `.git` (a directory, or a file in a worktree or submodule):

- **In the working directory**: that is the root.
- **In a parent**: ask "This folder is inside the git repo at `<parent>`. Set up that repo, or a separate repo here?" The answer is the root.
- **Nowhere**: the working directory is the root; stage 1 initializes git there.

The root is final for the whole run. When a stage's own "find the repo" step would reach a different answer or ask again, use this root silently.

Done when the root is known.

## 2. Run the stages

Take each stage in table order and run it to its end before starting the next:

1. **Check "Runs when".** When it fails, mark the stage skipped with the reason and go to the next one.
2. **Invoke the stage's skill** with the Skill tool, `args`: `root=<root>; run by /architect`. When the Skill tool cannot find it, mark it skipped with "`<skill>` is not installed" and go on.
3. **Follow the loaded instructions** step by step:
   - Put every question the stage asks to the user, worded as the stage words it, and run every check it lists.
   - Resolve paths it calls "beside this file" (`references/`, `templates/`) against **that skill's** base directory, which the Skill tool reports.
   - End at its final **Report** step without running it: step 3 below reports the whole run.
4. **Record the outcome.** When its last "Done when" holds, mark it done and note its outcomes in a few lines (created, merged, kept, skipped) for the final report.

**A stopped stage** (its own rules say stop, or the user declines it): ask "`<stage>` stopped: `<reason>`. Skip it and continue, or end the run here?"

- **Skip**: mark it skipped with the reason and go on. Any later stage whose "Runs when" depends on it is skipped too.
- **End**: go to step 3.

Done when every stage is done or skipped, or the user chose to end at a stopped stage.

## 3. Report

Report to the user, grouped by stage, a few lines each:

- What each stage created, merged, kept or skipped.
- Stages not run, and why: not applicable, not installed, or skipped after a stop.
- **Ended early**: the stage it stopped at and why; once that is fixed, re-run that stage alone or `/architect`.
- Whether the files were committed and pushed: they are only when `setup-github` ran to its end; otherwise they are uncommitted.
- Manual next steps: branch protection and required checks (the CI jobs plus `secret-scan`), per the plugin's checklist at https://github.com/ChetanS07/architect/blob/main/docs/repo-setup.md.
- Any stage re-runs alone: `/setup-git`, `/setup-manifest`, `/setup-ci`, `/setup-github`. When the stack changes, re-run `/setup-git` to add its `.gitignore` blocks.

Done when the report is shown.
