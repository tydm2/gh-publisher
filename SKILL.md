---
name: gh-publisher
description: 当用户想把一组文件、一个技能或一个项目推送到 GitHub 仓库时使用——尤其本机无 git、空仓库初始化、多语言 README 发布场景。用 gh CLI + GitHub REST API 无 git 推送，内置脚本 scripts/push.ps1 一条命令跑完以省 token；支持本机专属档案（local-profile）自动识别账号/gh/仓库；含个人信息的档案永不外发；多语言翻译走省 token 的增量编辑方案（不再全文重翻）；token 绝不进对话/日志、推送前密文扫描、输出脱敏；适配 DSH/Codex/Claude Code。不用于需完整 git 历史或分支合并的版本控制。
metadata:
  version: 1.6.0
  languages: [zh]
  changelog:
    - 1.6.0: 多语言收敛为 6 种发布语言（en/zh-CN/es/fr/ja/ru，原 10 语言砍半）——翻译环节减量 40%、语言栏只列 6 语言避免死链；i18n.md 新增 §1.6 效率要点，执行流程与语言清单同步更新（推送默认 6 语言）
    - 1.5.0: 翻译流程升级为「省 token 固定方案」——多语言 README 默认走**增量编辑翻译**（子代理读旧译文 + 新英文源，只增量修改变化段落，不全文重翻 11 语言，省 ~70-90% 输出 token、更快且保持术语/风格一致）；i18n.md 新增 §1.5 固定方案（步骤/保留清单/术语一致/首次翻译建术语基线），翻译规范补不译清单（项目名/命令/CLI flags/环境变量/文件名/徽章 URL）
    - 1.4.0: 本机专属优化——新增「本机专属档案（local-profile）」：账号/gh 入口（代理模式 shim）/配置目录/仓库映射固化在 E:\ds harness\gh\local-profile.json（标记 never_publish，只存本机绝不外发）；push.ps1 加 -Profile 自动识别（gh 入口/GH_CONFIG_DIR/仓库按源目录匹配/语言自动检测 README.<lang>.md），-Repo 改为可省略；新增 PERSONAL DATA GUARD——源目录含 local-profile.json / config.local.json 即中止推送；硬原则升级为四条（个人信息永不外发）；动作门控：涉及个人信息的动作必须特意询问并强调，普通推送一句确认即可
    - 1.3.1: push.ps1 修复——PS 7.2+ 下全局 $ErrorActionPreference='Stop' 使 gh 写向 stderr 的预期失败（如全新空仓库 git refs 探测的 HTTP 409「Git Repository is empty」）变成终止性错误，空仓库自动初始化流程在启动前即中断；Invoke-GhApi 内临时降级 EAP 为 Continue（成败以 $LASTEXITCODE 为准），空仓库场景实测通过（code-forge-skill 推送触发修复）
    - 1.3.0: 多语言升级为「推送默认步骤」——推送技能/文档项目前默认生成 10 语言 README（并行子代理翻译）→ -Languages/-RequireI18n 检查 → 推送；用户明确说不用才跳过；i18n.md 新增自动触发与执行流程；push.ps1 新增 -RequireI18n（缺失语言文件即 FAIL 中止）
    - 1.2.0: 多语言发布——本地语言可配置(zh/en, config.local.json 默认 zh)、推送 10 种 GitHub 最常用语言(en/zh-CN/hi/es/fr/ar/bn/pt/ru/ja)、references/i18n.md 协议、push.ps1 -Languages 就绪检查
    - 1.1.0: gh 二进制自动探测(-GhPath) + GH_CONFIG_DIR 自动探测 + 空仓库判定修复(git refs) + 仓库不存在提示 + API 错误可见 + 环境自检小节
    - 1.0.0: 初始版本——把「无 git 推送 GitHub」流程固化为技能：脚本省 token + 隐私账号安全 + 多 agent 适配
user-invocable: true
---

# gh-publisher

把一组本地文件推送到 GitHub 仓库（**无需 git**）：用 `gh` CLI 调 GitHub REST API（Contents / Git Database）完成空仓库初始化与批量提交，内置可复用脚本一次跑完——省 token、护隐私、跨平台。

## 何时用 / 何时不用

- **用**：本机无 git；空仓库首次初始化；把技能/文档/项目文件发布成 GitHub 仓库；批量覆盖多文件（含多语言 README）。
- **不用**：需要分支合并、完整 git 历史或多人协作开发——用 `git` 或 `gh repo` 系列命令。

