# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publish files to GitHub without git — token-efficient, privacy-safe, multi-agent, multilingual.**

`gh-publisher` is an agent skill that publishes a local directory to a GitHub repository using the `gh` CLI + GitHub REST API (Contents / Git Database) — no git required. It handles empty-repo initialization and batch commits with one reusable script, so agents push in one command instead of re-deriving the whole API flow. It also publishes **10 of GitHub's most-used languages** (README translations) while the local working copy stays in your preferred language.

## Why it stands out

- **🚀 Git-free push** — works on machines with no git; initializes empty repositories automatically.
- **⚡ Token-efficient** — one `scripts/push.ps1` command does guard → scan → init → batch commit → masked output (a single `PUSHED N files -> URL` line), instead of dozens of hand-rolled API calls.
- **🌍 Token-efficient translations** — multilingual READMEs update via **incremental-edit translation** (subagents edit only the changed paragraphs on top of the old translation, no full re-translation): ~70-90% less output token, faster, and terminology/style stay stable.
- **🔒 Privacy & account security** — tokens live only in the `gh` keyring (never in chat/logs/files); files are secret-scanned before push (`github_pat_`, `ghp_`, `sk-`, private keys…); output is masked.
- **🛡️ Personal-data guard** — the machine-local profile (`local-profile.json` / `config.local.json`) can **never** be published: the push aborts the moment such a file appears in the source, before anything else runs.
- **🗂️ Machine-local profile** — on a machine with tricky networking (e.g. hosts hijacking), one `local-profile.json` consolidates the account, the gh entry (a proxy-mode shim), and the known repo mapping, so pushes need only `-Profile` — no more hunting for account / gh / repo.
- **🔌 Multi-agent adaptable** — `pwsh` script runs on Windows/macOS/Linux; DSH / Codex / Claude Code mappings documented; no hardcoded platform tool names.
- **🧩 Auto empty-repo init** — detects empty repos and seeds the first file via the Contents API before the batch commit.
- **🌍 Multilingual publish** — the local working copy stays in your chosen language (default Chinese); releases ship README translations for GitHub's 10 most-used languages (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). See `references/i18n.md`.

## How it works

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Auto-locates the `gh` binary (`-GhPath` → PATH → common install paths) and auto-detects `GH_CONFIG_DIR` — no manual PATH/config fiddling. With `-Profile`, the gh entry, config dir, repo (matched by source dir) and languages (auto-detected from `README.<lang>.md`) are resolved automatically.
3. **Personal-data guard** — `local-profile.json` / `config.local.json` in the source → abort (they must never be published).
4. Secret scan → abort on any key/token pattern (unless `-ForceSecret`).
5. Detect empty repo by checking the branch ref (404 = empty) → seed first file (Contents API) if needed.
6. Batch commit all files (Git Database API: blobs → tree → commit → ref).
7. Print `PUSHED N files -> https://github.com/owner/repo` — nothing else. Missing repo → prints a `gh repo create` hint.
8. Optional `-Languages` check: verifies each language file exists (e.g. `README.hi.md`) before pushing and warns if any are missing.

## Multilingual publish (local language + 10 release languages)

- **Local working copy**: stays in your configured language (zh or en) — `config.local.json` in the installed skill dir (default `zh`). Say *"change local default language to English"* to switch; the local SKILL.md is updated to match.
- **Release**: `SKILL.md` stays in English (the universal GitHub primary), while `README.<lang>.md` is published for the 10 most-used languages. See `references/i18n.md` for the language list, translation rules, and trigger-contract notes (all language versions keep the same `name`).
- **Token-efficient fixed scheme**: languages with an existing translation update via incremental-edit translation (edit only the changed paragraphs — no full re-translation); first-time languages get one full translation that establishes the terminology baseline. See `references/i18n.md` §1.5.

## Machine-local profile (local-profile)

On machines with non-standard networking (e.g. a hosts file hijacking GitHub domains to 127.0.0.1, plus a portable `gh` that must run through a local proxy shim), `E:\ds harness\gh\local-profile.json` consolidates the owner, the gh entry, the config dir, and the known repo mapping. The file is flagged `"never_publish": true` — it only lives on the machine and is never pushed. Any action that reads/modifies it gets an explicitly emphasized confirmation first.

## Environment self-check (once before first push)

- `Get-Command gh` (or let the script auto-detect install paths); if missing: `winget install GitHub.cli`.
- `gh auth status` shows a logged-in account (token masked as `github_pat_***…`).
- `gh api repos/{owner}/{repo}` or `gh repo list` returns data.

## Install

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

Trigger it with phrases like *"push this to GitHub"*, *"publish this skill to a repo"* — or via **set-skill**'s `/skill` menu item ⑤.

## Docs

- `references/security.md` — privacy & account security
- `references/platform-adapter.md` — DSH / Codex / Claude Code mapping
- `references/i18n.md` — multilingual publish protocol (10 languages, incremental-edit translation)

## Companion skills

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lists this skill as `/skill` menu item ⑤.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publish the multi-agent workflows it generates with this one.

## Requirements

- `gh` CLI (logged in via `gh auth login`) + `pwsh` (PowerShell Core, cross-platform).

## Disclaimer

> **This skill is 100% AI-crafted.** Issues are inevitable — discussion and pull requests are welcome. The author actively iterates on it based on real-world usage.

## License

[MIT](./LICENSE)
