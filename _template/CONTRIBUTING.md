# Contributing

Thanks for your interest in improving `<skill-name>`.

## Development setup

```bash
git clone <repo-url>
cd <repo-name>
npx skills add ./ --list
bash tests/run.sh
```

## Guidelines

1. Keep `skills/<skill-name>/SKILL.md` under ~500 lines.
2. Do not hardcode private credentials.
3. Scripts must resolve their own directory with `pwd -P` for symlink installs.
4. Keep the default README in **English**; update `README.zh-CN.md` for user-facing changes.
5. Bump `metadata.version` in `SKILL.md` when behavior changes.
6. Keep `--dry-run` offline / side-effect free.

## Validation

```bash
bash tests/run.sh
bash skills/<skill-name>/scripts/<skill-name> --help
bash skills/<skill-name>/scripts/<skill-name> --dry-run --title "Test" --body "- hello"
```
