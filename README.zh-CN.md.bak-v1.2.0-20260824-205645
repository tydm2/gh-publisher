# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#免责声明)

**把文件推送到 GitHub——无需 git，省 token、护隐私、跨平台。**

`gh-publisher` 是一个智能体技能：用 `gh` CLI + GitHub REST API（Contents / Git Database）把本地目录发布到 GitHub 仓库——不需要 git。它用一条可复用脚本自动完成空仓库初始化与批量提交，让智能体一条命令就推完，而不必逐文件重推 API 细节。

## 亮点

- **🚀 无需 git**——在没有 git 的机器上也能推；自动初始化空仓库。
- **⚡ 省 token**——一条 `scripts/push.ps1` 命令完成「扫描→初始化→批量提交→脱敏输出」，最终只打印一行 `PUSHED N files -> URL`，取代几十次手搓 API。
- **🔒 隐私与账号安全**——token 只存在 `gh` keyring（绝不进对话/日志/文件）；推送前对文件做密文扫描（`github_pat_`、`ghp_`、`sk-`、私钥…）；输出脱敏。
- **🔌 多智能体适配**——`pwsh` 脚本跨 Win/macOS/Linux；给出 DSH / Codex / Claude Code 映射；不写死平台工具名。
- **🧩 自动空仓库初始化**——检测到空仓库先经 Contents API 播种首个文件，再批量提交。

## 工作原理

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <目录> -Repo owner/repo -Message "…" [-GhPath <gh.exe 路径>]`
2. 自动定位 `gh` 二进制（`-GhPath` → PATH → 常见安装路径）并自动探测 `GH_CONFIG_DIR`——无需手动改 PATH/配置。
3. 密文扫描 → 命中密钥/token 模式即中止（除非加 `-ForceSecret`）。
4. 按分支 ref 检测空仓库（404=空）→ 必要时播种首个文件（Contents API）。
5. 批量提交全部文件（Git Database API：blobs → tree → commit → ref）。
6. 打印 `PUSHED N files -> https://github.com/owner/repo`——仅此一行；仓库不存在时打印 `gh repo create` 提示。

## 环境自检（首次推送前跑一遍）

- `Get-Command gh`（或让脚本自动探测安装路径）；缺失时 `winget install GitHub.cli`。
- `gh auth status` 显示已登录账号（token 掩码为 `github_pat_***…`）。
- `gh api repos/{owner}/{repo}` 或 `gh repo list` 能返回数据。

## 安装

```
~/.dsh/skills/gh-publisher/    # 全局
.dsh/skills/gh-publisher/      # 项目级
```

用「把这个推到 GitHub」「把这个技能发布成仓库」之类的话触发；或经 **set-skill** 的 `/skill` 菜单第 ⑤ 项进入。

## 文档

- `references/security.md` —— 隐私与账号安全
- `references/platform-adapter.md` —— DSH / Codex / Claude Code 映射

## 配套技能

- **[set-skill](https://github.com/tydm2/create-generate-skill)** —— 在其 `/skill` 菜单中列为第 ⑤ 项。
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** —— 用它生成的多智能体工作流，可用本技能发布。

## 环境要求

- `gh` CLI（先 `gh auth login` 登录）+ `pwsh`（PowerShell Core，跨平台）。

## 免责声明

> **本技能为 100% AI 制作。** 问题在所难免——欢迎讨论与 PR。作者会根据真实使用情况持续迭代优化。

## License

[MIT](./LICENSE)
