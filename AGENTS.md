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
| Parent incubator | `kedoupi/skills` | schema, template, meta skill, catalog |
| Product skill | `kedoupi/<name>-skill` | one publishable skill package |

Schema baseline: [`schema/skill-repo.md`](./schema/skill-repo.md).

## Naming

| Concept | Pattern | Example |
| --- | --- | --- |
| Skill package (`SKILL.md` `name`) | `<name>` kebab-case | `lark-push` |
| GitHub repo + submodule directory | `<name>-skill` | `lark-push-skill` |
| Install | `npx skills add kedoupi/<name>-skill` | `npx skills add kedoupi/lark-push-skill` |
| Package path inside child repo | `skills/<name>/` | `lark-push-skill/skills/lark-push/` |

If the user says a name already ending in `-skill`, that is the **repo dir**;
the package name is the prefix without `-skill`.

Published products (SoT for agents: **root `README.md` catalog**; keep this table short):

| Package | Repo/dir | Install |
| --- | --- | --- |
| `lark-push` | `lark-push-skill` | `npx skills add kedoupi/lark-push-skill` |
| `tzai-image` | `tzai-image-skill` | `npx skills add kedoupi/tzai-image-skill -g --all` |

### Catalog rule (**hard**)

Root `README.md` **Published skills** is the incubator **directory**.  
**Any add / public version change** of a product skill **must** update that catalog
(package name, **version = SKILL.md**, one-line purpose, install).  
Also bump this table when a skill is added or removed.

```bash
bash scripts/check-catalog   # FAIL if disk skill missing or version stale in README
bash scripts/doctor          # includes catalog check
```

Release flow without catalog update is **incomplete** (schema: `schema/skill-repo.md` § Parent catalog).

## Layout

```text
Skills/                              # parent git: kedoupi/skills
├── AGENTS.md                        # THIS FILE
├── CLAUDE.md
├── README.md
├── .gitmodules                      # submodule registry
├── .agents/skills/skill-incubator/  # meta skill (not published)
├── schema/
├── scripts/
│   ├── new-skill.sh                 # scaffold → <name>-skill/
│   └── register-submodule.sh        # git submodule add
├── _template/
└── <name>-skill/                    # submodule → kedoupi/<name>-skill
    ├── AGENTS.md
    ├── skills/<name>/               # installable package
    └── tests/
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

6. **Catalog (mandatory for public):** update root `README.md` Published skills
   (name, version, purpose, install) + this file’s short table; run
   `bash scripts/check-catalog`.

## Editing an existing skill

1. `cd` into the submodule dir (`<name>-skill/`, e.g. `lark-push-skill/`).
2. Read that repo’s `AGENTS.md` + package `SKILL.md`.
3. Behavior change → bump `metadata.version`; docs-only → no bump.
4. Commit/push **inside the child**; then in parent:

   ```bash
   git add <name>-skill
   # if version/purpose changed for users:
   #   edit README.md Published skills + AGENTS.md table
   git add README.md AGENTS.md
   git commit -m "chore: bump <name>-skill (+ catalog if needed)"
   bash scripts/check-catalog
   ```

Inventory / health:

```bash
bash scripts/list-skills
bash scripts/check-catalog
bash scripts/doctor
# optional: Claude/Grok vendor discovery
bash scripts/link-agent-skills
```

## Release (per product skill)

1. In child: tests green, tag `vX.Y.Z`, push tag.
2. `npx skills add kedoupi/<name>-skill --list`
3. Parent: bump submodule pointer + **README catalog version** (+ AGENTS table).
4. `bash scripts/check-catalog` must pass before considering release done.

## Cross-skill conventions

- **SKILL.md**: under ~500 lines; strong `description` triggers; version is SoT
- **Config**: durable at `<skills-parent>/.skill-data/<name>/config.env`
- **Scripts**: `pwd -P`; minimize deps; bash + existing CLIs preferred
- **Dry-run**: offline / no side effects
- **CLI values**: may start with `-` (markdown lists)
- **Docs**: README English default + `README.zh-CN.md`
- **Commits**: Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- **Tests**: `tests/run.sh` offline before publish
- **Housekeeping**: no one-off debug scripts at incubator root; secrets never in packages
- **Parent vs child**: parent holds schema/meta; child holds one product skill
- **Catalog**: every product `*-skill` on disk must appear in root README with matching version

Full detail: [`schema/skill-repo.md`](./schema/skill-repo.md) § Parent catalog.

## Multi-agent file convention

| File | Role |
| --- | --- |
| **`AGENTS.md`** | Shared project contract (SoT) |
| **`CLAUDE.md`** | Thin Claude adapter only |
| **`README.md`** | Humans |

Never duplicate full rules in two agent files. Deeper skill-repo `AGENTS.md`
wins when working inside that submodule.
