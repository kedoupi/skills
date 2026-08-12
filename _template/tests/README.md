# Tests

## Offline (required)

```bash
bash tests/run.sh
```

Must stay network-free for CI.

## Live evaluation (optional)

```text
tests/live/<suite>/     # cases + rubrics only
artifacts/live/<suite>/<version>/   # generated outputs
```

Never store PNG/media under `tests/`. Full rules: incubator `schema/skill-repo.md`.
