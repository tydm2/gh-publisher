# gh-publisher 需求记忆（feedback-log，运行期迭代用）

> 按 set-skill 协议维护：存对话的蒸馏产物，不存全文；iterate/audit 时全量读；每条 ≤120 字；`#` 开头为硬约束；重复需求更新而非堆叠。

## 活跃需求（未消费）

（暂无）

## 已消费需求

- [2026-08-26] 对象:gh-publisher | 意图:revise | 需求本质:多语言从 10 种收敛为 6 种（en/zh-CN/es/fr/ja/ru）并优化翻译效率——只改翻译环节，别做别的 | 期望:v1.6.0 SKILL.md/i18n.md 语言清单与 -Languages 改为 6 语言；i18n.md 新增 §1.6 效率要点（减量 40%、语言栏只列 6 语言避免死链、代码块字节级保留）；已发布旧语言（hi/ar/bn/pt/de/ko）不回删不新增 | 上下文要点:用户要求聚焦翻译环节减量与提效；office-studio 已按 6 语言推送 | 优先级:高 [consumed by v1.6.0]

- [2026-08-24] 对象:gh-publisher | 意图:revise | 需求本质:多语言翻译每次全文重翻 11 语言太费 token/慢——选定一种更快捷更省 token 的固定方案即可，不要社区调研 | 期望:v1.5.0 默认走增量编辑翻译（子代理读旧译文+新英文源，编辑操作只改变化段落，不全文重翻）；i18n.md 新增 §1.5 固定方案与不译清单（项目名/命令/CLI flags/环境变量/文件名/徽章 URL）；首次翻译建术语基线 | 上下文要点:用户明确不要调研社区；保留清单参照 readme-i18n；术语/风格以旧译文为准 | 优先级:高 [consumed by v1.5.0]

- [2026-08-24] 对象:gh-publisher | 意图:revise | 需求本质:本机推送账号/路径/仓库信息分散难识别（gh 不在 PATH、hosts 被 Steam++ 劫持、token 在 keyring）——固化为本机专属档案 local-profile.json（owner/gh 代理入口/配置目录/仓库映射/网络说明，标记 never_publish）；push.ps1 加 -Profile 自动识别；含个人信息文件（local-profile.json/config.local.json）永不推送 GitHub；普通内容推送一句确认即可 | 期望:push.ps1 加 -Profile/-Repo 可选/语言自动检测/PERSONAL DATA GUARD 中止；SKILL.md 加本机档案节与个人信息硬规则（四条硬原则+安全红线+2）；档案只存本机绝不外发 | 上下文要点:用户明确——仅含个人信息的档案不能推，其它问一句就行；不需本地归档脚本；本机档案动作需特意询问并强调 | 优先级:高 [consumed by v1.4.0]
- [2026-08-24] 对象:gh-publisher | 意图:fix | 需求本质:推 code-forge-skill（全新空仓库）时复现——git refs 探测返回 HTTP 409「Git Repository is empty」且 gh 写 stderr，脚本全局 $ErrorActionPreference='Stop'（PS 7.2+）把 stderr 当终止性错误，空仓库初始化前脚本即中断 | 期望:Invoke-GhApi 内临时降级 EAP 为 Continue（成败以 $LASTEXITCODE 为准），空仓库自动走 Contents API 初始化 | 上下文要点:先变通（手动 PUT README 再批量提交）后修复；修复后以全新空仓库实测通过 | 优先级:高 [consumed by v1.3.1]
- [2026-08-24] 对象:gh-publisher | 意图:iterate | 需求本质:实际推送暴露六处摩擦——gh 不在 PATH、执行策略拦截、size==0 误判 README-only 仓库为空、仓库不存在静默失败、GH_CONFIG_DIR 手动设置、API 错误被吞 | 期望:v1.1.0 脚本自动探测 gh(-GhPath)/配置、文档化 -ExecutionPolicy Bypass、按 git refs 判空、仓库不存在给 gh repo create 提示、API 失败可见 stderr；SKILL/README 加环境自检小节 | 上下文要点:本次迭代由真实使用驱动（推 office-studio/office-imagegen-skill 时逐条复现）| 优先级:高 [consumed by v1.1.0]
- [2026-08-24] 对象:gh-publisher | 意图:revise | 需求本质:多语言发布——本地保留用户语言（zh/en 可配置、一句话切换），发布版带 GitHub 最常用 10 语言 | 期望:v1.2.0 config.local.json 存 local_lang、README.<lang>.md ×10（en/zh-CN/hi/es/fr/ar/bn/pt/ru/ja）、references/i18n.md 协议、push.ps1 -Languages 就绪检查；本地中文 SKILL 不动 | 上下文要点:用户选择本地默认中文 | 优先级:高 [consumed by v1.2.0]
- [2026-08-24] 对象:gh-publisher | 意图:revise | 需求本质:多语言步骤未自动执行——推 create-generate-skill 时只有单语言 README；根因=就绪检查仅可选、无自动触发协议、无强制手段 | 期望:v1.3.0 多语言升级为技能/文档项目推送默认步骤（生成 10 README→检查→推送，仅用户明确豁免才跳过）、i18n.md 第 0 章自动触发与执行流程、push.ps1 -RequireI18n 缺失语言文件即 FAIL | 上下文要点:已验证 create-generate-skill 线上补齐 10 语言 README | 优先级:高 [consumed by v1.3.0]