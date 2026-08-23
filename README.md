# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publish files to GitHub without git — token-efficient, privacy-safe, multi-agent.**

`gh-publisher` is an agent skill that publishes a local directory to a GitHub repository using the `gh` CLI + GitHub REST API (Contents / Git Database) — no git required. It handles empty-repo initialization and batch commits with one reusable script, so agents push in one command instead of re-deriving the whole API flow.

## Why it stands out

- **🚀 Git-free push** — works on machines with no git; initializes empty repositories automatically.
- **⚡ Token-efficient** — one `scripts/push.ps1` command does scan → init → batch commit → masked output (a single `PUSHED N files -> URL` line), instead of dozens of hand-rolled API calls.
- **🔒 Privacy & account security** — tokens live only in the `gh` keyring (never in chat/logs/files); files are secret-scanned before push (`github_pat_`, `ghp_`, `sk-`, private keys…); output is masked.
- **🔌 Multi-agent adaptable** — `pwsh` script runs on Windows/macOS/Linux; DSH / Codex / Claude Code mappings documented; no hardcoded platform tool names.
- **🧩 Auto empty-repo init** — detects empty repos and seeds the first file via the Contents API before the batch commit.

## How it works

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → abort on any key/token pattern (unless `-ForceSecret`).
3. Detect empty repo → seed first file (Contents API) if needed.
4. Batch commit all files (Git Database API: blobs → tree → commit → ref).
5. Print `PUSHED N files -> https://github.com/owner/repo` — nothing else.

## Install

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

Trigger it with phrases like *"push this to GitHub"*, *"publish this skill to a repo"* — or via **set-skill**'s `/skill` menu item ⑤.

## Docs

- `references/security.md` — privacy & account security
- `references/platform-adapter.md` — DSH / Codex / Claude Code mapping

## Companion skills

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lists this skill as `/skill` menu item ⑤.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publish the multi-agent workflows it generates with this one.

## Requirements

- `gh` CLI (logged in via `gh auth login`) + `pwsh` (PowerShell Core, cross-platform).

## Disclaimer

> **This skill is 100% AI-crafted.** Issues are inevitable — discussion and pull requests are welcome. The author actively iterates on it based on real-world usage.

## License

[MIT](./LICENSE)
