# CLAUDE.md

Claude Code project adapter for this **skill incubator**.

**Shared rules live in [`AGENTS.md`](./AGENTS.md).** Read that file first and follow it.

@AGENTS.md

## Claude-only notes (optional deltas)

- Prefer the incubator workflow in `AGENTS.md` over inventing a parallel layout.
- Create / edit / release product skills via project skill
  `.agents/skills/skill-incubator/SKILL.md` (not a published package).
- Parent GitHub: `kedoupi/skills` (submodules). Child repos: `kedoupi/<name>-skill`.
- When editing a skill submodule, also load that repo’s `AGENTS.md`
  (e.g. `lark-push/AGENTS.md` or `*-skill/AGENTS.md`) — deeper rules win.
- Do not reintroduce full project conventions here; update `AGENTS.md` instead.
