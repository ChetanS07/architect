# Project Folder Structure

**Feature-first beats type-first.** Group files by the business capability they serve (auth, billing, dashboard), not by file type (components, controllers, utils). Type-first layouts give every new file a global bucket to dump into. Feature-first forces "what does this belong to?" before "what kind of file is it?"

These rules hold for any language and framework, in applications. Libraries and CLIs follow only Naming and tests.

## Vocabulary

- **Deployable**: anything built and shipped on its own: web app, API, worker, mobile or desktop app.
- **Composition**: the code the framework calls first: entry points, routing, dependency wiring, wherever the framework puts it (a routing folder, file-based routes, `main`, a URL config). Composition is **thin**: it maps a URL, event or command to a feature and holds no business logic.
- **Feature**: one business capability, named with its glossary term and describable as one noun phrase.
- **Layer**: one kind of code inside a feature, from the closed list in Feature layers.
- **Public surface**: the one part of a feature that code outside it may import. See Public surface.
- **Promote**: move code into `shared/` when a second feature needs it. Code stays in its feature until then.
- **Record**: write a repo-specific choice into `docs/project-manifest/project-structure.md` (create it on first use). Anything not recorded uses the defaults here.
- **Project shape**: what the repo ships.
  - `single-app`: one deployable with a UI (web, mobile or desktop), with or without its own server.
  - `multi-app`: two or more deployables in one repo, such as a frontend and an API.
  - `service`: one deployable with no UI: an API, worker or job runner.
  - `content-site`: a UI with no data store of its own.

## Where a new file goes

Use the first match:

1. Wires URLs, events or commands, or starts a process: composition.
2. Defines a table, collection or record type: `entities/`.
3. Request or response shape used by two or more deployables: `packages/contracts/`.
4. Infrastructure (data store client, env, logger, ports, adapters, middleware): `shared/`, from day one.
5. Supports tests: `testing/`.
6. Used by one feature: that feature's folder, in the layer that matches.
7. Domain-free helper that a second feature needs: promote it.
8. Behaviour owned by another feature: import it through that feature's public surface.

## Layout

```
<repo>/
├── apps/<deployable>/       # multi-app only: one per deployable
├── packages/contracts/      # multi-app only: shapes used by 2+ deployables; everything else is duplicated on purpose
├── <migrations>/            # generated, outside the source root
├── e2e/                     # tests across deployables
├── docs/{adr/,project-manifest/}
├── GLOSSARY.md              # source of feature names
└── <boundaries config>      # see Import direction

<source root>/               # one per deployable; at the repo root unless multi-app
├── <composition>/           # where the framework expects it
├── features/<feature>/
├── entities/                # only in a deployable that owns a data store
├── shared/<layer>/          # the feature layers, plus lib/, middleware/, ports/, adapters/
└── testing/                 # fixtures, fakes, test app factories
```

The source root is the stack's: `src/`, `internal/` in Go, the top-level package in Python, `src/main/<lang>/<package>/` on the JVM. An existing repo with another root layout keeps it; record it. `shared/ports/` and `shared/adapters/` appear when an external service is worth swapping in tests.

**Framework-imposed folders.** When the framework requires a location (file-based routing, autoloaded model or controller folders, generated per-module folders), that requirement wins for those files only. Place every other file by these rules, group by feature inside the imposed folder where the framework allows it (a subfolder or namespace named for the feature), and record each exception.

**Scaffolding a project, or unsure of the repo's shape:** read `folder-structure-scaffold.md` beside this file, a reference tree of these rules at full size. It pictures the result; create folders and files by these rules, as the code needs them.

## Import direction

```
composition  →  features  →  entities  →  shared  →  contracts
```

- Each layer imports only from layers to its right.
- Features reach each other only through the public surface, with no cycles.
- `testing/` imports any layer. Production code imports `testing/` only from a test-built entry point.

A boundary checker enforces this: `eslint-plugin-boundaries`, `import-linter`, `depguard`, ArchUnit, NetArchTest, or the language's own visibility (Go `internal/`, Rust `pub(crate)`, C# `internal`). A rule that is not checked will drift.

## Feature layers

Each folder holds one layer. Layers come from this closed list, one name per role per repo. Where the stack has its own name for a role, use it and record the mapping.

| Folder        | Holds                                                                                          | Common stack names                         |
| ------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `components/` | UI: components, views, screens, templates                                                      | `views/`, `screens/`, `widgets/`           |
| `state/`      | Client-side UI state and reusable UI behaviour                                                 | `hooks/`, `composables/`, `stores/`, `viewmodels/` |
| `handlers/`   | Entry points into the feature: HTTP handlers, controllers, server actions, resolvers, RPC methods, message consumers, jobs | `controllers/`, `actions/`, `resolvers/`, `consumers/` |
| `services/`   | Orchestration and side effects                                                                 | `use-cases/`                               |
| `logic/`      | Pure rules                                                                                     | `domain/`, `rules/`                        |
| `data/`       | Queries against this deployable's own data store                                              | `repositories/`, `queries/`                |
| `clients/`    | Calls to external APIs, third-party services and other deployables                             | `gateways/`, `api/`                        |
| `content/`    | Static copy                                                                                    |                                            |
| `config/`     | Feature settings                                                                               |                                            |
| `types/`      | Types, schemas, DTOs, validation shapes                                                        | `schemas/`, `dto/`                         |

