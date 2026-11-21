# Branch conventions

Branch naming and size rules for the workflow in [`branching-and-pr.md`](../branching-and-pr.md). Terms (`<default>`, hard stop) are defined there.

## Names

`<type>/<short-description>`: lowercase, hyphen-separated, under 40 characters. Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`. Examples: `feat/add-login`, `fix/cart-redirect`.

## Size

Size is insertions plus deletions against `<default>`, leaving out lockfiles and generated files. Pass each one as an exclude pathspec:

```
git diff --shortstat origin/<default>...HEAD -- . ':(exclude)package-lock.json' ':(exclude)dist/**'
```

Generated files are those marked `linguist-generated` in `.gitattributes`, plus build output you can see is generated.

Measure after every push (step 5), not only at the end. Aim under 1000 lines. Past 1000, tell the human the branch is getting large. Past 1500 is a hard stop: stop work and ask the human whether and how to split. The usual split is to move independent pieces onto their own branches off `<default>`, each with its own PR. If later pieces depend on earlier ones, let the human choose between stacking them and landing them in order.
