# Changelog

All notable changes to `gh-publisher` are documented here. The skill follows [Semantic Versioning](https://semver.org/).

## [1.3.0] — 2026-08-24 — multilingual is now a DEFAULT push step

Driven by a real gap: pushing a skill repo without the 10-language step (create-generate-skill v4.8.0 shipped single-language).

- **Multilingual promoted from "optional readiness check" to a default push step** for skill/doc projects: generate the 10-language READMEs (parallel agents) → `-Languages` check → push; skipped only on explicit user opt-out.
- **`references/i18n.md`**: new section 0 "Auto-trigger & execution flow" (trigger, opt-out wording, 4-step execution, scope: READMEs translated, SKILL.md single primary, references/scripts not translated).
- **`push.ps1 -RequireI18n`**: hard enforcement — missing language files now FAIL the push (exit 1) instead of only warning.
- SKILL.md (en/zh) reworded: "Multilingual publish" → default step with execution flow.

## [1.2.0] — 2026-08-24 — multilingual publish

- **Local language preference**: the installed working copy keeps a configurable language (zh/en, default `zh`) persisted in `config.local.json`; say *"change local default language to English"* to switch, and the local SKILL.md follows.
- **10 release languages**: README translations now cover GitHub's 10 most-used natural languages — en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja (ar + bn added; de/ko kept as v1.0.0 snapshots).
- **`references/i18n.md`** (en/zh): multilingual publish protocol — language list, translation rules, file layout, trigger-contract notes (all language versions share the same `name`).
- **`push.ps1 -Languages`** check: verifies each language file exists (e.g. `README.hi.md`) before pushing and warns if any are missing.
- README (en/zh-CN) updated with the 10-language switcher bar and a "Multilingual publish" section.

## [1.1.0] — 2026-08-24 — usage-driven iteration

Iterated from real-world usage (pushing office-studio + office-imagegen-skill revealed six friction points):

- **Auto-detect the `gh` binary**: new `-GhPath` parameter + common install-path probing (`Program Files\GitHub CLI`, `LocalAppData`, `Program Files\gh`) — previously the script hard-failed when `gh` was not on PATH.
- **Auto-detect `GH_CONFIG_DIR`**: `-GhConfigDir` → `$env:GH_CONFIG_DIR` → `%APPDATA%\GitHub CLI` — no manual config fiddling.
- **Robust empty-repo detection**: now checks the branch git ref (404 = no commit yet = empty) instead of `repo.size == 0`, which falsely treated README-only repos as empty.
- **Repo-not-found hint**: prints `gh repo create <owner>/<repo> --public --source <dir> --push` instead of failing silently.
- **Surfaced API errors**: `gh api` stderr tail is now included in failure messages for diagnosis.
- **Documented `-ExecutionPolicy Bypass`** usage (PowerShell policy blocked `& script.ps1` on locked-down machines).
- **Environment self-check section** added to SKILL.md (en/zh) and README (en/zh): gh availability, `gh auth status`, connectivity probe.
- Multi-language READMEs other than en/zh-CN remain v1.0.0 snapshots; en/zh-CN are the source of truth.

## [1.0.0] — Initial English release

- First public release for GitHub.
- `SKILL.md` + `references/security.md` + `references/platform-adapter.md` in English.
- `scripts/push.ps1`: one-command git-free publish (secret scan → empty-repo init → batch commit → masked output).
- Multi-language README (10 languages).
- MIT license + AI-crafted disclaimer.

> The local Chinese version lives at `~/.dsh/skills/gh-publisher/` and remains the working copy on the author's machine.
