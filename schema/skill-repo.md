# Skill Repo Schema (incubator baseline)

> **Status:** living document. This is our current baseline derived from
> `lark-push` + [Agent Skills](https://agentskills.io/) + [skills CLI](https://skills.sh/).
> When we ingest external open-source schemas, diff them here under
> [references/](./references/) and fold agreed rules into this file.

## Purpose

**Parent incubator** (`kedoupi/skills`) holds schema, template, meta skill, and
registers each product skill as a **git submodule**.

**Product skill** repos are named `kedoupi/<name>-skill` and ship **one**
installable package via:

```bash
npx skills add kedoupi/<name>-skill
```

| Concept | Pattern | Example |
| --- | --- | --- |
| Package `name` in `SKILL.md` | `<name>` | `lark-push` |
| Child GitHub + submodule path | `<name>-skill` | `lark-push-skill` |
| Installable path in child | `skills/<name>/` | `skills/lark-push/` |

**Meta vs product**

| Kind | Location | Published? |
| --- | --- | --- |
| **Product skill** | `<name>-skill/skills/<name>/` (submodule child repo) | Yes (`npx skills add kedoupi/<name>-skill`) |
| **Meta skill** | `.agents/skills/skill-incubator/` on parent | **No** |
| **Parent** | `kedoupi/skills` | Not a skills.sh product; **catalog is SoT for published list** + tooling |

Authoring flows: meta skill `SKILL.md`. This file remains directory/contract SoT.

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
  → **MUST** update parent README catalog + AGENTS published list
  → commit parent (submodule pointer + catalog)
```

## Parent catalog (mandatory)

The incubator root **`README.md` → Published skills** is the **public directory** of
this monorepo. A skill that exists on disk / as a submodule but is missing or
stale in the catalog is **incomplete**.

### When catalog MUST be updated

| Event | Catalog action |
| --- | --- |
| **Add** a product skill (first publish / first submodule) | New row + short blurb + install command |
| **Behavior release** of a product skill (version bump users care about) | Update **Version** column (+ one-line if purpose changed) |
| **Rename / retire** a product skill | Rename row or mark retired; do not leave orphan entries |
| Docs-only tweak inside child | Catalog version optional (if version not bumped) |

### What a catalog row needs

| Field | Required |
| --- | --- |
| Package name (matches `SKILL.md` `name`) | yes |
| Version (matches package `metadata.version`) | yes (for published) |
| One-line purpose | yes |
| Child repo link `kedoupi/<name>-skill` | yes |
| Install command | yes |

Also keep root **`AGENTS.md`** published-products table in sync (shorter form is fine).

### Enforcement

```bash
bash scripts/doctor          # FAIL if disk *-skill missing from README catalog
bash scripts/check-catalog   # catalog-only check (same rules)
```

Agents **must not** finish a release or “add skill” task without catalog + parent commit
(unless user explicitly says private / no catalog).

## Directory contract

### Parent incubator (`kedoupi/skills`)

```text
Skills/
├── .git/
├── .gitmodules
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
│   └── <name>/                    # THE installable package (CLI discovers this)
│       ├── SKILL.md               # required — agent-facing definition
│       ├── config.example.env     # if skill needs durable config
│       ├── scripts/               # executables (pwd -P safe)
│       └── templates/             # optional body/prompt templates
├── tests/
│   └── run.sh                     # offline self-test (required for published skills)
├── docs/                          # optional screenshots / guides
└── .github/workflows/ci.yml       # recommended
```

### Forbidden / discouraged

| Don't | Why |
| --- | --- |
| Secrets only inside `skills/<name>/` | `npx skills update` wipes the package dir |
| Hardcoded chat ids / tokens / team bot names | Not portable |
| Relative links from installed package to repo-root README | Broken after install |
| `--dry-run` that requires live auth | Agents/CI/sandboxes can't preview |
| Full project rules duplicated in both `AGENTS.md` and `CLAUDE.md` | Files drift; agents disagree |

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
3. Locating the helper  
4. Config (if any)  
5. Safety / confirmation rules  
6. Usage examples (include `--dry-run`)  
7. Key CLI options  
8. Troubleshooting  

Keep under ~500 lines; link out for long references.

## Config schema (when needed)

Durable path (survives update):

```text
<skills-parent>/.skill-data/<skill-name>/config.env
```

Load order (later wins):

1. `~/.config/<skill-name>/config.env` (legacy optional)
2. `~/.agents/skills/.skill-data/<skill-name>/config.env` (shared global)
3. `<skills-parent>/.skill-data/<skill-name>/config.env` (install-local durable)
4. `<skill-root>/config.local.env` (wiped on update)
5. `$<ENV_PREFIX>_CONFIG` explicit file
6. CLI flags

`init` must:

- write durable config by default
- `chmod 600`
- shell-quote values (`printf '%q'`)
- support `--force`

Env var naming: `<SCREAMING_SKILL_NAME>_CHAT_ID` etc. (example: `LARK_PUSH_CHAT_ID`).

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
- Update incubator root `README.md` catalog when a skill is first published

## Evolving this schema

1. Drop reference material under `schema/references/<source>/`
2. Note deltas in `schema/references/CHANGELOG.md`
3. Promote agreed rules into **this file**
4. Update `_template/` and `scripts/new-skill.sh` in the same change

We deliberately keep one human-readable source of truth here rather than forcing
a rigid JSON Schema until external schemas are reviewed.
