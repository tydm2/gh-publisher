# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Dateien ohne git zu GitHub veröffentlichen — token-effizient, datenschutzfreundlich, multi-agent, mehrsprachig.**

`gh-publisher` ist eine Agent-Skill, die ein lokales Verzeichnis mithilfe der `gh`-CLI + GitHub-REST-API (Contents / Git Database) in ein GitHub-Repository veröffentlicht — ganz ohne git. Sie übernimmt die Initialisierung leerer Repositories und Batch-Commits mit einem wiederverwendbaren Skript, sodass Agents mit einem einzigen Befehl pushen, statt den gesamten API-Ablauf neu abzuleiten. Außerdem veröffentlicht sie **10 der meistgenutzten GitHub-Sprachen** (README-Übersetzungen), während die lokale Arbeitskopie in deiner bevorzugten Sprache bleibt.

## Warum sie heraussticht

- **🚀 Git-freies Pushen** — funktioniert auf Rechnern ohne git; initialisiert leere Repositories automatisch.
- **⚡ Token-effizient** — ein einziger `scripts/push.ps1`-Befehl macht Guard → Scan → Init → Batch-Commit → maskierte Ausgabe (eine einzige Zeile `PUSHED N files -> URL`) statt Dutzender handgeschriebener API-Aufrufe.
- **🌍 Token-effiziente Übersetzungen** — mehrsprachige READMEs werden per **Inkrementelle-Edit-Übersetzung** aktualisiert (Unteragenten bearbeiten nur die geänderten Absätze auf Basis der alten Übersetzung, keine vollständige Neuübersetzung): ~70–90 % weniger Output-Tokens, schneller, und Terminologie/Stil bleiben stabil.
- **🔒 Datenschutz & Kontosicherheit** — Tokens leben nur im `gh`-Keyring (niemals in Chat/Logs/Dateien); Dateien werden vor dem Push auf Geheimnisse gescannt (`github_pat_`, `ghp_`, `sk-`, private Schlüssel …); die Ausgabe wird maskiert.
- **🛡️ Schutz personenbezogener Daten** — das rechnerlokale Profil (`local-profile.json` / `config.local.json`) kann **niemals** veröffentlicht werden: Der Push bricht in dem Moment ab, in dem eine solche Datei in der Quelle auftaucht, bevor irgendetwas anderes ausgeführt wird.
- **🗂️ Rechnerlokales Profil** — auf einem Rechner mit kniffligem Netzwerk (z. B. gekaperte Hosts) bündelt eine `local-profile.json` das Konto, den gh-Eintrag (einen Proxy-Modus-Shim) und das bekannte Repo-Mapping, sodass Pushes nur noch `-Profile` benötigen — kein Suchen mehr nach Konto / gh / Repo.
- **🔌 Multi-agent anpassbar** — das `pwsh`-Skript läuft unter Windows/macOS/Linux; Mappings für DSH / Codex / Claude Code sind dokumentiert; keine fest verdrahteten Plattform-Toolnamen.
- **🧩 Automatische Init leerer Repos** — erkennt leere Repositories und legt die erste Datei über die Contents-API an, bevor der Batch-Commit erfolgt.
- **🌍 Mehrsprachiges Veröffentlichen** — die lokale Arbeitskopie bleibt in der gewählten Sprache (Standard: Chinesisch); Releases enthalten README-Übersetzungen für die 10 meistgenutzten GitHub-Sprachen (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Siehe `references/i18n.md`.

## So funktioniert es

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Lokalisiert die `gh`-Binärdatei automatisch (`-GhPath` → PATH → übliche Installationspfade) und erkennt `GH_CONFIG_DIR` automatisch — kein manuelles PATH/Config-Gefummel. Mit `-Profile` werden der gh-Eintrag, das Config-Verzeichnis, das Repo (abgeglichen über das Quellverzeichnis) und die Sprachen (automatisch erkannt aus `README.<lang>.md`) automatisch aufgelöst.
3. **Schutz personenbezogener Daten** — `local-profile.json` / `config.local.json` in der Quelle → Abbruch (sie dürfen niemals veröffentlicht werden).
4. Geheimnis-Scan → Abbruch bei jedem Schlüssel-/Token-Muster (außer mit `-ForceSecret`).
5. Leeres Repo erkennen, indem der Branch-Ref geprüft wird (404 = leer) → bei Bedarf erste Datei anlegen (Contents-API).
6. Alle Dateien per Batch-Commit einchecken (Git-Database-API: Blobs → Tree → Commit → Ref).
7. `PUSHED N files -> https://github.com/owner/repo` ausgeben — sonst nichts. Fehlt das Repo, wird ein Hinweis auf `gh repo create` ausgegeben.
8. Optionaler `-Languages`-Check: prüft, ob jede Sprachdatei vorhanden ist (z. B. `README.hi.md`), bevor gepusht wird, und warnt, wenn welche fehlen.

## Mehrsprachiges Veröffentlichen (lokale Sprache + 10 Release-Sprachen)

- **Lokale Arbeitskopie**: bleibt in deiner konfigurierten Sprache (zh oder en) — `config.local.json` im installierten Skill-Verzeichnis (Standard `zh`). Sage *"change local default language to English"*, um zu wechseln; die lokale SKILL.md wird entsprechend aktualisiert.
- **Release**: `SKILL.md` bleibt auf Englisch (der universelle GitHub-Primärtext), während `README.<lang>.md` für die 10 meistgenutzten Sprachen veröffentlicht wird. Siehe `references/i18n.md` für die Sprachliste, Übersetzungsregeln und Hinweise zum Trigger-Vertrag (alle Sprachversionen behalten denselben `name`).
- **Token-effizientes festes Schema**: Sprachen mit einer bestehenden Übersetzung werden per Inkrementelle-Edit-Übersetzung aktualisiert (nur die geänderten Absätze bearbeiten — keine vollständige Neuübersetzung); Sprachen zum ersten Mal erhalten eine vollständige Übersetzung, die die Terminologie-Baseline etabliert. Siehe `references/i18n.md` §1.5.

## Gemessene Ergebnisse: v1.4.0 → v1.5.0 (Inkrementelle-Edit-Übersetzung)

Das 11-sprachige README-Update für dieses Release war der erste Lauf des Inkrementelle-Edit-Schemas. Wir haben es gegen die bisherige vollständige Neuübersetzung gemessen, anhand der tatsächlichen v1.4.0-Dateien (aus dem Repo bei Commit `40dcf1f` geholt) im Vergleich zu den ausgelieferten v1.5.0-Dateien (Diff auf Zeilenebene):

| Metrik | Vollständige Neuübersetzung (v1.4-Ära) | Inkrementelle-Edit (v1.5) | Gespart |
|---|---|---|---|
| Output-Inhalt, 11 Sprachen | 68,292 Zeichen | 7,717 Zeichen | **88.7%** |
| Ungefähre Output-Tokens (~3 Zeichen/Token) | ~22,800 | ~2,600 | **~88.7%** |
| Terminologie / Stil | kann pro Release abweichen | alte Übersetzungen byte-identisch außer geänderten Absätzen | stabil |
| Aufwand pro Sprache | gesamte Datei neu generieren | ~4 gezielte Edits | schneller |

Geänderter Anteil pro Sprache (geänderte Zeichen / alte vollständige Datei): zh-CN 9.1% · hi 10.8% · es 11.9% · fr 12.5% · ar 12.2% · bn 11.3% · pt 11.6% · ru 12.0% · ja 8.9% · de 12.3% · ko 9.4% — **nur ~9-12% jeder Datei haben sich tatsächlich geändert**, sodass die vollständige Neuübersetzung ~8-11× mehr Output verbrauchte als nötig.

*Methode: v1.4.0-Dateien aus dem Repo bei Commit `40dcf1f` geholt; Diff auf Zeilenebene pro Sprache (hinzugefügte/geänderte Zeilen) im Vergleich zu den ausgelieferten v1.5.0-Dateien; Tokens bei gemischtsprachigen READMEs mit ~3 Zeichen/Token angenähert. Auch die Input-Seite kostet anders (die Inkrementelle-Edit-Übersetzung liest die alte Übersetzung), aber der Output ist der dominierende, teuerste Teil der LLM-Übersetzung.*

## Rechnerlokales Profil (local-profile)

Auf Rechnern mit nicht standardmäßigem Netzwerk (z. B. eine Hosts-Datei, die GitHub-Domains auf 127.0.0.1 umleitet, plus ein portables `gh`, das über einen lokalen Proxy-Shim laufen muss), bündelt `E:\ds harness\gh\local-profile.json` den Owner, den gh-Eintrag, das Config-Verzeichnis und das bekannte Repo-Mapping. Die Datei ist mit `"never_publish": true` gekennzeichnet — sie lebt nur auf dem Rechner und wird niemals gepusht. Jede Aktion, die sie liest/ändert, verlangt zuerst eine ausdrücklich hervorgehobene Bestätigung.

## Umgebungs-Selbsttest (einmal vor dem ersten Push)

- `Get-Command gh` (oder das Skript Installationspfade automatisch erkennen lassen); falls fehlend: `winget install GitHub.cli`.
- `gh auth status` zeigt ein angemeldetes Konto (Token maskiert als `github_pat_***…`).
- `gh api repos/{owner}/{repo}` oder `gh repo list` liefert Daten.

## Installation

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # pro Projekt
```

Auslösen mit Sätzen wie *"push this to GitHub"*, *"publish this skill to a repo"* — oder über **set-skill**s `/skill`-Menüpunkt ⑤.

## Dokumentation

- `references/security.md` — Datenschutz & Kontosicherheit
- `references/platform-adapter.md` — DSH / Codex / Claude Code-Mapping
- `references/i18n.md` — mehrsprachiges Veröffentlichungsprotokoll (10 Sprachen, Inkrementelle-Edit-Übersetzung)

## Begleitskills

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — listet diese Skill als `/skill`-Menüpunkt ⑤ auf.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — veröffentliche die von ihr erzeugten Multi-Agent-Workflows mit dieser Skill.

## Voraussetzungen

- `gh`-CLI (angemeldet über `gh auth login`) + `pwsh` (PowerShell Core, plattformübergreifend).

## Haftungsausschluss

> **Diese Skill ist zu 100 % KI-gefertigt.** Fehler sind unvermeidlich — Diskussionen und Pull-Requests sind willkommen. Der Autor verbessert sie aktiv auf Grundlage realer Nutzung.

## Lizenz

[MIT](./LICENSE)
