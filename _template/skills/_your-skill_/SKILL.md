---
name: <skill-name>
description: Use when the user asks to ... [trigger description that tells agents when to invoke this skill]
metadata:
  author: <your-github-handle>
  version: "0.1.0"
  requires:
    bins: []
---

# <Skill Display Name>

[One paragraph: what this skill does, default behavior, key constraints.]

## Prerequisites

```bash
# Verify required CLI / auth
# <cli> auth status --verify
```

## Locating the helper

```bash
# Common install locations:
#   Canonical / symlink source: ~/.agents/skills/<skill-name>/
#   Claude:  ~/.claude/skills/<skill-name>/
#   Codex:   ~/.codex/skills/<skill-name>/
#   Project: ./.agents/skills/<skill-name>/
```

Scripts resolve their real path with `pwd -P` so symlink installs share one config.

## Config

One-time after install (if this skill needs durable config):

```bash
bash <skill-dir>/scripts/<skill-name> init --chat-id <id>
```

Config is stored **outside** the skill package (survives `npx skills update`).
See incubator schema: durable path is `<skills-parent>/.skill-data/<skill-name>/config.env`.

Inspect:

```bash
bash <skill-dir>/scripts/<skill-name> config-path
bash <skill-dir>/scripts/<skill-name> which-config
```

## Safety

[Describe what agents must confirm before taking real action.]

If the user runs the helper script directly, that invocation is the approval.
For previews, use `--dry-run` (must stay offline / side-effect free).

## Usage

```bash
# Preview (local only)
bash <skill-dir>/scripts/<skill-name> --dry-run --title "Example" --body "- item"

# Real action
bash <skill-dir>/scripts/<skill-name> --title "Hello" --body "World"
```

## Key CLI options

```text
--title <text>
--body <text>     # may start with '-'
--dry-run         # local preview only
```

Full reference: `bash <skill-dir>/scripts/<skill-name> --help`.
