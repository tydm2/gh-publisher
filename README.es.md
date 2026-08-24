# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publica archivos en GitHub sin git — eficiente en tokens, seguro para la privacidad, multiagente y multilingüe.**

`gh-publisher` es una habilidad de agente que publica un directorio local en un repositorio de GitHub usando la `gh` CLI + la REST API de GitHub (Contents / Git Database) — sin necesidad de git. Gestiona la inicialización de repositorios vacíos y los commits por lotes con un único script reutilizable, de modo que los agentes publican con un solo comando en lugar de re-derivar todo el flujo de la API. También publica **10 de los idiomas más usados de GitHub** (traducciones del README) mientras la copia de trabajo local se mantiene en tu idioma preferido.

## Por qué destaca

- **🚀 Publicación sin git** — funciona en equipos sin git; inicializa repositorios vacíos automáticamente.
- **⚡ Eficiente en tokens** — un solo comando `scripts/push.ps1` hace escaneo → init → commit por lotes → salida enmascarada (una única línea `PUSHED N files -> URL`), en lugar de docenas de llamadas a la API hechas a mano.
- **🔒 Privacidad y seguridad de la cuenta** — los tokens viven solo en el keyring de `gh` (nunca en el chat, registros ni archivos); los archivos se escanean en busca de secretos antes de publicar (`github_pat_`, `ghp_`, `sk-`, claves privadas…); la salida está enmascarada.
- **🔌 Adaptable a múltiples agentes** — el script `pwsh` funciona en Windows/macOS/Linux; los mapeos para DSH / Codex / Claude Code están documentados; sin nombres de herramientas de plataforma codificados.
- **🧩 Inicialización automática de repos vacíos** — detecta repositorios vacíos y siembra el primer archivo mediante la Contents API antes del commit por lotes.
- **🌍 Publicación multilingüe** — la copia de trabajo local se mantiene en el idioma que elijas (chino por defecto); las versiones publicadas incluyen traducciones del README para los 10 idiomas más usados de GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Consulta `references/i18n.md`.

## Cómo funciona

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Localiza automáticamente el binario `gh` (`-GhPath` → PATH → rutas de instalación comunes) y detecta automáticamente `GH_CONFIG_DIR` — sin ajustes manuales de PATH/configuración.
3. Escaneo de secretos → aborta ante cualquier patrón de clave/token (salvo con `-ForceSecret`).
4. Detecta el repositorio vacío comprobando la referencia de la rama (404 = vacío) → siembra el primer archivo (Contents API) si es necesario.
5. Commit por lotes de todos los archivos (Git Database API: blobs → tree → commit → ref).
6. Imprime `PUSHED N files -> https://github.com/owner/repo` — nada más. Si falta el repositorio → imprime una sugerencia de `gh repo create`.
7. Verificación opcional de `-Languages`: comprueba que exista cada archivo de idioma (p. ej., `README.hi.md`) antes de publicar y advierte si falta alguno.

## Publicación multilingüe (idioma local + 10 idiomas de publicación)

- **Copia de trabajo local**: se mantiene en tu idioma configurado (zh o en) — `config.local.json` en el directorio de la habilidad instalada (`zh` por defecto). Di *"cambiar el idioma local por defecto a inglés"* para cambiarlo; el SKILL.md local se actualiza en consecuencia.
- **Publicación**: el `SKILL.md` se mantiene en inglés (el idioma principal universal de GitHub), mientras que `README.<lang>.md` se publica para los 10 idiomas más usados. Consulta `references/i18n.md` para la lista de idiomas, las reglas de traducción y las notas del contrato de activación (todas las versiones de idioma conservan el mismo `name`).

## Autocomprobación del entorno (una vez antes de la primera publicación)

- `Get-Command gh` (o deja que el script detecte automáticamente las rutas de instalación); si falta: `winget install GitHub.cli`.
- `gh auth status` muestra una cuenta con sesión iniciada (token enmascarado como `github_pat_***…`).
- `gh api repos/{owner}/{repo}` o `gh repo list` devuelve datos.

## Instalación

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

Actívala con frases como *"sube esto a GitHub"*, *"publica esta habilidad en un repositorio"* — o mediante el elemento ⑤ del menú `/skill` de **set-skill**.

## Documentación

- `references/security.md` — privacidad y seguridad de la cuenta
- `references/platform-adapter.md` — mapeo de DSH / Codex / Claude Code
- `references/i18n.md` — protocolo de publicación multilingüe (10 idiomas)

## Habilidades complementarias

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lista esta habilidad como elemento ⑤ del menú `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publica con esta los flujos de trabajo multiagente que genera.

## Requisitos

- `gh` CLI (con sesión iniciada mediante `gh auth login`) + `pwsh` (PowerShell Core, multiplataforma).

## Descargo de responsabilidad

> **Esta habilidad está 100% creada por IA.** Los problemas son inevitables — los debates y los pull requests son bienvenidos. El autor itera activamente sobre ella basándose en el uso real.

## Licencia

[MIT](./LICENSE)
