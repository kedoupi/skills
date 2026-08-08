# <skill-name>

[One-line description of what this skill does.]

## Install

```bash
npx skills add <owner>/<repo-name> -g --all
```

## Prerequisites

1. [List required CLIs / auth / permissions]

## Quick start

```bash
# One-time config after install
bash <skill-dir>/scripts/<skill-name> init --chat-id <id>

# Preview (local only — no side effects)
bash <skill-dir>/scripts/<skill-name> --dry-run --title "Hello" --body "- item"

# Run
bash <skill-dir>/scripts/<skill-name> --title "Hello" --body "World"
```

## Features

- ...

## Repository layout

```text
skills/
  <skill-name>/
    SKILL.md
    config.example.env
    scripts/
      <skill-name>       # main CLI
    templates/
tests/
  run.sh
```

## Development

```bash
bash tests/run.sh
npx skills add ./ --list
```

## License

[MIT](./LICENSE)
