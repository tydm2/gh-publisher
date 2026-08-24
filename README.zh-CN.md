# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.4.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**免 git 发布文件到 GitHub —— 省 token、隐私安全、多智能体适配、多语言。**

`gh-publisher` 是一个智能体技能（agent skill），使用 `gh` CLI + GitHub REST API（Contents / Git Database）将本地目录发布到 GitHub 仓库——无需 git。它用一个可复用的脚本处理空仓库初始化与批量提交，让智能体一条命令完成推送，而不必重新推导整套 API 流程。它还会发布 GitHub 使用率最高的 **10 种语言**（README 翻译版），而本地工作副本始终保留在你偏好的语言。

## 为什么它与众不同

- **🚀 免 git 推送** —— 在没有 git 的机器上也能工作；自动初始化空仓库。
- **⚡ 省 token** —— 一条 `scripts/push.ps1` 命令完成 守卫 → 扫描 → 初始化 → 批量提交 → 脱敏输出（一行 `PUSHED N files -> URL`），替代数十次手写 API 调用。
- **🔒 隐私与账号安全** —— token 只存在于 `gh` 钥匙串中（绝不进入对话/日志/文件）；推送前对文件做密文扫描（`github_pat_`、`ghp_`、`sk-`、私钥……）；输出脱敏。
- **🛡️ 个人数据守卫** —— 本机专属档案（`local-profile.json` / `config.local.json`）**绝不**可能被发布：源目录一出现此类文件，推送立即中止，其它任何步骤都不再执行。
- **🗂️ 本机专属档案** —— 在网络环境复杂（例如 hosts 被劫持）的机器上，一个 `local-profile.json` 即可整合账号、gh 条目（代理模式垫片）以及已知仓库映射，推送只需 `-Profile`——再也不用手动寻找账号 / gh / 仓库。
- **🔌 多智能体适配** —— `pwsh` 脚本可在 Windows/macOS/Linux 上运行；已文档化 DSH / Codex / Claude Code 的映射；不硬编码任何平台工具名称。
- **🧩 自动空仓库初始化** —— 检测空仓库，并在批量提交前通过 Contents API 植入第一个文件。
- **🌍 多语言发布** —— 本地工作副本保持在你所选的语言（默认中文）；发布版随附 GitHub 使用率最高的 10 种语言的 README 翻译（en、zh-CN、hi、es、fr、ar、bn、pt、ru、ja）。参见 `references/i18n.md`。

## 工作原理

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. 自动定位 `gh` 可执行文件（`-GhPath` → PATH → 常见安装路径）并自动检测 `GH_CONFIG_DIR`——无需手动调整 PATH / 配置。使用 `-Profile` 时，gh 条目、配置目录、仓库（按源目录匹配）与语言（从 `README.<lang>.md` 自动检测）都会自动解析。
3. **个人数据守卫** —— 源目录中出现 `local-profile.json` / `config.local.json` → 中止（它们绝不能被发布）。
4. 密文扫描 → 命中任何密钥/token 模式即中止（除非使用 `-ForceSecret`）。
5. 通过检查分支引用检测空仓库（404 = 空）→ 必要时植入第一个文件（Contents API）。
6. 批量提交所有文件（Git Database API：blob → tree → commit → ref）。
7. 仅打印 `PUSHED N files -> https://github.com/owner/repo` —— 其它一律不输出。仓库缺失时 → 打印 `gh repo create` 提示。
8. 可选 `-Languages` 检查：推送前逐一验证每个语言文件是否存在（例如 `README.hi.md`），缺失时给出警告。

## 多语言发布（本地语言 + 10 种发布语言）

- **本地工作副本**：保持在你配置的语言（zh 或 en）——即已安装技能目录下的 `config.local.json`（默认 `zh`）。说一句 *"把本地默认语言改成英文"* 即可切换；本地 SKILL.md 会同步更新。
- **发布版**：`SKILL.md` 保持英文（GitHub 的通用主语言），同时发布 GitHub 使用率最高的 10 种语言的 `README.<lang>.md`。语言列表、翻译规则与触发契约注意事项参见 `references/i18n.md`（所有语言版本保持相同的 `name`）。

## 本机专属档案（local-profile）

在网络不标准的机器上（例如 hosts 文件将 GitHub 域名劫持到 127.0.0.1，外加一个必须通过本地代理垫片运行的便携版 `gh`），`E:\ds harness\gh\local-profile.json` 可整合 owner、gh 条目、配置目录与已知仓库映射。该文件标记为 `"never_publish": true`——它只存在于本机，绝不被推送。任何读取/修改它的操作都会先收到明确强调的确认。

## 环境自检（首次推送前做一次）

- `Get-Command gh`（或让脚本自动检测安装路径）；若缺失：`winget install GitHub.cli`。
- `gh auth status` 显示已登录账号（token 脱敏为 `github_pat_***…`）。
- `gh api repos/{owner}/{repo}` 或 `gh repo list` 返回数据。

## 安装

```
~/.dsh/skills/gh-publisher/    # 全局
.dsh/skills/gh-publisher/      # 按项目
```

用 *"把这个推到 GitHub"*、*"把这个技能发布到仓库"* 之类的短语触发它——或通过 **set-skill** 的 `/skill` 菜单项 ⑤。

## 文档

- `references/security.md` —— 隐私与账号安全
- `references/platform-adapter.md` —— DSH / Codex / Claude Code 映射
- `references/i18n.md` —— 多语言发布协议（10 种语言）

## 配套技能

- **[set-skill](https://github.com/tydm2/create-generate-skill)** —— 把本技能列为 `/skill` 菜单项 ⑤。
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** —— 用它发布其生成的多智能体工作流。

## 环境要求

- `gh` CLI（通过 `gh auth login` 登录）+ `pwsh`（PowerShell Core，跨平台）。

## 免责声明

> **本技能 100% 由 AI 打造。** 问题在所难免——欢迎讨论与提交 pull request。作者会根据真实使用情况持续迭代。

## 许可证

[MIT](./LICENSE)
