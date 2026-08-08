# Incubator checklists

Paths relative to **parent incubator root** (`kedoupi/skills`).

## Naming reminder

| | Example |
| --- | --- |
| Package | `my-feature` |
| Repo / dir | `my-feature-skill` |
| Install | `npx skills add kedoupi/my-feature-skill` |

## New skill

- [ ] Scope agreed (triggers, safety, deps, publish vs private)
- [ ] `bash scripts/new-skill.sh <name>` → `./<name>-skill/`
- [ ] `skills/<name>/SKILL.md` description + version
- [ ] Scripts `pwd -P`; dry-run offline if side effects
- [ ] README EN + zh-CN
- [ ] `bash <name>-skill/tests/run.sh` passes
- [ ] GitHub `kedoupi/<name>-skill` created + child pushed
- [ ] `bash scripts/register-submodule.sh <name>-skill`
- [ ] Parent catalog updated if publishing

## Edit skill

- [ ] Work inside submodule dir
- [ ] Behavior → bump package version; docs-only → no bump
- [ ] Child commit + push
- [ ] Parent: `git add <name>-skill` + commit pointer
- [ ] EN / zh-CN synced when user-facing

## Release

- [ ] Child tests green
- [ ] Tag `vX.Y.Z` on **child**
- [ ] `npx skills add kedoupi/<name>-skill --list`
- [ ] Parent pointer + README catalog

## Incubator health

```bash
bash scripts/list-skills
bash scripts/doctor
bash scripts/link-agent-skills   # optional
```

## Reserved top-level (not product skills)

`_template`, `schema`, `scripts`, `.agents`, and other tooling dirs.
