# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Dateien ohne git nach GitHub veröffentlichen — token-effizient, datenschutzsicher, multi-agent-fähig.**

`gh-publisher` ist ein Agent-Skill, der ein lokales Verzeichnis mithilfe der `gh` CLI und der GitHub REST API (Contents / Git Database) in ein GitHub-Repository veröffentlicht — ganz ohne git. Er übernimmt die Initialisierung leerer Repositories und Batch-Commits mit einem einzigen wiederverwendbaren Skript, sodass Agents mit einem einzigen Befehl pushen, statt den gesamten API-Ablauf jedes Mal neu herzuleiten.

## Was ihn auszeichnet

- **🚀 Push ohne git** — funktioniert auf Rechnern ohne git; initialisiert leere Repositories automatisch.
- **⚡ Token-effizient** — ein einziger `scripts/push.ps1`-Befehl erledigt Scan → Init → Batch-Commit → maskierte Ausgabe (eine einzige Zeile `PUSHED N files -> URL`), statt dutzender handgeschriebener API-Aufrufe.
- **🔒 Datenschutz & Kontosicherheit** — Tokens liegen nur im `gh`-keyring (niemals im Chat/in Logs/in Dateien); Dateien werden vor dem Push einem secret scan unterzogen (`github_pat_`, `ghp_`, `sk-`, private Schlüssel …); die Ausgabe ist maskiert.
- **🔌 Multi-Agent-tauglich** — das `pwsh`-Skript läuft unter Windows/macOS/Linux; die Zuordnungen für DSH / Codex / Claude Code sind dokumentiert; keine fest verdrahteten Plattform-Toolnamen.
- **🧩 Automatische Empty-Repo-Initialisierung** — erkennt leere Repositories und setzt die erste Datei vor dem Batch-Commit über die Contents API.

## So funktioniert es

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → Abbruch bei jedem Schlüssel-/Token-Muster (außer mit `-ForceSecret`).
3. Leeres Repository erkennen → bei Bedarf erste Datei setzen (Contents API).
4. Batch-Commit aller Dateien (Git Database API: blobs → tree → commit → ref).
5. `PUSHED N files -> https://github.com/owner/repo` ausgeben — sonst nichts.

## Installation

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # pro Projekt
```

Auslösen lässt er sich mit Formulierungen wie *„push this to GitHub"*, *„publish this skill to a repo"* — oder über **set-skill**s `/skill`-Menüpunkt ⑤.

## Dokumentation

- `references/security.md` — Datenschutz & Kontosicherheit
- `references/platform-adapter.md` — Zuordnung für DSH / Codex / Claude Code

## Begleitende Skills

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — führt diesen Skill als `/skill`-Menüpunkt ⑤ auf.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — veröffentlicht die damit generierten Multi-Agent-Workflows mit diesem Skill.

## Voraussetzungen

- `gh` CLI (angemeldet via `gh auth login`) + `pwsh` (PowerShell Core, plattformübergreifend).

## Haftungsausschluss

> **Dieser Skill ist zu 100 % KI-erstellt.** Probleme sind unvermeidlich — Diskussionen und Pull Requests sind willkommen. Der Autor iteriert aktiv auf Basis der realen Nutzung daran weiter.

## Lizenz

[MIT](./LICENSE)
