# Folder Structure: Reference Scaffold

Reference only: this tree shows how the rules in `folder-structure.md` combine in a project at full size. Create folders and files by those rules, as the code needs them; the tree is a picture of the result, not a template to copy.

Shown: a `single-app` with a UI, its own server and its own data store, using default layer names. Comments describe what each file does; real file names follow Naming and tests in `folder-structure.md`.

```
<repo>/
├── <source root>/
│   ├── <composition>/                    # maps each route, event or command to a feature; no logic
│   │   ├── sign-in route                 # renders auth's sign-in form
│   │   ├── billing route                 # renders the invoice list
│   │   ├── billing API route             # wires invoices' handlers
│   │   └── app entry                     # starts the app, plugs shared adapters into ports
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── components/               # sign-in form
│   │   │   ├── state/                    # current session
│   │   │   ├── handlers/                 # sign in, sign out
│   │   │   ├── services/                 # sign in: checks credentials, starts a session
│   │   │   ├── logic/                    # password policy, with its test beside it
│   │   │   ├── data/                     # find user by email
│   │   │   └── <public surface>          # entry module; absent in explicit-paths mode
│   │   │
│   │   └── billing/
│   │       ├── invoices/                 # sub-feature
│   │       │   ├── components/           # invoice list, invoice detail
│   │       │   ├── state/                # list filters
│   │       │   ├── handlers/             # list invoices, record payment
│   │       │   ├── services/             # record payment: calls data/ and the payment port
│   │       │   ├── logic/                # late fee: values in, values out
│   │       │   ├── data/                 # overdue invoices query
│   │       │   └── types/                # invoice summary, payment request
│   │       ├── subscriptions/            # sub-feature
│   │       │   ├── components/           # plan picker
│   │       │   ├── services/             # change plan
│   │       │   ├── clients/              # payment provider's subscription API
│   │       │   ├── content/              # plan descriptions
│   │       │   └── config/               # trial length, plan limits
│   │       └── <public surface>          # one surface for both sub-features
│   │
│   ├── entities/                         # users, invoices, subscriptions: one file each
│   ├── shared/
│   │   ├── components/                   # button, input: each used by 2+ features
│   │   ├── lib/                          # data store client, env, logger
│   │   ├── middleware/                   # error handling, request logging
│   │   ├── ports/                        # payment gateway, mail sender: interfaces
│   │   └── adapters/                     # the real payment gateway and mail sender
│   └── testing/                          # fixtures, fakes for each port, test app factory
│
├── <migrations>/                         # generated from entities/, outside the source root
├── e2e/                                  # end-to-end tests
├── docs/{adr,project-manifest}/
├── GLOSSARY.md                           # auth, billing, invoice, subscription
└── <boundaries config>
```

Every layer folder above exists because its feature already holds two or more layers. A feature with one layer keeps its files flat, and each folder appears with its first file.

**Other shapes:**

- `multi-app`: each deployable gets its own copy of the `<source root>` tree under `apps/<deployable>/`, holding only the layers it uses (a frontend has no `entities/` or `data/`; it calls the backend through `clients/`). Shared request and response shapes go in `packages/contracts/`.
- `service`: drop `components/`, `state/` and `content/`.
- `content-site`: drop `entities/`, `data/` and `<migrations>/`; features can be named for their page.

**Other stacks:** swap default layer names for the stack's own, place framework-imposed folders where the framework requires them, and record both in `project-structure.md`.
