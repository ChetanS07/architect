<!-- git-setup: filling this template. Delete this whole comment from the written README.md.

Replace each placeholder:

- <project-name>: the `name` from the stack manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod` module path's last segment), else the root folder name.
- <description>: the manifest's description, else one line asking the reader to describe the project.
- <setup-commands>: the install command for the detected stack (`npm install`, `pip install -e .`, `go mod download`, `cargo build`, `composer install`, `bundle install`, `flutter pub get`, `swift build` or `pod install`, `./gradlew build`, `cmake -B build && cmake --build build`, `mix deps.get`, `sbt compile`, `stack build`, `zig build`, `renv::restore()`, and so on, matching the lockfile present), in a `sh` code block. Drop the placeholder when no stack was detected.
- <hooks-command>: the hook command recorded in the gitleaks step.
No <...> placeholder may remain in the written file.
-->
# <project-name>

<description>

## Getting started

<setup-commands>

Enable the repo's git hooks (once per clone):

```sh
<hooks-command>
```

The pre-commit hook runs [gitleaks](https://github.com/gitleaks/gitleaks) on staged changes. Install gitleaks to enable it.
