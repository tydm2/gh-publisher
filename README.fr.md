# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publiez des fichiers sur GitHub sans git — économe en tokens, respectueux de la vie privée, multi-agents.**

`gh-publisher` est une compétence d'agent qui publie un répertoire local vers un dépôt GitHub en utilisant la CLI `gh` + l'API REST GitHub (Contents / Git Database) — sans avoir besoin de git. Elle gère l'initialisation des dépôts vides et les commits par lots avec un script réutilisable, de sorte que les agents poussent en une seule commande au lieu de re-dériver tout le flux de l'API.

## Ce qui le distingue

- **🚀 Push sans git** — fonctionne sur des machines sans git ; initialise automatiquement les dépôts vides.
- **⚡ Économe en tokens** — une seule commande `scripts/push.ps1` fait scan → init → commit par lots → sortie masquée (une seule ligne `PUSHED N files -> URL`), au lieu de dizaines d'appels API faits à la main.
- **🔒 Vie privée & sécurité du compte** — les tokens ne vivent que dans le keyring de `gh` (jamais dans le chat/les logs/les fichiers) ; les fichiers sont soumis à un secret scan avant le push (`github_pat_`, `ghp_`, `sk-`, clés privées…) ; la sortie est masquée.
- **🔌 Adaptable multi-agents** — le script `pwsh` tourne sous Windows/macOS/Linux ; les correspondances DSH / Codex / Claude Code sont documentées ; aucun nom d'outil de plateforme codé en dur.
- **🧩 Initialisation auto des dépôts vides** — détecte les dépôts vides et amorce le premier fichier via l'API Contents avant le commit par lots.

## Comment ça marche

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → abandon sur tout motif de clé/token (sauf avec `-ForceSecret`).
3. Détecte un dépôt vide → amorce le premier fichier (API Contents) si nécessaire.
4. Commit par lots de tous les fichiers (API Git Database : blobs → tree → commit → ref).
5. Affiche `PUSHED N files -> https://github.com/owner/repo` — rien d'autre.

## Installation

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # par projet
```

Déclenchez-le avec des phrases comme *« push this to GitHub »*, *« publish this skill to a repo »* — ou via l'entrée ⑤ du menu `/skill` de **set-skill**.

## Docs

- `references/security.md` — vie privée & sécurité du compte
- `references/platform-adapter.md` — correspondance DSH / Codex / Claude Code

## Compétences compagnes

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — répertorie cette compétence comme entrée ⑤ du menu `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publiez avec celle-ci les workflows multi-agents qu'il génère.

## Prérequis

- CLI `gh` (connectée via `gh auth login`) + `pwsh` (PowerShell Core, multiplateforme).

## Avertissement

> **Cette compétence est 100 % générée par IA.** Les problèmes sont inévitables — les discussions et les pull requests sont les bienvenues. L'auteur l'itère activement en s'appuyant sur l'utilisation réelle.

## Licence

[MIT](./LICENSE)
