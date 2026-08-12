# Durable config convention (kedoupi skills)

Author-facing detail for product skills. **Source of truth summary:** parent
[`skill-repo.md`](../skill-repo.md) § Config schema.

## Goals

1. **Open-source first** — any user can configure without kedoupi-internal env names.
2. **Brand home** — one place for humans: `~/.config/kedoupi/`.
3. **Safe for agents** — prefer files; never edit the user’s `~/.zshrc` / global env.
4. **Survive reinstall** — config outside `skills/<name>/` package tree.
5. **Backward compatible** — keep reading `.skill-data` and `~/.config/<name>/`.

## Recommended layout

```text
~/.config/kedoupi/<skill-name>/
  config.env          # KEY=value, chmod 600
  # optional extras: style.yaml, …
```

Skill **code** stays under agent skill dirs (`~/.agents/skills/<name>/`, etc.).

## Public keys only

| Skill | Prefix | Examples |
| --- | --- | --- |
| `lark-push` | `LARK_PUSH_` | `LARK_PUSH_CHAT_ID` |
| `tzai-image` | `TZAI_` | `TZAI_API_KEY`, `TZAI_BASE_URL` |
| `wechat-mp` | `WECHAT_MP_` | `WECHAT_MP_APPID`, `WECHAT_MP_SECRET`, `WECHAT_MP_API_BASE` |

Document these in each package `config.example.env`. Host-private aliases (if any)
are out of band — not the public contract.

## Load order

Later wins among files; process env / CLI may override for CI.

1. `~/.config/<skill>/config.env`
2. `~/.agents/skills/.skill-data/<skill>/config.env`
3. `<skills-parent>/.skill-data/<skill>/config.env`
4. `~/.config/kedoupi/<skill>/config.env` ← **recommended**
5. `<skill>/config.local.env`
6. `$PREFIX_CONFIG` path
7. Env / CLI

## Migrate

If kedoupi file missing and a legacy file exists → copy to kedoupi (once), `chmod 600`.
Source = **config files only**, not shell exports.

## Init

```bash
<skill> init …                 # default writes ~/.config/kedoupi/<skill>/config.env
<skill> init --target durable  # legacy install-adjacent
<skill> which-config           # show paths + masked values
<skill> doctor                 # missing config → pasteable init hint
```

## Content vs config

| Data | Location |
| --- | --- |
| API keys, chat ids, app secrets | `~/.config/kedoupi/<skill>/` |
| Article drafts, images, history | User **project** (e.g. `./wechat-mp-out/`) |

## Checklist for new skills

- [ ] `config.example.env` with public prefix only  
- [ ] Default `init` → `~/.config/kedoupi/<name>/config.env`  
- [ ] `ensure_kedoupi_config` (or equivalent) before load  
- [ ] `which-config` lists kedoupi path first  
- [ ] Docs: “you usually do **not** need to export secrets in your shell”  
- [ ] Offline test: migrate copy + init target kedoupi  

## Optional local cleanup (after migrate)

When `~/.config/kedoupi/<name>/config.env` exists and is known-good:

| Safe to remove | Keep |
| --- | --- |
| Duplicate `~/.agents/skills/.skill-data/<name>/config.env` (identical copy) | `~/.config/kedoupi/…` |
| One-off demo dirs (`~/tmp-*-demo`, stray `~/wechat-mp-out` not in a content project) | Installed skill packages under `~/.agents/skills/<name>/` |
| Empty `.skill-data` trees | Agent **symlinks** (`~/.claude/skills/…` → `.agents`) — discovery, not junk |

Do **not** delete shell rc / global env vars as part of skill cleanup.  
Do **not** remove multi-agent symlinks created by `npx skills add -g --all`.
