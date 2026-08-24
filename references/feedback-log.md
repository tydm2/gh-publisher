# gh-publisher feedback log (runtime memory)

> Maintained per the set-skill protocol: distilled requirements only, read fully on iterate/audit, max ~120 chars each; `#` prefix = hard constraint; duplicates update, not stack.

## Active requirements

(none)

## Consumed requirements

- [2026-08-24] object:gh-publisher | intent:fix | essence:reproduced while pushing code-forge-skill — probing refs of a brand-new empty repo returns HTTP 409 "Git Repository is empty"; gh writes stderr, and the script-wide $ErrorActionPreference='Stop' (PS 7.2+) turns stderr into a terminating error killing the script before the empty-repo init | expectation:Invoke-GhApi temporarily downgrades EAP to Continue so $LASTEXITCODE decides; empty repos auto-init via Contents API | context:worked around (manual PUT README) then fixed; verified on a fresh empty repo | priority:high [consumed by v1.3.1]
- [2026-08-24] object:gh-publisher | intent:iterate | essence:six friction points from real pushes (gh not on PATH, execution-policy block, size==0 false-empty on README-only repos, silent repo-missing failure, manual GH_CONFIG_DIR, swallowed API errors) | expectation:v1.1.0 auto-detects gh/config, documents -ExecutionPolicy Bypass, detects empty via git refs, hints gh repo create, surfaces API stderr; self-check section in SKILL/README | context:iteration driven by real usage (pushing office-studio/office-imagegen-skill) | priority:high [consumed by v1.1.0]
- [2026-08-24] object:gh-publisher | intent:revise | essence:multilingual publishing 鈥?local copy keeps the user's language (configurable zh/en, one-phrase switch), releases carry GitHub's 10 most-used languages | expectation:v1.2.0 config.local.json local_lang, README.<lang>.md 脳10 (en/zh-CN/hi/es/fr/ar/bn/pt/ru/ja), references/i18n.md protocol, push.ps1 -Languages readiness check; local zh SKILL.md untouched | context:user chose zh as default local language | priority:high [consumed by v1.2.0]
- [2026-08-24] object:gh-publisher | intent:revise | essence:multilingual step did NOT auto-run 鈥?pushing a skill repo shipped single-language README (create-generate-skill v4.8.0); root causes: optional-only readiness check, no auto-trigger protocol, no enforcement | expectation:v1.3.0 multilingual is a DEFAULT push step for skill/doc projects (generate 10 READMEs 鈫?check 鈫?push; skip only on explicit opt-out), i18n.md section 0 auto-trigger & execution flow, push.ps1 -RequireI18n hard fail on missing language files | context:verified live: create-generate-skill now has all 10 READMEs | priority:high [consumed by v1.3.0]
