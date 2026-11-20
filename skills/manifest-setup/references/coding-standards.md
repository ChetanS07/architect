# Coding Standards

Applies to new and changed code. Don't rewrite unrelated code to comply.
If a rule needs breaking, say why in a comment.

## Approach

### 1. Think before coding

Don't assume. Don't hide confusion. Surface tradeoffs.

- State assumptions explicitly. If uncertain, ask rather than guess.
- Present multiple interpretations when ambiguity exists — don't pick one
  silently.
- Push back when a simpler approach exists.
- Stop when confused. Name what's unclear and ask.

### 2. Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite it.

Test: would a senior engineer call this overcomplicated? If yes, simplify.

### 3. Surgical changes

Touch only what you must. Clean up only your own mess.

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- Notice unrelated dead code? Mention it, don't delete it.
- Remove imports, variables, and functions that your changes made unused.
  Leave pre-existing dead code alone unless asked.

Test: every changed line should trace directly to the user's request.

## Core (any language)

1. One module, one responsibility.
2. Name things for what they do. File naming: see folder-structure.md.
3. Keep functions short. Past about 50 lines, extract unless it reads
   worse. Tests, JSX and data tables are exempt.
4. Comments explain why, not what.
5. Validate at trust boundaries: API input, env vars, external files,
   cross-process messages. Unvalidated data never goes past the boundary.
6. Errors are typed and carry a stable code. Never throw or raise bare
   strings or generic errors. Codes are `UPPER_SNAKE_CASE`, defined once
   per feature, and never reused for a different meaning.
7. Runtime output goes through a leveled logger. CLI stdout and throwaway
   scripts are exempt.

## Security

- No secrets in code, config committed to the repo, or test fixtures. Read
  them from the environment or a secret store.
- Database queries are parameterized. Never build queries, shell commands
  or HTML by string concatenation with untrusted input.
- Never log secrets, tokens, passwords or personal data.

## Dependencies

- Prefer what's already installed and the standard library.
- Don't add a dependency without saying why in the PR description. Ask
  first if it is large, unmaintained, or duplicates one already present.
- Commit the lockfile with the change that alters it.

## Testing

- New logic gets a test. A bug fix gets a regression test.
- Test behaviour through the public interface.
- Test files are also exempt from the error rule (Core 6).

## TypeScript

- Strict mode. No `any` without
  `// eslint-disable-next-line @typescript-eslint/no-explicit-any -- <reason>`.
- Validate boundaries with Zod.
- Errors extend `Error` with a `.code: string` field.
- Named exports only, except where a framework or tool requires a default.
- Every promise is awaited, returned, or explicitly ignored with `void`.
- Prettier and ESLint configs live at the repo root.
- Import order: builtins, external, internal.

## Other languages

No language section yet. Use the ecosystem's standard formatter, linter
and boundary-validation library (for example Ruff and Pydantic for
Python, `gofmt` and `go vet` for Go). Where the repo already has a
choice, follow it. Core rules still apply.

## Enforcement

Lint and typecheck must pass before commit. If tooling can check a rule,
tooling owns it; don't re-check it by hand.

## Agents

A file is human-owned when a comment in its first 5 lines contains
`@human-edited`. Don't edit, regenerate, move or delete it; stop and ask.
