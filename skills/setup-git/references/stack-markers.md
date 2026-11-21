# Stack markers

Used by step 2 of `SKILL.md`. Each marker found at the repo root selects a gitignore block in `templates/gitignore/`. When you add a block there, add its marker row here and its name to the list of options at the end.

| Marker | Block |
| --- | --- |
| `package.json` | `node` |
| `next.config.js`, `next.config.mjs`, `next.config.ts`, or `next` in `package.json` dependencies | `nextjs` (and `node`) |
| `nuxt.config.ts`, `nuxt.config.js`, or `nuxt` in `package.json` dependencies | `nuxt` (and `node`) |
| `svelte.config.js` together with `@sveltejs/kit` in `package.json` dependencies | `sveltekit` (and `node`) |
| `remix.config.js`, `react-router.config.ts`, or any `@remix-run/*` or `@react-router/dev` package in `package.json` dependencies | `remix` (and `node`) |
| `angular.json`, or `@angular/core` in `package.json` dependencies | `angular` (and `node`) |
| `astro.config.mjs`, `astro.config.ts`, or `astro` in `package.json` dependencies | `node` only: its `dist/` and `.astro/` are already there |
| `vue` in `package.json` dependencies (without Nuxt) | `node` only: its Vite and Cypress output is already there |
| `pyproject.toml`, `requirements.txt`, `setup.py`, `Pipfile` | `python` |
| `go.mod` | `go` |
| `Cargo.toml` | `rust` |
| `pom.xml`, `build.gradle`, `build.gradle.kts` | `java` |
| `*.csproj`, `*.sln` | `dotnet` |
| `composer.json` | `php` |
| `Gemfile`, `*.gemspec` | `ruby` |
| `pubspec.yaml` | `dart` |
| `Package.swift`, `*.xcodeproj`, `*.xcworkspace`, `Podfile` | `swift` |
| `AndroidManifest.xml` anywhere in the tree, or a Gradle file applying `com.android` | `android` (and `java`) |
| `CMakeLists.txt`, `meson.build`, `conanfile.txt`, `conanfile.py`, `vcpkg.json`; or a `Makefile` beside `*.c`/`*.cpp` files | `cpp` |
| `mix.exs` | `elixir` |
| `build.sbt` | `scala` |
| `stack.yaml`, `*.cabal`, `cabal.project` | `haskell` |
| `build.zig`, `build.zig.zon` | `zig` |
| `deno.json`, `deno.jsonc` | `deno` |
| `DESCRIPTION` with a `Package:` field, `*.Rproj`, `renv.lock` | `r` |
| `*.ipynb` | `jupyter` |
| `ProjectSettings/ProjectVersion.txt` | `unity` (not `dotnet`: Unity generates `*.csproj` and `*.sln`) |
| `*.uproject` | `unreal` |

## Options to offer when no stack is detected

node (also for Astro and Vue), nextjs, nuxt, sveltekit, remix, angular, python, go, rust, java, dotnet, php, ruby, dart (Flutter), swift, android, cpp, elixir, scala, haskell, zig, deno, r, jupyter, unity, unreal, or none.
