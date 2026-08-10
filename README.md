# Skills

Personal **agent skill incubator**: design, polish, and publish installable skills
for multi-agent use (`npx skills add`).

| Layer | GitHub | What lives there |
| --- | --- | --- |
| **Parent** | [kedoupi/skills](https://github.com/kedoupi/skills) | schema, template, meta skill, catalog, **git submodules** |
| **Product skill** | `kedoupi/<name>-skill` | one installable package `skills/<name>/` |

Install a published product skill:

```bash
npx skills add kedoupi/<name>-skill
```

Clone this incubator (with all skill submodules):

```bash
git clone --recurse-submodules git@github.com:kedoupi/skills.git
# or later:
git submodule update --init --recursive
```

## Naming

| | Pattern | Example |
| --- | --- | --- |
| Package name | `<name>` | `lark-push` |
| Repo + directory | `<name>-skill` | `lark-push-skill` |
| Install | `npx skills add kedoupi/<name>-skill` | |

## How this incubator works

```text
idea
  → skill-incubator (or agent) aligns scope
  → bash scripts/new-skill.sh <name>     # → ./<name>-skill/
  → implement + bash <name>-skill/tests/run.sh
  → create GitHub kedoupi/<name>-skill + push
  → bash scripts/register-submodule.sh <name>-skill
  → (optional) tag + skills.sh + catalog
```

| Path | Role |
| --- | --- |
| [`schema/skill-repo.md`](./schema/skill-repo.md) | Living schema (layout, config, safety, tests) |
| [`_template/`](./_template/) | Product skill skeleton |
| [`scripts/new-skill.sh`](./scripts/new-skill.sh) | Scaffold `./<name>-skill/` |
| [`scripts/register-submodule.sh`](./scripts/register-submodule.sh) | `git submodule add` helper |
| [`scripts/list-skills`](./scripts/list-skills) | List product skill dirs / remotes |
| [`scripts/doctor`](./scripts/doctor) | Incubator health check |
| [`scripts/link-agent-skills`](./scripts/link-agent-skills) | Symlink meta skill for Claude/Grok |
| [`.agents/skills/skill-incubator/`](./.agents/skills/skill-incubator/) | Meta skill: create / edit / release |
| [`AGENTS.md`](./AGENTS.md) | Agent contract SoT |
| [`CLAUDE.md`](./CLAUDE.md) | Thin Claude adapter |
| `<name>-skill/` | **Submodule** → product GitHub |

### Multi-agent notes

Keep **one** shared contract in `AGENTS.md`. Tool stubs only point at it.
Each product submodule has its own `AGENTS.md` for skill-local rules.

### New skill

```bash
bash scripts/new-skill.sh my-feature
# creates my-feature-skill/ with skills/my-feature/
cd my-feature-skill
# edit package…
bash tests/run.sh
# create GitHub kedoupi/my-feature-skill, push, then from parent:
cd ..
bash scripts/register-submodule.sh my-feature-skill
```

### Schema evolution

1. Put references under `schema/references/<source>/`
2. Log deltas in `schema/references/CHANGELOG.md`
3. Promote rules into `schema/skill-repo.md` + `_template/`

## Published skills

| Skill package | Version | Repo (child) | Install | Docs |
| --- | --- | --- | --- | --- |
| `lark-push` | `1.3.0` | [kedoupi/lark-push-skill](https://github.com/kedoupi/lark-push-skill) | `npx skills add kedoupi/lark-push-skill` | [EN](https://github.com/kedoupi/lark-push-skill#readme) · [中文](https://github.com/kedoupi/lark-push-skill/blob/main/README.zh-CN.md) |
| `tzai-image` | `0.2.0` | [kedoupi/tzai-image-skill](https://github.com/kedoupi/tzai-image-skill) | `npx skills add kedoupi/tzai-image-skill` | [EN](https://github.com/kedoupi/tzai-image-skill#readme) · [中文](https://github.com/kedoupi/tzai-image-skill/blob/main/README.zh-CN.md) |

Package name stays `lark-push`; GitHub/submodule directory is `lark-push-skill`.

Each product skill is an independent public GitHub repository (submodule here)
following [Agent Skills](https://agentskills.io/) and this incubator’s schema.
