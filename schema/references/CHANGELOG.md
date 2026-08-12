# Schema references changelog

External open-source skill schemas and layouts we review go under
`schema/references/<source>/`.

| Date | Source | Notes |
| --- | --- | --- |
| 2026-08-08 | baseline | Bootstrapped from `lark-push` + agentskills.io + skills.sh conventions |
| 2026-08-08 | packaging | Parent monorepo `kedoupi/skills` + git **submodule** per product skill; child GitHub named `<name>-skill`; package name remains `<name>` |
| 2026-08-12 | layout | **docs / tests / artifacts** hard separation; `scripts/check-skill-layout`; template indexes; no media under `tests/`; no `docs/benchmarks/` |

When you send a new schema, we will:

1. Snapshot it under `schema/references/<source>/`
2. Write a short delta vs baseline
3. Promote agreed rules into `../skill-repo.md` and `_template/`
