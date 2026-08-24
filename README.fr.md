# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publiez des fichiers sur GitHub sans git — économe en tokens, respectueux de la vie privée, multi-agent, multilingue.**

`gh-publisher` est une compétence d'agent qui publie un répertoire local vers un dépôt GitHub à l'aide de la CLI `gh` + de l'API REST GitHub (Contents / Git Database) — sans git requis. Elle gère l'initialisation des dépôts vides et les commits par lots avec un seul script réutilisable, si bien que les agents poussent en une seule commande au lieu de redériver tout le flux d'API. Elle publie également **10 des langues les plus utilisées de GitHub** (traductions du README) tandis que la copie de travail locale reste dans votre langue préférée.

## Pourquoi elle se distingue

- **🚀 Push sans git** — fonctionne sur les machines sans git ; initialise automatiquement les dépôts vides.
- **⚡ Économe en tokens** — une seule commande `scripts/push.ps1` fait garde → scan → init → commit par lots → sortie masquée (une seule ligne `PUSHED N files -> URL`), au lieu de dizaines d'appels d'API bricolés à la main.
- **🌍 Traductions économes en tokens** — les README multilingues sont mis à jour via la **traduction par édition incrémentale** (les sous-agents ne modifient que les paragraphes changés par-dessus l'ancienne traduction, sans re-traduction complète) : ~70–90 % de tokens de sortie en moins, plus rapide, et la terminologie/le style restent stables.
- **🔒 Vie privée et sécurité du compte** — les tokens ne vivent que dans le trousseau de `gh` (jamais dans les discussions/journaux/fichiers) ; les fichiers sont scannés à la recherche de secrets avant le push (`github_pat_`, `ghp_`, `sk-`, clés privées…) ; la sortie est masquée.
- **🛡️ Garde-fou des données personnelles** — le profil local à la machine (`local-profile.json` / `config.local.json`) ne peut **jamais** être publié : le push s'interrompt dès qu'un tel fichier apparaît dans la source, avant que quoi que ce soit d'autre ne s'exécute.
- **🗂️ Profil local à la machine** — sur une machine au réseau capricieux (p. ex. détournement via le fichier hosts), un seul `local-profile.json` regroupe le compte, l'entrée gh (un adaptateur en mode proxy) et le mappage des dépôts connus, si bien que les pushes n'ont besoin que de `-Profile` — fini la chasse au compte / gh / dépôt.
- **🔌 Adaptable multi-agent** — le script `pwsh` fonctionne sur Windows/macOS/Linux ; les correspondances DSH / Codex / Claude Code sont documentées ; aucun nom d'outil de plateforme codé en dur.
- **🧩 Initialisation automatique des dépôts vides** — détecte les dépôts vides et dépose le premier fichier via l'API Contents avant le commit par lots.
- **🌍 Publication multilingue** — la copie de travail locale reste dans la langue de votre choix (chinois par défaut) ; les publications embarquent les traductions du README pour les 10 langues les plus utilisées de GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Voir `references/i18n.md`.

## Comment ça fonctionne

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Localise automatiquement le binaire `gh` (`-GhPath` → PATH → chemins d'installation courants) et détecte automatiquement `GH_CONFIG_DIR` — pas de bricolage manuel du PATH/de la configuration. Avec `-Profile`, l'entrée gh, le répertoire de configuration, le dépôt (correspondant au répertoire source) et les langues (auto-détectées à partir de `README.<lang>.md`) sont résolus automatiquement.
3. **Garde-fou des données personnelles** — `local-profile.json` / `config.local.json` dans la source → interruption (ils ne doivent jamais être publiés).
4. Scan des secrets → interruption sur tout motif de clé/token (sauf avec `-ForceSecret`).
5. Détecte le dépôt vide en vérifiant la référence de branche (404 = vide) → dépose le premier fichier (API Contents) si nécessaire.
6. Commit par lots de tous les fichiers (API Git Database : blobs → tree → commit → ref).
7. Affiche `PUSHED N files -> https://github.com/owner/repo` — rien d'autre. Dépôt manquant → affiche une indication `gh repo create`.
8. Contrôle optionnel `-Languages` : vérifie que chaque fichier de langue existe (p. ex. `README.hi.md`) avant de pousser et avertit si l'un d'eux manque.

## Publication multilingue (langue locale + 10 langues de publication)

- **Copie de travail locale** : reste dans la langue configurée (zh ou en) — `config.local.json` dans le répertoire d'installation de la compétence (défaut `zh`). Dites *« change local default language to English »* pour basculer ; le SKILL.md local est mis à jour en conséquence.
- **Publication** : `SKILL.md` reste en anglais (la langue primaire universelle de GitHub), tandis que `README.<lang>.md` est publié pour les 10 langues les plus utilisées. Voir `references/i18n.md` pour la liste des langues, les règles de traduction et les notes sur le contrat de déclenchement (toutes les versions linguistiques conservent le même `name`).
- **Schéma fixe économe en tokens** : les langues disposant déjà d'une traduction sont mises à jour via la traduction par édition incrémentale (modifier uniquement les paragraphes changés — pas de re-traduction complète) ; les langues traduites pour la première fois reçoivent une traduction complète qui établit la référence de terminologie. Voir `references/i18n.md` §1.5.

## Profil local à la machine (local-profile)

Sur les machines au réseau non standard (p. ex. un fichier hosts qui détourne les domaines GitHub vers 127.0.0.1, plus un `gh` portable qui doit passer par un adaptateur proxy local), `E:\ds harness\gh\local-profile.json` regroupe le propriétaire, l'entrée gh, le répertoire de configuration et le mappage des dépôts connus. Ce fichier est marqué `"never_publish": true` — il ne vit que sur la machine et n'est jamais poussé. Toute action qui le lit/le modifie exige d'abord une confirmation explicitement mise en évidence.

## Auto-vérification de l'environnement (une fois avant le premier push)

- `Get-Command gh` (ou laissez le script détecter automatiquement les chemins d'installation) ; s'il manque : `winget install GitHub.cli`.
- `gh auth status` affiche un compte connecté (token masqué en `github_pat_***…`).
- `gh api repos/{owner}/{repo}` ou `gh repo list` renvoie des données.

## Installation

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # par projet
```

Déclenchez-la avec des phrases comme *« push this to GitHub »*, *« publish this skill to a repo »* — ou via l'élément de menu `/skill` de **set-skill** (⑤).

## Documentation

- `references/security.md` — vie privée et sécurité du compte
- `references/platform-adapter.md` — correspondance DSH / Codex / Claude Code
- `references/i18n.md` — protocole de publication multilingue (10 langues, traduction par édition incrémentale)

## Compétences associées

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — liste cette compétence comme élément de menu `/skill` (⑤).
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publiez avec celle-ci les workflows multi-agents qu'il génère.

## Prérequis

- CLI `gh` (connectée via `gh auth login`) + `pwsh` (PowerShell Core, multiplateforme).

## Disclaimer

> **Cette compétence est 100 % conçue par IA.** Les problèmes sont inévitables — les discussions et les pull requests sont les bienvenues. L'auteur l'améliore activement en fonction de son utilisation réelle.

## License

[MIT](./LICENSE)
