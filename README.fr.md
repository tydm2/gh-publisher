# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publiez des fichiers sur GitHub sans git — économe en tokens, respectueux de la vie privée, multi-agents, multilingue.**

`gh-publisher` est une compétence d'agent qui publie un répertoire local vers un dépôt GitHub à l'aide de la `gh` CLI + l'API REST GitHub (Contents / Git Database) — aucun git requis. Elle gère l'initialisation d'un dépôt vide et les commits par lots avec un seul script réutilisable, de sorte que les agents poussent en une seule commande au lieu de redériver tout le flux d'API. Elle publie également **10 des langues les plus utilisées de GitHub** (traductions README) tandis que la copie de travail locale reste dans votre langue préférée.

## Pourquoi il se démarque

- **🚀 Pousser sans git** — fonctionne sur les machines sans git ; initialise automatiquement les dépôts vides.
- **⚡ Économe en tokens** — une seule commande `scripts/push.ps1` effectue analyse → initialisation → commit par lots → sortie masquée (une seule ligne `PUSHED N files -> URL`), au lieu de dizaines d'appels d'API faits à la main.
- **🔒 Confidentialité et sécurité du compte** — les tokens ne vivent que dans le keyring `gh` (jamais dans le chat/les journaux/les fichiers) ; les fichiers sont analysés à la recherche de secrets avant l'envoi (`github_pat_`, `ghp_`, `sk-`, clés privées…) ; la sortie est masquée.
- **🔌 Adaptable multi-agents** — le script `pwsh` s'exécute sur Windows/macOS/Linux ; les mappages DSH / Codex / Claude Code sont documentés ; aucun nom d'outil de plateforme codé en dur.
- **🧩 Initialisation auto des dépôts vides** — détecte les dépôts vides et sème le premier fichier via l'API Contents avant le commit par lots.
- **🌍 Publication multilingue** — la copie de travail locale reste dans la langue de votre choix (chinois par défaut) ; les versions publiées incluent des traductions README pour les 10 langues les plus utilisées de GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Voir `references/i18n.md`.

## Comment ça fonctionne

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Localise automatiquement le binaire `gh` (`-GhPath` → PATH → chemins d'installation courants) et détecte automatiquement `GH_CONFIG_DIR` — aucun réglage manuel de PATH/config.
3. Analyse des secrets → abandon sur tout motif de clé/token (sauf `-ForceSecret`).
4. Détecte un dépôt vide en vérifiant la référence de branche (404 = vide) → sème le premier fichier (API Contents) si nécessaire.
5. Commit par lots de tous les fichiers (API Git Database : blobs → tree → commit → ref).
6. Affiche `PUSHED N files -> https://github.com/owner/repo` — rien d'autre. Dépôt manquant → affiche une indication `gh repo create`.
7. Vérification optionnelle `-Languages` : vérifie que chaque fichier de langue existe (p. ex. `README.hi.md`) avant de pousser et avertit si certains manquent.

## Publication multilingue (langue locale + 10 langues de diffusion)

- **Copie de travail locale** : reste dans votre langue configurée (zh ou en) — `config.local.json` dans le répertoire de la compétence installée (par défaut `zh`). Dites *« change la langue locale par défaut en anglais »* pour changer ; le SKILL.md local est mis à jour en conséquence.
- **Publication** : `SKILL.md` reste en anglais (la langue principale universelle de GitHub), tandis que `README.<lang>.md` est publié pour les 10 langues les plus utilisées. Voir `references/i18n.md` pour la liste des langues, les règles de traduction et les notes de contrat de déclenchement (toutes les versions linguistiques conservent le même `name`).

## Auto-vérification de l'environnement (une fois avant le premier envoi)

- `Get-Command gh` (ou laissez le script détecter automatiquement les chemins d'installation) ; si absent : `winget install GitHub.cli`.
- `gh auth status` affiche un compte connecté (token masqué en `github_pat_***…`).
- `gh api repos/{owner}/{repo}` ou `gh repo list` renvoie des données.

## Installation

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

Déclenchez-le avec des phrases comme *« pousse ceci sur GitHub »*, *« publie cette compétence vers un dépôt »* — ou via l'élément de menu `/skill` ⑤ de **set-skill**.

## Documentation

- `references/security.md` — confidentialité et sécurité du compte
- `references/platform-adapter.md` — mappage DSH / Codex / Claude Code
- `references/i18n.md` — protocole de publication multilingue (10 langues)

## Compétences compagnes

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — répertorie cette compétence comme élément de menu `/skill` ⑤.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publiez les workflows multi-agents qu'il génère avec celle-ci.

## Prérequis

- `gh` CLI (connectée via `gh auth login`) + `pwsh` (PowerShell Core, multiplateforme).

## Avertissement

> **Cette compétence est 100 % créée par IA.** Les problèmes sont inévitables — les discussions et les pull requests sont les bienvenues. L'auteur itère activement dessus en fonction de l'utilisation réelle.

## Licence

[MIT](./LICENSE)
