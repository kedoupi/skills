# Skills

Personal **agent skill incubator**: design, polish, and publish installable skills
for multi-agent use (`npx skills add`).

| Layer | GitHub | What lives there |
| --- | --- | --- |
| **Parent** | [kedoupi/skills](https://github.com/kedoupi/skills) | schema, template, meta skill, **catalog**, git submodules |
| **Product skill** | `kedoupi/<name>-skill` | one installable package under `skills/<name>/` |

```bash
# clone incubator + all product skills
git clone --recurse-submodules git@github.com:kedoupi/skills.git
# or later:
git submodule update --init --recursive
```

---

## Published skills（目录）

每增加一个可安装 product skill，**必须**在本表登记，并随父仓 commit / push。

| Skill package | Version | 说明 | Repo | Install |
| --- | --- | --- | --- | --- |
| **`lark-push`** | `1.3.0` | 飞书/Lark 群推送：完成通知、日报周报、发布摘要 | [kedoupi/lark-push-skill](https://github.com/kedoupi/lark-push-skill) | `npx skills add kedoupi/lark-push-skill` |
| **`tzai-image`** | `0.5.3` | TaoziAPI 生图引擎 + 场景 kind + Plan C 斜杠（小红书/流程图/架构图/封面等） | [kedoupi/tzai-image-skill](https://github.com/kedoupi/tzai-image-skill) | 见下 |

### `lark-push`

- 用途：向配置好的飞书群发送进度/日报/发布类通知  
- 文档：[README](https://github.com/kedoupi/lark-push-skill#readme) · [中文](https://github.com/kedoupi/lark-push-skill/blob/main/README.zh-CN.md)

```bash
npx skills add kedoupi/lark-push-skill
```

### `tzai-image`

- 用途：经 [TaoziAPI](https://tzai.kdp.cool) 文生图；默认模型 **`gpt-image-2`**
- 形态：一个引擎 + 6 分类 hub + 11 高频场景斜杠（Plan C）；长尾 kind 走引擎
- 能力摘要：小红书图卡/封面、信息图矩阵、封面五维、流程/架构图、`--ref` 参考图、多图工作流
- 文档：[README](https://github.com/kedoupi/tzai-image-skill#readme) · [中文](https://github.com/kedoupi/tzai-image-skill/blob/main/README.zh-CN.md) · [场景表](https://github.com/kedoupi/tzai-image-skill/blob/main/docs/SCENES.md)

```bash
# 引擎 + 全部 Plan C skill → 各 Agent
npx skills add kedoupi/tzai-image-skill -g --all

# 可选：把 commands/*.md 链到 Claude/Grok/Cursor 等 commands 目录
git clone https://github.com/kedoupi/tzai-image-skill.git
cd tzai-image-skill && bash scripts/install-slash-commands.sh

# 配置 Key（二选一）
export TZAI_API_KEY='sk-...'
# 或 durable：
bash ~/.agents/skills/tzai-image/scripts/tzai-image init --api-key sk-...
```

常用斜杠示例：`/tzai-image` `/tzai-xhs` `/tzai-xhs-cover` `/tzai-flowchart` `/tzai-architecture` `/tzai-icon` `/tzai-cover` …

---

## Naming

| | Pattern | Example |
| --- | --- | --- |
| Package name | `<name>` | `lark-push`, `tzai-image` |
| Repo + directory | `<name>-skill` | `lark-push-skill`, `tzai-image-skill` |
| Install | `npx skills add kedoupi/<name>-skill` | |

## How this incubator works

```text
idea
  → skill-incubator (or agent) aligns scope
  → bash scripts/new-skill.sh <name>     # → ./<name>-skill/
  → implement + bash <name>-skill/tests/run.sh
  → create GitHub kedoupi/<name>-skill + push
  → bash scripts/register-submodule.sh <name>-skill
  → update this README catalog (version + one-line + install)
  → commit parent: catalog + submodule pointer
  → (optional) tag child vX.Y.Z + skills.sh
```

| Path | Role |
| --- | --- |
| [`schema/skill-repo.md`](./schema/skill-repo.md) | Living schema (layout, config, safety, tests) |
| [`_template/`](./_template/) | Product skill skeleton |
| [`scripts/new-skill.sh`](./scripts/new-skill.sh) | Scaffold `./<name>-skill/` |
| [`scripts/register-submodule.sh`](./scripts/register-submodule.sh) | `git submodule add` helper |
| [`scripts/list-skills`](./scripts/list-skills) | List product skill dirs / remotes |
| [`scripts/doctor`](./scripts/doctor) | Incubator health check |
| [`scripts/link-agent-skills`](./scripts/link-agent-skills) | Symlink meta skill for Claude/Grok |
| [`.agents/skills/skill-incubator/`](./.agents/skills/skill-incubator/) | Meta skill: create / edit / release |
| [`AGENTS.md`](./AGENTS.md) | Agent contract SoT |
| `<name>-skill/` | **Submodule** → product GitHub |

### Catalog maintenance（必做）

Whenever a product skill is **first published** or **version-bumped for users**:

1. Child repo: tag / push  
2. Parent: `git add <name>-skill` (submodule SHA)  
3. Parent: update **Published skills** table + short install blurb in this `README.md`  
4. Parent: commit + push `kedoupi/skills`

Do **not** only bump the submodule and leave the catalog at an old version.

### Multi-agent notes

Keep **one** shared contract in `AGENTS.md`. Tool stubs only point at it.  
Each product submodule has its own `AGENTS.md` for skill-local rules.

### New skill

```bash
bash scripts/new-skill.sh my-feature
# creates my-feature-skill/ with skills/my-feature/
cd my-feature-skill
# edit package…
bash tests/run.sh
# create GitHub kedoupi/my-feature-skill, push, then from parent:
cd ..
bash scripts/register-submodule.sh my-feature-skill
# then edit README.md Published skills table + commit parent
```

### Schema evolution

1. Put references under `schema/references/<source>/`  
2. Log deltas in `schema/references/CHANGELOG.md`  
3. Promote rules into `schema/skill-repo.md` + `_template/`  

---

Each product skill is an independent public GitHub repository (submodule here)
following [Agent Skills](https://agentskills.io/) and this incubator’s schema.