## 四条硬原则（★每次必守）

1. **省 token**：优先跑 `scripts/push.ps1`（一条命令完成全部），不要逐文件手调 API、不要重新推导 blob→tree→commit→ref 流程；翻译走「增量编辑」固定方案，不全文重翻。
2. **隐私与账号安全**：token 永远不写进对话/日志/文件；登录用 `gh auth login`（keyring 托管）；输出一律脱敏；推送前密文扫描；绝不提交密钥。
3. **多 agent 适配**：正文不写死平台专属工具名；脚本用 `pwsh`（PowerShell Core，跨 Win/macOS/Linux），平台映射见 `references/platform-adapter.md`。
4. **个人信息永不外发（★v1.4）**：本机专属档案（`local-profile.json` / `config.local.json`）含账号、路径、仓库等个人信息，**任何情况下不推送 GitHub**——push.ps1 检测到即中止（PERSONAL DATA GUARD）。对本机档案的创建/修改/读取、或任何涉及个人信息的动作，必须**特意询问并强调**（⚠️ 本机专有、不发布）后才执行；普通技能/文档推送只需一句确认。

## 脚本用法（首选，省 token）

```powershell
pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <本地目录> -Repo owner/repo -Message "提交说明" [-Profile <本机档案路径>] [-Branch main] [-GhConfigDir <gh配置目录>] [-GhPath <gh.exe 路径>] [-ForceSecret]
```

- `-ExecutionPolicy Bypass` 可绕开受限机器的脚本执行策略拦截（Windows 常见坑）。
- 脚本**自动探测 `gh` 二进制**（`-GhPath` → PATH → 常见安装路径）并**自动探测 `GH_CONFIG_DIR`**（`-GhConfigDir` → 环境变量 → `%APPDATA%\GitHub CLI`），无需手动改 PATH/配置。
- **本机部署（tydm2）用 `-Profile` 即可**：自动识别 gh 入口（代理模式 shim）、配置目录、仓库（按源目录匹配）与语言（自动检测 README.<lang>.md），`-Repo`/`-Languages`/`-GhPath`/`-GhConfigDir` 均可省略——见「本机专属档案」节。
- 脚本自动完成：密文扫描 → 个人信息防推检查 → 空仓库检测（空则先初始化）→ 批量提交 → 脱敏输出（只打印「PUSHED N files -> URL」）。
- 密文命中默认**中止**（列出命中位置），确需放行加 `-ForceSecret`。
- 仓库不存在时脚本打印 `gh repo create ... --push` 提示，而非静默失败。
- 参数与退出码见 `scripts/push.ps1` 顶部注释。

## 本机专属档案（local-profile，★v1.4）

本机（tydm2 部署）的账号/路径/仓库信息固化在 `E:\ds harness\gh\local-profile.json`（JSON，标记 `"never_publish": true`）：

