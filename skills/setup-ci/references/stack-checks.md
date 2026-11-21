# Stack checks

Used by steps 3 and 4 of `SKILL.md`. Defaults per stack; the repo's own scripts and the user's answers override them.

## Baseline every stack gets

Recommend one job for each of these, skipping one only when the stack has no such tool and the user names none:

- `lint`: linter and formatter check (check mode, never rewriting files).
- `type-check`: static types or compile check.
- `test`: unit tests. Integration tests join this job, or get their own `integration-test` job when they need services.
- `build`: production build, binary or package.

These names match the required checks in `docs/project-manifest/repo-setup.md`. Secret scanning is git-setup's `secret-scan` workflow; recommend it only when that workflow is absent.

Then add the stack's extras below where the stack profile calls for them.

## Defaults per stack

| Stack | Setup action | Install | lint | type-check | test | build | Extras to recommend |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Node / TypeScript (npm, pnpm, yarn, bun) | `actions/setup-node` with `cache: <pm>` (bun: `oven-sh/setup-bun`) | `npm ci` / `pnpm install --frozen-lockfile` / `yarn install --immutable` / `bun install --frozen-lockfile` | `eslint .` or `biome ci .`; `prettier --check .` | `tsc --noEmit` | `vitest run` or `jest --ci` | the `build` script | Playwright or Cypress `e2e` job when present; `npm audit --audit-level=high` |
| Next.js, Nuxt, SvelteKit, Remix, Astro, Angular | as Node | as Node | framework lint (`next lint`, `ng lint`) or ESLint | `tsc --noEmit`; `svelte-check`; `nuxi typecheck` | as Node | `next build`, `nuxt build`, `vite build`, `ng build` | `e2e` against the built app |
| Python | `actions/setup-python` (uv: `astral-sh/setup-uv`) | `uv sync --frozen`, `poetry install`, or `pip install -r requirements*.txt` | `ruff check .` and `ruff format --check .` (or flake8 + black) | `mypy .` or `pyright` | `pytest` | `uv build` / `python -m build` for a package; none for an app | Django: `manage.py check` and `makemigrations --check`; `pip-audit` |
| Go | `actions/setup-go` with `go-version-file: go.mod` | `go mod download` | `golangci-lint run`; `gofmt -l .` empty | `go vet ./...` | `go test -race ./...` | `go build ./...` | `govulncheck ./...` |
| Rust | `dtolnay/rust-toolchain` with `clippy, rustfmt` | none | `cargo fmt --check`; `cargo clippy -- -D warnings` | covered by clippy | `cargo test` | `cargo build --release` | `cargo audit` |
| Java / Kotlin (Maven, Gradle) | `actions/setup-java` with `cache: maven` or `gradle` | wrapper resolves deps | `spotless:check` / `checkstyle` / `ktlint` when configured | compile is the check | `./mvnw verify` or `./gradlew test` | `./mvnw package` or `./gradlew build` | Android: `./gradlew lint assembleDebug` |
| .NET | `actions/setup-dotnet` | `dotnet restore` | `dotnet format --verify-no-changes` | compile is the check | `dotnet test` | `dotnet build -c Release --no-restore` | |
| PHP | `shivammathur/setup-php` | `composer install` | `php-cs-fixer fix --dry-run` or `phpcs` | `phpstan analyse` or `psalm` | `phpunit` or `pest` | none | Laravel: `php artisan test` |
| Ruby | `ruby/setup-ruby` with `bundler-cache: true` | via action | `rubocop` | `srb tc` or `steep check` when configured | `rspec` or `rails test` | none | `bundle audit`; Rails: `brakeman` |
| Dart / Flutter | `subosito/flutter-action` (Dart: `dart-lang/setup-dart`) | `flutter pub get` | `dart format --set-exit-if-changed .` | `flutter analyze` | `flutter test` | `flutter build <target>` | |
| Swift | macOS runner, Xcode preinstalled | `swift package resolve` | `swiftlint` | compile is the check | `swift test` or `xcodebuild test` | `swift build` | |
| C / C++ | none | system packages, Conan or vcpkg | `clang-format --dry-run --Werror` | compile with `-Wall -Werror` | `ctest` | `cmake -B build && cmake --build build` | |
| Elixir | `erlef/setup-beam` | `mix deps.get` | `mix format --check-formatted`; `mix credo` | `mix dialyzer` | `mix test` | `mix compile --warnings-as-errors` | |
| Deno | `denoland/setup-deno` | none | `deno lint`; `deno fmt --check` | `deno check` | `deno test` | none | |

A stack not in the table: build the same baseline from its standard tools, and mark any item you are not sure of `(assumed)`.

## Stack profile triggers

- **Services needed**: run the test job with `services:` containers (`postgres`, `mysql`, `redis`, ...) and pass connection details through `env:`.
- **Container image as build output**: add a `docker-build` job (`docker build .`) that builds without pushing.
- **Monorepo**: one job set per package, using the workspace tool's filter (`pnpm --filter`, `turbo run`, `nx affected`) or a `strategy.matrix` over package paths.
- **Several runtime versions supported**: a `strategy.matrix` over versions on the `test` job only.

## Workflow shape

```yaml
name: ci

on:
  pull_request:
    branches: [<default-branch>]
  push:
    branches: [<default-branch>]

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  <job-name>:            # one per final-list item, named as on the list
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<major>
      - <setup action with dependency cache>
      - <install>
      - run: <command>
```

- Trigger on every `pull_request` against the default branch, drafts included: give `pull_request` no `types:` filter and no `if:` on `draft`.
- Each job checks out and installs on its own, so jobs run in parallel and report as separate status checks.
- Read the runtime version from the repo's own pin (`.nvmrc`, `.python-version`, `go.mod`, `rust-toolchain.toml`, `global.json`) through the setup action's version-file input, when one exists.
