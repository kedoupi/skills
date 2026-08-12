# <skill-name>

[一句话说明这个 skill 做什么。]

[English](./README.md) | [简体中文](./README.zh-CN.md)

## 安装

```bash
npx skills add <owner>/<repo-name> -g --all
```

`npx skills add` **只装代码**——安装 ≠ 配置。

## 安装后（复制粘贴）

```bash
SK=~/.agents/skills/<skill-name>

bash $SK/scripts/<skill-name> doctor

# 推荐 durable 配置（npx skills update 不会冲掉；不要写进 ~/.zshrc）：
bash $SK/scripts/<skill-name> init …
# → ~/.config/kedoupi/<skill-name>/config.env
```

## 前置条件

1. [列出所需 CLI / 鉴权 / 权限]

## 快速开始

```bash
# 预览（支持时本地、无副作用）
bash $SK/scripts/<skill-name> --dry-run …

# 正式执行
bash $SK/scripts/<skill-name> …
```

## 配置

| 路径 | 作用 |
| --- | --- |
| `~/.config/kedoupi/<skill-name>/config.env` | **推荐**（`init` 默认） |
| `~/.agents/skills/<skill-name>/` | 仅 skill 包（update 会 wipe） |
| shell `export` | 仅 CI — 尽量不改 `~/.zshrc` |

公开环境变量使用 skill 前缀（如 `LARK_PUSH_*` / `TZAI_*` / `WECHAT_MP_*`）。  
详见 `skills/<skill-name>/config.example.env`。

## 功能

- ...

## 仓库结构

```text
skills/
  <skill-name>/
    SKILL.md
    config.example.env
    scripts/
      <skill-name>
    templates/
tests/
  run.sh
docs/
```

## 开发

```bash
bash tests/run.sh
npx skills add ./ --list
```

## License

[MIT](./LICENSE)
