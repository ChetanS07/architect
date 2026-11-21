# architect

A Claude Code plugin that sets up a project and installs dev standards for coding agents: a git baseline with secret scanning, coding, branching and folder-structure standards registered in `CLAUDE.md`, and a connected GitHub repo.

## Skills

| Command | What it does |
|---------|--------------|
| `/architect` | Runs the three stages below in order, then reports what each one did. |
| `/git-setup` | Initializes git and adds `.gitattributes`, a stack-aware `.gitignore`, gitleaks secret scanning (config, pre-commit hook and a `secret-scan` GitHub Actions workflow), `.editorconfig` and `README.md`. Never commits. |
| `/manifest-setup` | Copies the standards into `docs/project-manifest/` and adds a `## Standards` section to `CLAUDE.md` so agents read the right file before the work it covers. Optionally registers a design system. Never commits. |
| `/github-setup` | Signs in to `gh`, picks or creates the GitHub repo, sets `origin`, restricts PRs to one merge method, then makes the first commit and push. |
| `/setup-ci` | Recommends CI checks, tests and builds from the stack in `docs/project-manifest/tech-stack-and-low-level-design.md` (or asks for the stack), loops on your changes until you approve the final list, then writes `.github/workflows/ci.yml`. Never commits. |

Every skill only adds what is missing and asks before replacing anything, so each is safe to re-run on its own. If `/architect` is interrupted, run it again or run the unfinished stage alone.

## Standards installed

`/manifest-setup` writes these to `docs/project-manifest/`:

- `branching-and-pr.md`: branch naming, commits and pull requests, with templates
- `coding-standards.md`: rules for writing and editing code
- `folder-structure.md` and `folder-structure-scaffold.md`: project layout, with a reference tree
- `design-system.md`: your design system sources, when you register any

The files are yours to edit; a re-run asks before overwriting one you changed.

## After running

Work through [`docs/repo-setup.md`](docs/repo-setup.md) to turn on branch protection and make the CI jobs plus `secret-scan` required checks. When the project's stack changes, re-run `/git-setup` to add the matching `.gitignore` blocks.

## License

MIT
