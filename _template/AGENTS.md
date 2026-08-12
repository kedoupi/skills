# AGENTS.md

Guidance for AI coding agents working on the `<skill-name>` skill.

This skill is scaffolded from the incubator template. Cross-skill conventions live in
the incubator docs (`schema/skill-repo.md`, root `AGENTS.md`) when working inside the
local Skills workspace; they are **not** published as part of this skill repo.

When **creating or editing skills inside the incubator**, agents should follow the
project meta skill `.agents/skills/skill-incubator/` (not shipped in this package).

This file is the **source of truth** for agents in this skill repo. If `CLAUDE.md`
exists, it should only point here.

## Purpose

[One-line description.]

## Layout

```text
skills/
  <skill-name>/        # installable package (skills CLI discovers this)
    SKILL.md
    config.example.env
    scripts/
    templates/
    references/        # optional
tests/
  README.md
  run.sh               # offline self-test (required)
  fixtures/            # optional
  live/<suite>/        # optional live *specs* only
docs/
  README.md            # when docs/ is used
  screenshots/         # curated gallery only
artifacts/             # optional generated outputs
  README.md
  live/<suite>/<version>/
```

**Separation:** `docs/` guides · `tests/` CI + live specs · `artifacts/` generated outputs.  
No media under `tests/`; no `docs/benchmarks/`. Incubator SoT: `schema/skill-repo.md`.

## Editing rules

- Keep `SKILL.md` under ~500 lines; put long references in separate files.
- Do not hardcode private credentials or team-specific identifiers.
- Scripts must resolve their own directory with `pwd -P` so symlink installs work.
- Minimize runtime dependencies.
- Bump `metadata.version` in `SKILL.md` when behavior changes.
- `--dry-run` must stay offline / side-effect free.
- CLI values may start with `-` (markdown lists).

## Local validation

```bash
bash tests/run.sh
npx skills add ./ --list
bash skills/<skill-name>/scripts/<skill-name> --help
```
