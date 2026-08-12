# AGENTS.md

Guidance for **any** AI coding agent working in this skill incubator
(Claude Code, Codex, Cursor, Grok Build, OpenCode, …).

This file is the **source of truth**. Tool-specific stubs (e.g. `CLAUDE.md`)
should point here instead of duplicating rules.

## Purpose

Collection of installable [Agent Skills](https://agentskills.io/) published via
`npx skills add`. The **parent** repo is the incubator; each **product skill**
is a separate GitHub repository registered as a **git submodule**.

| Layer | GitHub | Role |
| --- | --- | --- |
| Parent incubator | `kedoupi/skills` | registry, schema, template, meta skill, generated catalog |
| Product repo | `kedoupi/<name>-skill` | one release unit: a single skill or a skill family |

Machine registry: [`products.json`](./products.json). Schema baseline: [`schema/skill-repo.md`](./schema/skill-repo.md).

## Naming

| Concept | Pattern | Example |
| --- | --- | --- |
| Skill package (`SKILL.md` `name`) | `<name>` kebab-case | `lark-push` |
| GitHub repo + submodule directory | `<name>-skill` | `lark-push-skill` |
| Install | `npx skills add kedoupi/<name>-skill` | `npx skills add kedoupi/lark-push-skill` |
| Primary package path | `skills/<name>/` | `lark-push-skill/skills/lark-push/` |
| Optional family entrypoints | `skills/<entrypoint>/` | `tzai-image-skill/skills/tzai-icon/` |

If the user says a name already ending in `-skill`, that is the **repo dir**;
the package name is the prefix without `-skill`.

Published products are registered in **`products.json`**. This short table and the
README catalog are generated views; do not edit their rows by hand.

<!-- BEGIN GENERATED PRODUCT TABLE -->
| Product / primary skill | Type | Repo/dir | Entrypoints | Install |
| --- | --- | --- | ---: | --- |
| `lark-push` | `single` | `lark-push-skill` | 1 | `npx skills add kedoupi/lark-push-skill` |
| `tzai-image` | `family` | `tzai-image-skill` | 18 | `npx skills add kedoupi/tzai-image-skill -g --all` |
| `wechat-mp` | `single` | `wechat-mp-skill` | 1 | `npx skills add kedoupi/wechat-mp-skill` |
<!-- END GENERATED PRODUCT TABLE -->

### Catalog rule (**hard**)

`products.json` is the product directory SoT; root `README.md` **Published skills** is
its public generated view. Any add / retire / entrypoint change updates the registry.
A primary `SKILL.md` version change updates the generated tables.

```bash
bash scripts/render-catalog  # update README + AGENTS views
bash scripts/check-catalog   # registry ↔ disk ↔ submodules ↔ generated views
bash scripts/doctor          # includes catalog check
```

Release flow without registry/catalog validation is **incomplete** (schema: `schema/skill-repo.md` § Product registry).

## Layout

```text
Skills/                              # parent git: kedoupi/skills
├── AGENTS.md                        # THIS FILE
├── CLAUDE.md
├── README.md
├── products.json                    # product registry SoT
├── .gitmodules                      # submodule checkout registry
├── .agents/skills/skill-incubator/  # meta skill (not published)
├── schema/                          # SoT: skill-repo.md (incl. docs/tests/artifacts)
├── scripts/
│   ├── new-skill.sh                 # scaffold → <name>-skill/
│   ├── register-submodule.sh
│   ├── check-catalog                # registry + generated views
│   ├── render-catalog
│   ├── check-skill-layout           # docs / tests / artifacts separation
│   └── doctor                       # includes catalog + layout
├── _template/
└── <name>-skill/                    # submodule → kedoupi/<name>-skill
    ├── skills/<name>/               # primary package
    ├── skills/<entrypoint>/         # family facades only (optional)
    ├── tests/                       # offline CI + live *specs*
    ├── docs/                        # guides + curated screenshots
    └── artifacts/                   # generated outputs (optional)
```

**docs / tests / artifacts** (hard separation — full rules in
[`schema/skill-repo.md`](./schema/skill-repo.md)):

| Tree | Holds | Not for |
| --- | --- | --- |
| `skills/` | Installable package | Benchmark dumps |
| `docs/` | Guides, architecture, curated `screenshots/` | Raw live A/B pixels |
| `tests/` | `run.sh`, fixtures, `live/<suite>/` prompts | PNG / media binaries |
| `artifacts/` | Paid/live outputs + reports | Skill source of truth |

```bash
bash scripts/check-skill-layout
bash scripts/doctor
```

## Incubator workflows (meta skill)

```text
.agents/skills/skill-incubator/SKILL.md
```

Triggers: 新建 skill / scaffold / 改 skill / bump / release / 孵化器.

- Contract SoT: [`schema/skill-repo.md`](./schema/skill-repo.md)
- Scaffold: `bash scripts/new-skill.sh <name>`
- Register submodule: `bash scripts/register-submodule.sh <name>-skill`
- Meta skill is **project-local** — not published via `npx skills add`

Optional discovery for agents that only scan vendor dirs (symlink, do not copy):

```bash
bash scripts/link-agent-skills
# creates .claude/skills/skill-incubator and .grok/skills/skill-incubator
# → ../../.agents/skills/skill-incubator
```

## Creating a new skill

Prefer **skill-incubator → New skill**. Short form:

1. Align: problem, triggers, safety, deps, publish or private.
2. Scaffold:

   ```bash
   bash scripts/new-skill.sh <name> [--author kedoupi]
   # creates ./<name>-skill/ with package skills/<name>/
   ```

3. Implement package + docs; `bash <name>-skill/tests/run.sh`.
4. Create GitHub repo `kedoupi/<name>-skill`, push child.
5. Register:

   ```bash
   bash scripts/register-submodule.sh <name>-skill
   ```

6. **Registry (mandatory for public):** add the product to `products.json`, run
   `bash scripts/render-catalog`, then `bash scripts/check-catalog`.

## Editing an existing skill

1. `cd` into the submodule dir (`<name>-skill/`, e.g. `lark-push-skill/`).
2. Read that repo’s `AGENTS.md` + package `SKILL.md`.
3. Behavior change → bump `metadata.version`; docs-only → no bump.
4. Commit/push **inside the child**; then in parent:

   ```bash
   git add <name>-skill
   # if product purpose/entrypoints changed: edit products.json first
   bash scripts/render-catalog
   git add products.json README.md AGENTS.md
   git commit -m "chore: bump <name>-skill (+ generated catalog if needed)"
   bash scripts/check-catalog
   ```

Inventory / health:

```bash
bash scripts/list-skills
bash scripts/render-catalog --check
bash scripts/check-catalog
bash scripts/check-skill-layout
bash scripts/doctor
# optional: Claude/Grok vendor discovery
bash scripts/link-agent-skills
```

## Release (per product skill)

1. In child: tests green, tag `vX.Y.Z`, push tag.
2. `npx skills add kedoupi/<name>-skill --list`
3. Parent: bump submodule pointer; run `bash scripts/render-catalog`.
4. `bash scripts/check-catalog` must pass before considering release done.

## Cross-skill conventions

- **SKILL.md**: under ~500 lines; strong `description` triggers; version is SoT
- **Config**: recommended `~/.config/kedoupi/<name>/config.env` (brand+XDG); legacy `.skill-data/` still read + one-shot migrate. Public keys only (`LARK_PUSH_*` / `TZAI_*` / `WECHAT_MP_*`). Never rewrite the user's shell environment. See `schema/references/durable-config.md`
- **Scripts**: `pwd -P`; minimize deps; bash + existing CLIs preferred
- **Dry-run**: offline / no side effects
- **CLI values**: may start with `-` (markdown lists)
- **Docs**: README English default + `README.zh-CN.md`
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- **Tests**: `tests/run.sh` offline before publish
- **Housekeeping**: no one-off debug scripts at incubator root; secrets never in packages
- **Parent vs child**: parent holds registry/schema/meta; each child is one release unit (`single` or `family`)
- **Catalog**: every product and installable entrypoint must match `products.json`; README/AGENTS tables are generated
- **Layout**: `docs/` / `tests/` / `artifacts/` separation; no media under `tests/`; no `docs/benchmarks/`
Full detail: [`schema/skill-repo.md`](./schema/skill-repo.md) § Product registry.

## Multi-agent file convention

| File | Role |
| --- | --- |
| **`AGENTS.md`** | Shared project contract (SoT) |
| **`CLAUDE.md`** | Thin Claude adapter only |
| **`README.md`** | Humans |

Never duplicate full rules in two agent files. Deeper skill-repo `AGENTS.md`
wins when working inside that submodule.
