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
- [ ] Layout: `docs/` guides only; `tests/` offline + live **specs**; `artifacts/` for generated outputs
- [ ] `docs/README.md` if `docs/` used; no `docs/benchmarks/`; no media under `tests/`
- [ ] `bash <name>-skill/tests/run.sh` passes
- [ ] `bash scripts/check-skill-layout <name>-skill` green
- [ ] GitHub `kedoupi/<name>-skill` created + child pushed
- [ ] `bash scripts/register-submodule.sh <name>-skill`
- [ ] **Registry:** add `products.json` object (`single` by default) + install blurb
- [ ] `bash scripts/render-catalog` updates README + AGENTS generated tables
- [ ] `bash scripts/check-catalog` green
- [ ] Parent commit + push (submodule pointer + registry/generated catalog)

## Edit skill

- [ ] Work inside submodule dir
- [ ] Behavior → bump package version; docs-only → no bump
- [ ] Child commit + push
- [ ] Parent: `git add <name>-skill`
- [ ] **If family lockstep version bumped:** regenerate/sync all entrypoint versions
- [ ] **If purpose/entrypoints changed:** update `products.json`
- [ ] EN / zh-CN synced when user-facing
- [ ] `bash scripts/render-catalog && bash scripts/check-catalog`
- [ ] Parent commit

## Release

- [ ] Child tests green
- [ ] Tag `vX.Y.Z` on **child**
- [ ] `npx skills add kedoupi/<name>-skill --list`
- [ ] Parent pointer + generated catalog (`scripts/render-catalog`)
- [ ] `bash scripts/check-catalog` green
- [ ] Parent push

## Incubator health

```bash
bash scripts/list-skills
bash scripts/render-catalog --check
bash scripts/check-catalog
bash scripts/check-skill-layout
bash scripts/doctor
bash scripts/link-agent-skills   # optional
```

## Reserved top-level (not product skills)

`_template`, `schema`, `scripts`, `.agents`, and other tooling dirs.