- **内容**：owner（tydm2）、gh 便携版入口（代理模式 shim `gh.cmd`，绕开 Steam++ 对 GitHub 域名的 hosts 劫持）、`GH_CONFIG_DIR`（`E:\ds harness\gh\.config`）、已知仓库映射（workflow-builder-skill / create-generate-skill / gh-publisher / mode-creator-skill 及其本地源目录）、网络与认证说明。
- **用法**：`push.ps1 -Profile <档案路径> -Source <目录> -Message "..."` —— 自动识别 gh 入口、配置目录、仓库与语言，不再逐项查找。
- **个人信息防推（硬规则）**：文件名匹配 `local-profile.json` / `config.local.json` 的文件**永不推送到 GitHub**，push.ps1 检测到即中止；档案只存本机，绝不外发。
- **动作门控**：对本机档案的创建/修改/读取、或任何涉及个人信息的动作，必须**特意询问并强调**（⚠️ 本机专有、不发布）后才执行；普通技能/文档推送只需一句确认。
- **换机迁移**：复制整个 `E:\ds harness\gh\`（含档案与 gh 便携版）即可。

## 环境自检（首次推送前跑一遍）

1. **gh 可用？** — `Get-Command gh`（脚本也会自动探测安装路径）；缺失时 `winget install GitHub.cli` 或传 `-GhPath <gh.exe 路径>`。
2. **已登录？** — `gh auth status` 须显示已登录账号（token 显示为 `github_pat_***…` 掩码；**绝不**在任何地方粘贴原始 token）。
3. **配置目录？** — 通常自动（`%APPDATA%\GitHub CLI`）；agent 无法写该目录时设 `GH_CONFIG_DIR` 或传 `-GhConfigDir`。
4. **连通性** — 首次推送前 `gh api repos/{owner}/{repo}` 或 `gh repo list` 能返回数据。

## 多语言发布（技能/文档项目的推送默认步骤）

**推送技能或文档类项目到 GitHub 前，6 语言步骤默认执行**（发布语言 en/zh-CN/es/fr/ja/ru，效率说明见 `references/i18n.md`）——只有用户明确说「单语言推送/不用翻译」才跳过。

- **本地工作副本保留你的语言**：已安装技能目录的 `config.local.json` 存 `{"local_lang": "zh"|"en"}`（默认 `zh`）。说「更改本地保留默认语言为英文」即切换——本地 SKILL.md 同步更新。翻译本地文档前先读该配置。
- **发布版 = 6 种发布语言**：`README.<lang>.md` 覆盖 en、zh-CN、es、fr、ja、ru（完整清单 + 翻译规范 + 触发契约注意事项见 `references/i18n.md`；相比 10 语言减量 40%，更快更省 token）。`SKILL.md` 保持单一主版语言（gh-publisher 用英文；其他项目按自身约定）；所有语言版本 `name` 一致。
- **翻译方式 = 省 token 固定方案（v1.5）**：已有旧译文的语言默认走**增量编辑翻译**——子代理读旧译文 + 新英文源，只用编辑操作修改变化段落，不全文重翻（省 ~70-90% 输出 token、更快、保持术语/风格一致）；无旧译文的语言全文翻译一次并建立术语基线。细则见 `references/i18n.md` §1.5。
- **默认执行流程（除非用户豁免）**：
  1. 检查源目录已有语言文件；缺失/过期的语言文件用并行子代理按「增量编辑翻译」更新（见 i18n.md §1.5）。
  2. 就绪检查：`push.ps1 -Languages en,zh-CN,es,fr,ja,ru`——缺失列 WARN（有 `-Profile` 时自动检测，可省略）。
  3. 硬性把关：加 `-RequireI18n`——缺失语言文件即 **FAIL 中止推送**（exit 1）。
  4. 推送。
- **自动触发协议/语言清单/翻译规范/豁免话术见 `references/i18n.md`**。

## 手动流程（仅脚本不可用时）

1. 确认来源目录、目标 `owner/repo`、提交信息、分支（默认 main）。
2. **密文扫描 + 个人信息检查**（见「安全红线」）。
3. 判空：`gh api repos/{owner}/{repo}` 看 `size`，或 `GET contents` 返回 404 "empty"。
4. 空仓库 → 用 **Contents API** `PUT /contents/{path}` 写首个文件初始化（自动建默认分支）→ 再用 **Git Database API** 批量提交其余文件；非空 → 直接 Git Database API 批量提交（blobs→tree→commit→PATCH ref）。
5. 输出只打印提交数与最终 URL，**不打印任何 token/密钥**。

## 安全红线（逐条自检）

- [ ] 登录走 `gh auth login` / keyring，token 不出现在任何脚本或日志
- [ ] 推送前对全部文件做密文扫描：`github_pat_`、`ghp_`、`gho_`、`ghs_`、`ghr_`、`sk-`、`AKIA…`、`-----BEGIN … PRIVATE KEY-----` 命中即中止并提示
- [ ] 输出脱敏：`gh auth status` 里 token 按 `github_pat_***…` 掩码展示
- [ ] 永不把用户粘贴进对话的 token 回显或写入文件
- [ ] 提交信息与文件不含密钥、账号密码、隐私数据
- [ ] （v1.4）**个人信息防推**：`local-profile.json` / `config.local.json` 出现在源目录 → push.ps1 中止（PERSONAL DATA GUARD），绝不发布
- [ ] （v1.4）**动作门控**：涉及本机档案/个人信息的动作先特意询问并强调（⚠️ 本机专有）；普通推送一句确认即可
- [ ] （v1.5）**省 token 翻译**：多语言走增量编辑翻译（不全文重翻）；保留清单（语言栏/徽章 URL/链接/锚点/命令/环境变量/文件名）未破坏

## 参考

- `references/security.md`：隐私与账号安全细则（脱敏、密文扫描清单、密钥轮换处置）
- `references/platform-adapter.md`：DSH / Codex / Claude Code 机制映射（GH_CONFIG_DIR、子代理、弹框等价物）
- `references/i18n.md`：多语言发布协议（6 语言清单、省 token 增量编辑翻译、效率要点、翻译规范）