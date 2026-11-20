# Branch conventions

Branch naming and size rules for the workflow in [`branching-and-pr.md`](../branching-and-pr.md). Terms (`<default>`, hard stop) are defined there.

## Names

`<type>/<short-description>`: lowercase, hyphen-separated, under 40 characters. Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`. Examples: `feat/add-login`, `fix/cart-redirect`.

## Size

Measure with `git diff --shortstat origin/<default>...HEAD`, excluding lockfiles and generated files. Aim under 1000 lines. Over 1500 is a hard stop: ask the human whether to split before marking the PR ready.
