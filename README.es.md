# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publica archivos en GitHub sin git: eficiente en tokens, seguro para la privacidad y multiagente.**

`gh-publisher` es una habilidad (skill) para agentes que publica un directorio local en un repositorio de GitHub usando la CLI `gh` + la API REST de GitHub (Contents / Git Database), sin necesidad de git. Gestiona la inicialización de repositorios vacíos y los commits por lotes con un único script reutilizable, de modo que los agentes publican con un solo comando en lugar de tener que reconstruir todo el flujo de la API.

## Por qué destaca

- **🚀 Push sin git** — funciona en máquinas sin git; inicializa repositorios vacíos automáticamente.
- **⚡ Eficiente en tokens** — un solo comando `scripts/push.ps1` hace escaneo → inicialización → commit por lotes → salida enmascarada (una única línea `PUSHED N files -> URL`), en lugar de decenas de llamadas a la API escritas a mano.
- **🔒 Privacidad y seguridad de la cuenta** — los tokens viven únicamente en el keyring de `gh` (nunca en el chat, logs ni archivos); los archivos se someten a un secret scan antes del push (`github_pat_`, `ghp_`, `sk-`, claves privadas…); la salida está enmascarada.
- **🔌 Adaptable a múltiples agentes** — el script `pwsh` funciona en Windows/macOS/Linux; mapeos documentados para DSH / Codex / Claude Code; sin nombres de herramientas de plataforma codificados de forma rígida.
- **🧩 Inicialización automática de repos vacíos** — detecta repos vacíos y siembra el primer archivo mediante la API Contents antes del commit por lotes.

## Cómo funciona

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → aborta ante cualquier patrón de clave/token (salvo con `-ForceSecret`).
3. Detecta un repo vacío → siembra el primer archivo (API Contents) si es necesario.
4. Commit por lotes de todos los archivos (API Git Database: blobs → tree → commit → ref).
5. Imprime `PUSHED N files -> https://github.com/owner/repo` — nada más.

## Instalación

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # por proyecto
```

Actívala con frases como *"push this to GitHub"*, *"publish this skill to a repo"* — o mediante el elemento ⑤ del menú `/skill` de **set-skill**.

## Documentación

- `references/security.md` — privacidad y seguridad de la cuenta
- `references/platform-adapter.md` — mapeo DSH / Codex / Claude Code

## Habilidades complementarias

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lista esta habilidad como el elemento ⑤ del menú `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publica con esta habilidad los flujos de trabajo multiagente que genera.

## Requisitos

- CLI `gh` (con sesión iniciada mediante `gh auth login`) + `pwsh` (PowerShell Core, multiplataforma).

## Aviso legal

> **Esta habilidad está 100% creada por IA.** Los problemas son inevitables: las discusiones y los pull requests son bienvenidos. El autor la itera activamente basándose en su uso en el mundo real.

## Licencia

[MIT](./LICENSE)
