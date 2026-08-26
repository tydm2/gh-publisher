# Changelog

All notable changes to `gh-publisher` are documented here. The skill follows [Semantic Versioning](https://semver.org/).

## [1.6.0] — 2026-08-26 — multilingual cut from 10 to 6 release languages

- **6 release languages**: en, zh-CN, es, fr, ja, ru (hi/ar/bn/pt dropped from the set — translation volume −40%); previously published hi/ar/bn/pt/de/ko READMEs are kept for compatibility but no longer maintained or added to.
- **`references/i18n.md` §1.6 "Efficiency points"**: language bar lists only the 6 release languages (no dead links, shorter); code blocks / preserve-list items stay byte-identical (no re-translation); parallel subagents by default.
- **`SKILL.md` / `references/i18n.md`**: language list, execution flow and `-Languages en,zh-CN,es,fr,ja,ru` updated everywhere.

## [1.5.0] — 2026-08-24 — token-efficient fixed scheme: incremental-edit translation

The 11-language README set used to be fully re-translated on every version bump — most tokens went into rewriting unchanged paragraphs, and terminology drifted. v1.5.0 picks ONE fixed, token-efficient way to translate:

- **Incremental-edit translation is now the default**: each parallel subagent reads the old `README.<lang>.md` + the new English `README.md` and applies **file edits only to the changed paragraphs** — unchanged paragraphs stay byte-identical, ~70-90% less output token, faster, and terminology/style stay stable.
- **`references/i18n.md` §1.5**: the fixed scheme (steps, preserve list, terminology consistency, terminology baseline on first translation); translation rules gain a **do-not-translate list** (project names / package names / commands / CLI flags / option names / env vars / file names / badge URLs), readme-i18n style.
- First-time languages still get one full translation, which establishes the terminology baseline for future incremental updates.
## [1.4.0] — 2026-08-24 — machine-local profile & personal-data guard

Machine-local optimization, driven by real friction on this machine (gh not on PATH, GitHub domains hijacked in the hosts file by Steam++, token in the keyring — the account/gh/repo info was scattered and hard to find):

- **Machine-local profile (`local-profile.json`)**: consolidates owner, gh portable entry (proxy-mode shim that bypasses the hosts hijack), `GH_CONFIG_DIR`, and the known repo mapping; flagged `never_publish` — it lives only on the machine and is never pushed to GitHub.
- **`scripts/push.ps1`**: new `-Profile` parameter auto-resolves the gh entry, config dir, repo (matched by source dir) and languages (auto-detected from `README.<lang>.md`); `-Repo` is now optional when the profile resolves it.
- **PERSONAL DATA GUARD**: any `local-profile.json` / `config.local.json` inside the source aborts the push; the check runs before gh lookup so it fires even when gh is missing.
- **Hard rules upgraded to four**: "personal data never leaves the machine" — actions touching the local profile / personal data require an explicitly emphasized confirmation; ordinary pushes need only a one-line confirmation.
- Verified: contract freeze (name / user-invocable unchanged), `-Profile` end-to-end (profile → language auto-detect → proxy shim → GitHub), and the personal-data guard (aborts with no gh installed).
## [1.3.1] — 2026-08-24 — push.ps1 empty-repo 409 fix

Discovered while pushing code-forge-skill: on a brand-new empty repo, probing `git/refs/heads/main` returns HTTP 409 "Git Repository is empty"; gh writes it to stderr, and under PS 7.2+ the script-wide `$ErrorActionPreference='Stop'` turns native stderr into a terminating error — killing the script before the empty-repo init could run.

- **`scripts/push.ps1`**: `Invoke-GhApi` now guards the native `gh` call with a temporary EAP downgrade (`Continue`, restored in a `finally` block); success/failure is decided by `$LASTEXITCODE`, not by stderr.
- Verified end-to-end on a fresh empty repo: auto-seed via Contents API → Git Database batch commit → exit 0.

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
