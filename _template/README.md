# <skill-name>

[One-line description of what this skill does.]

[English](./README.md) | [简体中文](./README.zh-CN.md)

## Install

```bash
npx skills add <owner>/<repo-name> -g --all
```

`npx skills add` only installs code — **install ≠ configure**.

## After install (copy-paste)

```bash
SK=~/.agents/skills/<skill-name>

bash $SK/scripts/<skill-name> doctor

# Recommended durable config (survives npx skills update; not ~/.zshrc):
bash $SK/scripts/<skill-name> init …   # skill-specific flags
# → ~/.config/kedoupi/<skill-name>/config.env
```

## Prerequisites

1. [List required CLIs / auth / permissions]

## Quick start

```bash
# Preview (local only — no side effects when supported)
bash $SK/scripts/<skill-name> --dry-run …

# Real run
bash $SK/scripts/<skill-name> …
```

## Configuration

| Path | Role |
| --- | --- |
| `~/.config/kedoupi/<skill-name>/config.env` | **Recommended** (`init` default) |
| `~/.agents/skills/<skill-name>/` | Package only (wiped on update) |
| shell `export` | CI only — prefer not editing `~/.zshrc` |

Public env keys use a skill prefix (e.g. `LARK_PUSH_*` / `TZAI_*` / `WECHAT_MP_*`).  
See `skills/<skill-name>/config.example.env`.

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
docs/
```

## Development

```bash
bash tests/run.sh
npx skills add ./ --list
```

## License

[MIT](./LICENSE)
