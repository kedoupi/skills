---
name: skill-incubator
description: >
  Use when working inside the Skills incubator (kedoupi/skills): create a new
  installable agent skill as a <name>-skill GitHub submodule, scaffold with
  new-skill.sh, register-submodule.sh, edit or fix an existing skill, bump
  versions, run offline tests, or prepare publish/release. Triggers: 新建 skill,
  创建 skill, scaffold, new-skill, 改 skill, 修改 skill, edit skill, bump version,
  release skill, publish skill, 孵化器, incubator, submodule, /skill-incubator.
  Not for end-user Feishu/Lark messaging (lark-push) and not for generic Grok-only
  ~/.grok skills.
metadata:
  version: "0.4.0"
---

# Skill Incubator

Project-local meta skill for the **parent** repo `kedoupi/skills`. Guides agents
that **author** product skills. **Not** published via `npx skills add`.

## Always

1. Resolve **incubator root**: contains `schema/`, `_template/`, `scripts/new-skill.sh`.
2. Contract SoT: [`schema/skill-repo.md`](../../../schema/skill-repo.md).
3. **Naming**
   - Package (`SKILL.md` name): `<name>` (e.g. `lark-push`)
   - GitHub + submodule dir: `<name>-skill` (e.g. `lark-push-skill`)
   - Install: `npx skills add kedoupi/<name>-skill`
   - Path: `<name>-skill/skills/<name>/`
4. Parent is git + **submodules**; each product skill is its own GitHub.
5. Scaffold only via `bash scripts/new-skill.sh …` (do not hand-copy `_template`).
6. Never ship this meta skill inside a product package.

Example product: package `lark-push` in submodule dir `lark-push-skill` (`kedoupi/lark-push-skill`).

Checklists: [references/checklist.md](./references/checklist.md).

## Route

| User intent | Section |
| --- | --- |
| 新建 / create / scaffold | [New skill](#new-skill) |
| 修改 / edit / bump | [Edit skill](#edit-skill) |
| 发布 / tag / publish | [Release skill](#release-skill) |
| 列表 / 健康检查 | [List & doctor](#list--doctor) |

## New skill

### 1. Align

- Triggers, side effects, deps, durable config, publish vs private
- Package `name` (kebab-case) + author (default `kedoupi`)

### 2. Validate

- Package name legal; reserved: `_template`, `schema`, `scripts`, `agents`, `docs`
- Neither `<name>` nor `<name>-skill` top-level dir should already exist

### 3. Scaffold

```bash
bash scripts/new-skill.sh <name> [--author kedoupi]
# → ./<name>-skill/ with skills/<name>/
```

### 4. Implement (inside `<name>-skill/`)

1. `skills/<name>/SKILL.md` — triggers + `metadata.version`
2. Scripts with `pwd -P`; offline dry-run if side effects
3. README EN + zh-CN; repo `AGENTS.md`; thin `CLAUDE.md`
4. `bash tests/run.sh` and `npx skills add ./ --list`

### 5. Publish child + register submodule

```bash
# create empty GitHub kedoupi/<name>-skill, then in child:
git remote add origin git@github.com:kedoupi/<name>-skill.git
git push -u origin main

# from incubator root:
bash scripts/register-submodule.sh <name>-skill
git push origin main   # parent, after user approves
```

### 6. Catalog (**mandatory**)

Parent root **`README.md` → Published skills** is the incubator **directory**.  
Incomplete if the skill ships but is missing/stale there.

```bash
# after submodule register / first public release:
# 1) add row: package | version | purpose | repo | install
# 2) short install blurb if non-trivial
# 3) sync AGENTS.md published-products table
# 4) verify:
bash scripts/check-catalog
bash scripts/doctor
```

Schema SoT: `schema/skill-repo.md` § **Parent catalog**.

## Edit skill

### 1. Locate

- Submodule path: `<name>-skill/` (e.g. `lark-push-skill/`)
- Read child `AGENTS.md` + `skills/<name>/SKILL.md`

### 2. Classify

| Kind | Action |
| --- | --- |
| Behavior | Code + bump package `metadata.version` + **catalog version** |
| Docs only | No version bump; catalog optional |
| Incubator-wide | `schema/` + `_template/` on **parent** |

### 3. Git (two repos)

```bash
# inside child submodule
git add … && git commit && git push

# parent: bump pointer + catalog when version/user-facing purpose changed
cd <incubator-root>
git add <name>-skill README.md AGENTS.md
git commit -m "chore: bump <name>-skill (+ catalog if needed)"
bash scripts/check-catalog
```

Confirm before any push.

## Release skill

1. Child: `bash tests/run.sh` green  
2. Version = tag `vX.Y.Z`; push tag on **child** remote  
3. `npx skills add kedoupi/<name>-skill --list`  
4. Parent: submodule pointer + **README catalog version** + AGENTS list  
5. `bash scripts/check-catalog` green, then parent commit/push  

**Do not** ship a release with only a submodule SHA bump and an outdated catalog.

## List & doctor

Prefer scripts (deterministic):

```bash
bash scripts/list-skills
bash scripts/check-catalog        # package dir ↔ README version
bash scripts/check-skill-layout   # docs / tests / artifacts separation
bash scripts/doctor               # includes catalog + layout
bash scripts/link-agent-skills    # optional Claude/Grok vendor symlinks
```

| Check | Expect |
| --- | --- |
| Parent git | `kedoupi/skills` |
| Schema / template / scripts | present + executable |
| Meta skill | `.agents/skills/skill-incubator/SKILL.md` |
| Product | dir ends with `-skill`, package under `skills/<name>/` |
| Catalog | every product package listed in README with matching version |
| Layout | `docs/` · `tests/` · `artifacts/` separation (`schema/skill-repo.md`) |

## Safety

- Confirm before `git push`, tag, or GitHub create on parent or child
- No secrets in packages; no `rm -rf` product dirs without explicit ask
- Do not publish this meta skill

## Out of scope

| Need | Instead |
| --- | --- |
| Feishu push | product `lark-push` |
| Generic Grok skill | Grok create-skill |

## References

- `schema/skill-repo.md`
- `scripts/new-skill.sh`, `scripts/register-submodule.sh`
- `scripts/list-skills`, `scripts/doctor`, `scripts/link-agent-skills`
- `references/checklist.md`
- root `AGENTS.md`
