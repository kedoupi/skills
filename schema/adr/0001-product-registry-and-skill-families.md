# ADR-0001: Product registry and skill families

- Status: Accepted
- Date: 2026-08-12

## Context

The incubator originally assumed one product repository contained exactly one installable
skill. That model fits `lark-push` and `wechat-mp`, but not `tzai-image`: the latter has one
primary engine plus generated hub and high-frequency entrypoints. The README and AGENTS
catalogs were also maintained independently from package metadata, so release state could
drift across child tags, submodule pointers, and parent documentation.

## Decision

1. `products.json` is the machine-readable source of truth for published product identity,
   repository, product type, primary skill, installable entrypoints, install command, and
   catalog purpose.
2. Product repositories have one of two explicit types:
   - `single`: exactly one installable entrypoint, which is the primary skill.
   - `family`: one primary skill plus two or more related entrypoints in the same release unit.
3. `metadata.version` in the primary `SKILL.md` remains the product version source of truth.
   A family declares whether entrypoint versions are `lockstep` or `independent`; current
   families use `lockstep`.
4. README and AGENTS product tables are generated views. They are updated with
   `scripts/render-catalog` and verified by `scripts/check-catalog` / `scripts/doctor`.
5. Parent CI checks the registry, generated views, submodules, layouts, and every product's
   offline test suite.

## Consequences

- Product identity is no longer inferred only from directory naming.
- Family repositories are first-class instead of exceptions to the schema.
- Adding, renaming, or retiring a product requires a registry change.
- Adding or removing an installable entrypoint requires a registry change.
- Lockstep family releases fail validation if a generated facade retains an old version.
- Markdown catalogs remain readable public documentation but are not independently edited.

## Deferred

A versioned cross-skill artifact/capability protocol is a separate decision. Existing soft
peer composition remains valid until that protocol is designed and adopted by producers and
consumers together.
