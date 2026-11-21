---
name: setup-manifest
description: Install the architect dev standards into docs/project-manifest/ and register them in CLAUDE.md. Use when the user asks to install or update the project standards, or when /architect runs it.
---

Install the standards in `references/` (beside this file) into the current repo, then register them in `CLAUDE.md` so future sessions read the right file before the work it covers. A re-run offers newer standards and asks before replacing any file that differs.

## 1. Confirm the repo

Find the repo root:

1. Walk up from the working directory through its parents. The nearest directory containing `.git` is the root. This keeps a monorepo subfolder with its own `package.json` from being mistaken for the root.
2. If no `.git` is found, use the working directory when it holds a project root marker: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `build.gradle.kts`, `*.csproj`, `*.sln`, `composer.json` or `Gemfile`.
3. Otherwise ask the user for the repo path and wait for it. Check that the path exists and is a directory; if not, say so and ask again.

Done when the repo root is known.

## 2. Copy the references

Create `<repo>/docs/project-manifest/` if missing. Compare every file in `references/` with its namesake in `<repo>/docs/project-manifest/`, treating CRLF and LF line endings as equal:

- **Missing**: copy it in. Outcome: created.
- **Identical**: leave it. Outcome: unchanged.
- **Diverged**: hold it for one batch question.

Also list any files in `<repo>/docs/project-manifest/` that have no namesake in `references/`, other than `design-system.md` and `project-structure.md` (both are repo-specific). These are stale: renamed or dropped from the current standards, or added by the user.

If there are diverged or stale files, ask once about all of them:

- Diverged: "`<names>` differ from the plugin's current versions. Each may be an older copy from a previous install or your own edits. For each: overwrite, keep the repo version, or show diff?"
- Stale: "`<names>` are not part of the current standards. For each: delete or keep?"

Apply each answer per file. For each file answered "show diff", show its diff, then ask overwrite or keep for that file. A diverged or stale file may be a deliberate customization, so the repo version stands until the user picks overwrite or delete.

Done when every reference file has an outcome (created, unchanged, overwritten or kept) and every stale file is deleted or kept.

## 3. Ask about the design system

When `<repo>/docs/project-manifest/design-system.md` does not exist, ask once: "Do you have a design system to register? Share URLs (Figma, hosted docs, Claude Design artifact links) or saved Claude Design names. Reply `skip` if none."

When it exists, ask once, listing its current sources: "Your design system lists: `<sources>`. Reply with entries to add to these, `replace` followed by entries to start the list over, `remove` to delete `design-system.md`, or `skip` to keep it as is."

Each entry becomes one `- <entry>` line, verbatim, under Sources. Record the entries only; the sources themselves hold the tokens.

- **Entries supplied, file absent**: write `design-system.md` from `templates/design-system.md` (beside this file), replacing the template's `- <entry>` placeholder line with the entry lines. The placeholder never appears in the written file.
- **Entries supplied, file exists**: append the entries under its existing Sources, skipping any already listed, and remove a leftover `- <entry>` placeholder line if one is there. Leave the rest of the file untouched.
- **`replace` with entries**: rewrite `design-system.md` from the template the same way, with only the new entries in place of the placeholder.
- **`remove`**: delete `design-system.md`.
- **`skip` or empty reply**: leave `design-system.md` as it is, existing or absent.

Done when the user has answered and `design-system.md` holds exactly the sources they chose, or is absent.

## 4. Register in CLAUDE.md

Pick the target file:

- `<repo>/CLAUDE.md` if it exists.
- Otherwise `<repo>/.claude/CLAUDE.md` if it exists.
- Otherwise, if `<repo>/AGENTS.md` exists, ask whether to add the block there or create `<repo>/CLAUDE.md`.
- Otherwise create `<repo>/CLAUDE.md`.

Below, `CLAUDE.md` means the target file. If it exists, keep a copy of it before editing. Write the block in `templates/claude-md-standards.md` (beside this file) verbatim into `CLAUDE.md`, except omit its design-system bullet (both lines) when `docs/project-manifest/design-system.md` does not exist.

A `## Standards` section is a line reading exactly `## Standards`, outside a fenced code block, and everything after it up to, but not including, the next level-1 or level-2 heading (a line starting `# ` or `## `, not `###`) outside a fenced code block, or end of file.

Placement:

- **No `## Standards` section**: append the block at the end.
- **One `## Standards` section** (ours, or one from the earlier `cs-dev-standards` plugin): replace it.
- **More than one `## Standards` section**: replace the first. Show the user the others and ask whether to remove them; remove only the ones they approve.

Done when the first `## Standards` section in `CLAUDE.md` matches the block, any other `## Standards` sections are removed or kept per the user's answer, and comparing against the saved copy shows every other line untouched (a newly created `CLAUDE.md` has no other lines).

## 5. Report

Tell the user in a few lines:

- Each reference file's outcome, and each stale file's outcome.
- Whether `design-system.md` was written, updated, kept, removed or absent, and whether its pointer is in `CLAUDE.md`.
- Which file the Standards block went into.
- The files in `docs/project-manifest/` are theirs to edit; a re-run asks before replacing or deleting any of them. One thing is not protected: the first `## Standards` section in `CLAUDE.md` is replaced on every run.
- Branch protection, hooks and required checks are manual; the plugin's checklist is at https://github.com/ChetanS07/architect/blob/main/docs/repo-setup.md.
