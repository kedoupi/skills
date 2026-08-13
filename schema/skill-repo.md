# Skill Repo Schema (incubator baseline)

> **Status:** living document. This is our current baseline derived from
> `lark-push` + [Agent Skills](https://agentskills.io/) + [skills CLI](https://skills.sh/).
> When we ingest external open-source schemas, diff them here under
> [references/](./references/) and fold agreed rules into this file.

## Purpose

**Parent incubator** (`kedoupi/skills`) holds the product registry, schema,
template, meta skill, generated catalog, and product repos as **git submodules**.

A **product repo** is one independently released unit named
`kedoupi/<name>-skill`. It has one primary skill and is explicitly one of:

| Type | Contract | Example |
| --- | --- | --- |
| `single` | Exactly one installable entrypoint | `lark-push` |
| `family` | One primary skill plus related entrypoints in the same release unit | `tzai-image` engine + generated facades |

```bash
npx skills add kedoupi/<name>-skill
```

| Concept | Pattern | Example |
| --- | --- | --- |
| Product id + primary `SKILL.md` name | `<name>` | `lark-push` |
| Child GitHub + submodule path | `<name>-skill` | `lark-push-skill` |
| Primary package path | `skills/<name>/` | `skills/lark-push/` |
| Family entrypoint path | `skills/<entrypoint>/` | `skills/tzai-icon/` |

**Meta vs product**

| Kind | Location | Published? |
| --- | --- | --- |
| **Product repo** | `<name>-skill/skills/…` (submodule child repo) | Yes (`npx skills add kedoupi/<name>-skill`) |
| **Meta skill** | `.agents/skills/skill-incubator/` on parent | **No** |
| **Parent** | `kedoupi/skills` | Not a skills.sh product; `products.json` is registry SoT + tooling |

Authoring flows: meta skill `SKILL.md`. Repo contract: this document. Product
identity/type/entrypoints: `products.json`.

**Example:** package `lark-push`, child repo `kedoupi/lark-push-skill`.

## Lifecycle

```text
idea / pain point
  → discuss with agent (scope, triggers, safety)
  → scaffold: scripts/new-skill.sh <name>     # → <name>-skill/
  → implement scripts + SKILL.md
  → offline tests
  → create GitHub kedoupi/<name>-skill + push child
  → scripts/register-submodule.sh <name>-skill
  → tag child + skills.sh (optional)
  → **MUST** update products.json when product facts changed
  → scripts/render-catalog
  → commit parent (submodule pointer + registry + generated catalog)
```

## Product registry and generated catalog (mandatory)

The incubator root **`products.json`** is the machine-readable product directory.
`README.md` → Published skills and the short `AGENTS.md` product table are generated
public/agent views. A product, entrypoint, submodule, or generated view that disagrees
with the registry is **incomplete**.

Registry schema: [`products.schema.json`](./products.schema.json). Decision record:
[`adr/0001-product-registry-and-skill-families.md`](./adr/0001-product-registry-and-skill-families.md).

### When registry/catalog MUST be updated

| Event | Catalog action |
| --- | --- |
| **Add** a product (first publish / first submodule) | Add registry object, type, primary, entrypoints, purpose, install |
| **Behavior release** | Primary `SKILL.md` remains version SoT; lockstep family entrypoints match it |
| **Add/remove family entrypoint** | Update registry `entrypoints` and regenerate views |
| **Rename / retire** | Update registry identity/status; do not leave orphan repos or entrypoints |
| Docs-only tweak inside child | No product version change required |

### What a catalog row needs

| Field | Required |
| --- | --- |
| Product id + primary skill | yes |
| Product type (`single` / `family`) | yes |
| Complete installable entrypoint list | yes |
| Entrypoint version policy (`lockstep` / `independent`) | yes |
| One-line purpose + install command | yes |
| Child repo `kedoupi/<name>-skill` | yes |

Version is read from the primary `SKILL.md`, not duplicated in `products.json`.
Generate both Markdown views with `bash scripts/render-catalog`; never hand-edit rows.

### Enforcement

```bash
bash scripts/render-catalog  # products.json + primary version → Markdown views
bash scripts/check-catalog   # registry ↔ packages ↔ .gitmodules ↔ generated views
bash scripts/doctor          # includes registry/catalog + layout
```

Agents **must not** finish a release or “add skill” task without registry/catalog + parent commit
(unless user explicitly says private / no catalog).

## Directory contract

### Parent incubator (`kedoupi/skills`)

```text
Skills/
├── .git/
├── .gitmodules
├── products.json
├── AGENTS.md / CLAUDE.md / README.md
├── .agents/skills/skill-incubator/
├── schema/
├── _template/
├── scripts/new-skill.sh
├── scripts/register-submodule.sh
└── <name>-skill/                 # git submodule
```

### Product skill child (`kedoupi/<name>-skill`)

```text
<name>-skill/                      # independent git repo (submodule path)
├── .git/
├── .gitignore
├── LICENSE                        # MIT recommended
├── README.md                      # English (default)
├── README.zh-CN.md                # Chinese (recommended)
├── AGENTS.md                      # agent rules for THIS skill (SoT for all agents)
├── CLAUDE.md                      # optional thin Claude adapter → @AGENTS.md
├── CONTRIBUTING.md
├── skills.sh.json                 # skills.sh grouping (optional but recommended)
├── skills/
│   ├── <name>/                    # primary installable package
│   │   ├── SKILL.md               # required — agent-facing definition
│   │   ├── config.example.env     # if skill needs durable config
│   │   ├── scripts/               # executables (pwd -P safe)
│   │   ├── references/            # optional long agent references
│   │   └── templates/             # optional body/prompt templates
│   └── <entrypoint>/              # family only; related facade/package
├── tests/                         # offline CI + optional live *specs*
│   ├── README.md                  # required when tests/ has more than run.sh
│   ├── run.sh                     # offline self-test (required for published skills)
│   ├── fixtures/                  # deterministic offline fixtures
│   └── live/<suite>/              # live evaluation specs only (text; no binaries)
├── docs/                          # human guides + curated gallery (optional tree)
│   ├── README.md                  # required when docs/ exists
│   ├── screenshots/               # curated README/gallery assets only
│   ├── architecture/              # design / roadmap (optional)
│   └── research/                  # external research notes (optional)
├── artifacts/                     # generated outputs (optional; not installable)
│   ├── README.md                  # required when artifacts/ exists
│   └── live/<suite>/<version>/    # e.g. pairs/ + report.md
├── scripts/                       # repo tooling (optional; not the skill package)
└── .github/workflows/ci.yml       # recommended
```

### Single vs family product repos

- `single`: `skills/` contains exactly the primary package.
- `family`: `skills/` contains the primary package plus every entrypoint listed in
  `products.json`; no unregistered installable package is allowed.
- `lockstep`: every entrypoint `metadata.version` matches the primary version.
- `independent`: entrypoints may version separately, but the primary version remains the
  product catalog version.
- A family is one release unit, not an excuse to combine unrelated products.

### docs / tests / artifacts (**hard separation**)

These three trees must not blur. SoT for agents: this section + `scripts/check-skill-layout`.

| Tree | Role | Network / paid | Installable? |
| --- | --- | --- | --- |
| **`skills/<entrypoint>/`** | What `npx skills add` installs | N/A | **Yes** |
| **`docs/`** | Human guides, architecture, **curated** gallery | No | No |
| **`tests/`** | Offline CI + **live case definitions** (prompts, rubrics, fixtures) | Offline required; live optional | No |
| **`artifacts/`** | **Generated** outputs (images, HTML dumps, live reports) | Often yes | No |

**Rules**

1. **Specs vs pixels:** live prompts/rubrics live under `tests/live/<suite>/`; generated images and run reports under `artifacts/live/<suite>/<version>/`.
2. **Gallery vs dumps:** `docs/screenshots/` is for README marketing/samples only — not raw A/B benchmark dumps.
3. **No binaries in tests:** do not store `.png` / `.jpg` / large media under `tests/`.
4. **No `docs/benchmarks/`:** deprecated; use `tests/live/` + `artifacts/live/`.
5. **Indexes:** if `docs/` exists → `docs/README.md`; if `artifacts/` exists → `artifacts/README.md`; if `tests/` has anything beyond `run.sh` → `tests/README.md`.
6. **Scratch:** local experiments → `artifacts/live/_scratch/` (gitignore recommended).
7. **Article/user content** (e.g. wechat drafts) belongs in the **user's project**, never under the skill package or incubator root.

**Enforcement**

```bash
bash scripts/check-skill-layout          # all product *-skill dirs
bash scripts/check-skill-layout lark-push-skill
bash scripts/doctor                      # includes layout + registry/catalog
```

### Forbidden / discouraged

| Don't | Why |
| --- | --- |
| Secrets only inside `skills/<name>/` | `npx skills update` wipes the package dir |
| Hardcoded chat ids / tokens / team bot names | Not portable |
| Relative links from installed package to repo-root README | Broken after install |
| `--dry-run` that requires live auth | Agents/CI/sandboxes can't preview |
| Full project rules duplicated in both `AGENTS.md` and `CLAUDE.md` | Files drift; agents disagree |
| Live PNGs under `docs/benchmarks/` or `tests/` | Breaks docs/tests/artifacts separation |
| Putting installable logic only under `scripts/` at repo root | CLI discovers `skills/<name>/` only |
### Multi-agent instruction files

| File | Role |
| --- | --- |
| **`AGENTS.md`** | **Source of truth** for all coding agents (Codex, Grok, Cursor, …) |
| **`CLAUDE.md`** | Optional thin Claude Code adapter: `@AGENTS.md` + Claude-only deltas |
| **`README.md`** | Humans (install/usage); not a substitute for `AGENTS.md` |

Put layout, commands, safety, and conventions only in `AGENTS.md`. Never maintain
two full copies. Incubator root follows the same pattern.

## `SKILL.md` frontmatter

```yaml
---
name: <skill-name>                 # kebab-case, matches directory
description: >-
  Use when the user asks to ...    # triggers + intent (critical for auto-invoke)
metadata:
  author: <github-handle>
  version: "0.1.0"                 # semver; source of truth for --version
  requires:
    bins: ["optional-cli"]
---
```

Body sections (recommended order):

1. One-paragraph behavior summary  
2. Prerequisites / auth  
3. **Onboarding** (when to ask for keys; install ≠ configure)  
4. Locating the helper  
5. Config (if any) — preferred path `~/.config/kedoupi/<name>/`  
6. Safety / confirmation rules  
7. Usage examples (include `--dry-run`)  
8. Key CLI options  
9. Troubleshooting  

Keep under ~500 lines; link out for long references.

**Onboarding rule:** Do not solicit secrets merely because the skill was installed.
Solicit only when the user’s request crosses a credential boundary (paid API, draft
push, chat send) or they ask for environment check. Always offer a **copy-paste
`init` command** and a zero-config degrade path. Detail:
[`references/durable-config.md`](./references/durable-config.md) § Onboarding.

## Config schema (when needed) — **kedoupi brand + open-source**

Secrets and durable settings **never** live only inside the installable package
(`npx skills update` wipes it). Prefer **config files** over editing the user's
shell profile / global environment.

### What goes where

| Kind | Location | Notes |
| --- | --- | --- |
| Skill package (code) | `~/.agents/skills/<name>/` (or agent vendor paths) | Install via `npx skills add` — **not** under `~/.config` |
| **Recommended config** | `~/.config/kedoupi/<name>/config.env` | Brand + XDG; default `init` target |
| Extra files (style, etc.) | `~/.config/kedoupi/<name>/…` | e.g. `style.yaml` |
| Legacy suite durable | `~/.agents/skills/.skill-data/<name>/config.env` | Still **read**; may auto-migrate once |
| Install-adjacent durable | `<skills-parent>/.skill-data/<name>/config.env` | Still **read** |
| Per-skill XDG legacy | `~/.config/<name>/config.env` | Still **read** |
| In-package local | `<skill-root>/config.local.env` | Optional; wiped on update |
| User content / history | Project CWD (e.g. `./wechat-mp-out/`) | Never incubator root |

```text
~/.config/kedoupi/
  lark-push/config.env
  tzai-image/config.env
  wechat-mp/config.env
  wechat-mp/style.yaml
```

### Load order (later wins)

1. `~/.config/<name>/config.env` (legacy XDG)
2. `~/.agents/skills/.skill-data/<name>/config.env`
3. `<skills-parent>/.skill-data/<name>/config.env`
4. **`~/.config/kedoupi/<name>/config.env`** (recommended — wins among stock files)
5. `<skill-root>/config.local.env` (wiped on update)
6. `$<PREFIX>_CONFIG` explicit file path
7. Process environment / CLI flags (optional override for CI; **do not** teach users to put secrets in `~/.zshrc`)

### Auto-migrate (once)

On `doctor` / `init` only (before write). `load`, `dry-run`, and `which-config` must stay side-effect free:

- If **`~/.config/kedoupi/<name>/config.env` is missing**, and any **legacy config file** exists with content → **copy** that file to the kedoupi path (`chmod 600`), print one stderr line.
- **Only copy from existing config files** — never rewrite the user's global shell environment.
- Prefer standard public keys only (`LARK_PUSH_*`, `TZAI_*`, `WECHAT_MP_*`, …). Do not invent private host-only names as the open-source API.

### `init` must

- Default **`--target kedoupi`** → `~/.config/kedoupi/<name>/config.env`
- Still support `--target durable|global|local` for power users / tests
- `chmod 600`
- Quote values safely (`printf '%q'` or allowlisted KEY=value writer)
- Support `--force`
- Document keys in `config.example.env` with the **public** prefix only

### Env var naming (public)

| Rule | Example |
| --- | --- |
| Prefix = screaming package name | `lark-push` → `LARK_PUSH_*` |
| | `tzai-image` → `TZAI_*` (engine family) |
| | `wechat-mp` → `WECHAT_MP_*` |
| Explicit config path | `LARK_PUSH_CONFIG`, `TZAI_IMAGE_CONFIG`, `WECHAT_MP_CONFIG` |

Agents **must not** mutate the user's shell rc files to “make it work”. Use `init` + kedoupi config files.

Full narrative for authors: [`schema/references/durable-config.md`](./references/durable-config.md).

## Script schema

- Shebang + `set -euo pipefail`
- Resolve root with `pwd -P` from `BASH_SOURCE`
- Subcommands: `init`, `config-path`, `which-config`, `version` (when configful)
- Prefer a `doctor` checklist that prints install hints when deps / config are missing
- `--dry-run` = local preview only when side effects exist
- Option values may start with `-` (markdown lists); never treat `-*` as missing
- Minimize deps (prefer bash + existing CLIs; python3 only when necessary)
- Version printed from `SKILL.md` `metadata.version`
- Missing CLI deps should fail with a copy-pasteable install command

## Safety schema

For any skill that sends messages, mutates shared systems, or spends money:

- Confirm target, content, and identity before real action
- User running the helper script counts as approval
- Agent-driven sends should prefer explicit user confirmation unless the user just ran the command

## Test schema (minimum for publish)

`tests/run.sh` must pass offline:

- `bash -n` on shell scripts
- `python3 -m py_compile` when python exists
- `--help` / `--version` smoke
- `--dry-run` happy path
- at least one edge case (e.g. leading `-` body, missing required config)

### Live evaluation (optional)

When a skill needs paid/live quality checks (images, remote APIs):

| Item | Location |
| --- | --- |
| Case table / prompts | `tests/live/<suite>/cases.tsv` (or `.md`) |
| Scoring rubric | `tests/live/<suite>/rubric.md` |
| Outputs + report | `artifacts/live/<suite>/<version>/` |
| Runner (optional) | repo `scripts/run-live-compare.sh` or suite-specific |

Live suites must not be required for default `tests/run.sh` (CI offline).
## skills.sh.json (optional)

```json
{
  "$schema": "https://skills.sh/schemas/skills.sh.schema.json",
  "groupings": [
    {
      "title": "<Category>",
      "description": "<one line>",
      "skills": ["<skill-name>"]
    }
  ]
}
```

## Versioning & release

- Semver in `SKILL.md`
- Conventional Commits preferred
- Tag `vX.Y.Z` on publish
- Register first publication in `products.json`; run `scripts/render-catalog`

## Evolving this schema

1. Drop reference material under `schema/references/<source>/`
2. Note deltas in `schema/references/CHANGELOG.md`
3. Promote agreed rules into **this file**
4. Update `_template/` and `scripts/new-skill.sh` in the same change

We deliberately keep one human-readable source of truth here rather than forcing
a rigid JSON Schema until external schemas are reviewed.