Any other folder inside a feature is a sub-feature.

**`services/` vs `logic/`:** a file that touches I/O, directly or through what it calls (data store, API, mail, clock, randomness), is a service, or `data/` or `clients/` if that is all it does. A file that only maps values in to values out is `logic/`, and imports only `logic/`, `types/` and pure `shared/` code.

**Layers appear on demand.** A feature with one layer keeps its files flat; once it holds two, each layer gets a folder, created with its first file. In stacks that favour one module per concern (Go, Python, Elixir), a layer can start as a single file named for it (`service.go`, `data.py`) and become a folder when it outgrows one file.

```
features/job-postings/{components,data,handlers,services}/
```

**Sub-features.** Split a feature when it holds two capabilities that do not import each other, or group features that share a prefix and depend on each other. Sub-features import each other directly; everything outside the parent uses the parent's public surface.

```
features/billing/{invoices,subscriptions}/{components,data}/
```

## Public surface

The boundary checker rejects imports into anything but a feature's public surface. Each deployable uses one of two modes; an ADR can override the default.

**Explicit paths** (default for a deployable that ships a client bundle). Features have no re-export files: in bundled clients they slow dev builds, weaken tree-shaking and can pull server code into the client. Other features import only from `components/`, `state/`, `services/` and `types/`; composition may also import `handlers/` to wire them. Anything needed from an internal layer is exposed through a function in `services/`. Server-only files carry the framework's server-only guard (for example the `server-only` package).

**Entry module** (default for every other deployable). The feature's language-level entry is its public surface: `index.ts`, `__init__.py`, a Go package's exported identifiers, a Rust module's `pub` items, or a public facade class with everything else package-private or `internal` on the JVM and .NET. In a deployable that also ships a client bundle, server-only exports go in a separate server entry behind the server-only guard. These entries are the only re-export files in the source root.

## Entities

- `entities/` holds data model definitions only: tables, collections, ORM models, record types, one file each, named for it (`jobPostings.ts`, `job_postings.py`). A grouping file exists only when the ORM requires a registry.
- Queries, rules and extra validation live in features. When the ORM attaches query methods or callbacks to models, feature-specific queries still go in that feature's `data/`.
- Relations are declared in the model that holds the foreign key; reverse relations live in the querying feature's `data/`.
- Migrations are generated from `entities/` where the stack generates them.

**Per-feature schemas.** A shared `entities/` fits a small team on one data store. When two or more people regularly conflict there, or features ship schema changes on different cadences, move to per-feature schemas in `features/<name>/data/schema/`: features reference each other's tables by id only, and cross-feature joins move to a composition-level query. Record an ADR and apply it to the whole deployable. Frameworks that tie models to modules (one models file per app or module) start on per-feature schemas.

## Naming and tests

- Folders: kebab-case. Where folder names are import names that disallow hyphens, follow the language's package rule (snake_case in Python, lowercase in Go and JVM packages).
- Files: the language's idiomatic case. UI components and classes use PascalCase where the language names files for their type (`ProfileCard.tsx`, `InvoiceService.java`); otherwise camelCase in JS/TS (`getUser.ts`), snake_case in Python, Ruby, Rust and Elixir, lowercase in Go. Role suffixes are fine where a role repeats (`billing.routes.ts`, `billing_routes.py`).
- Name each file for what it does (`formatCurrency.ts`). A **bucket** name (`utils`, `helpers`, `common`, `misc`, `index2`) means the purpose is not understood yet.
- Features use the glossary term on every tier. In a `content-site`, features with no capability behind them can be named for their page (`home`, `legal`).
- Tests sit beside the code in the stack's naming (`foo.test.ts`, `foo_test.go`, `test_foo.py`). Where the toolchain requires a separate test tree (Maven and Gradle `src/test/`, .NET test projects, Rust `tests/`), that tree mirrors the feature layout. Composition integration tests sit beside the route or entry point; cross-deployable tests go in `e2e/`.

## Repo choices

These bend to match an existing codebase, then lock for that repo once recorded: root layout and source root; framework-imposed folders; layer folder names; case conventions; test placement; and, per deployable, public surface mode and schema model. Every other rule here is fixed.

## Red flags

- A second layer is joining a folder, or a data store query and an external API call share one.
- A pure function is landing in `services/`, or I/O in `logic/`.
- Business logic in composition: a route file, controller registration, page or `main`.
- A bucket file name, or a feature that is not one noun phrase.
- Code promoted to `shared/` on its first use.
- An import reaches into another feature's internals, or two features import each other.
- A folder outside the layer list that is not a sub-feature, or two names for one layer role in the repo.
- A model definition in a feature outside per-feature schemas, or a query or rule in `entities/`.
- `shared/` or `entities/` importing from a feature, or production code importing `testing/`.
- A repo choice or framework-imposed exception that is not recorded.
- An empty layer folder or `.gitkeep` "for later".

**Done when** every file sits in a feature, `entities/`, `shared/<layer>/`, `testing/`, `packages/`, composition, a recorded framework-imposed folder or a repo-level folder; no red flag applies; and the boundary checker passes.
