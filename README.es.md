# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.4.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publica archivos en GitHub sin git — eficiente en tokens, seguro para la privacidad, multi-agente, multilingüe.**

`gh-publisher` es una skill de agente que publica un directorio local en un repositorio de GitHub mediante la CLI de `gh` + la API REST de GitHub (Contents / Git Database) — sin necesidad de git. Maneja la inicialización de repositorios vacíos y los commits por lotes con un único script reutilizable, de modo que los agentes hacen push con un solo comando en lugar de volver a derivar todo el flujo de la API. También publica **10 de los idiomas más usados de GitHub** (traducciones del README) mientras la copia de trabajo local permanece en tu idioma preferido.

## Por qué destaca

- **🚀 Push sin git** — funciona en máquinas sin git; inicializa repositorios vacíos automáticamente.
- **⚡ Eficiente en tokens** — un solo comando `scripts/push.ps1` hace guard → scan → init → commit por lotes → salida enmascarada (una sola línea `PUSHED N files -> URL`), en lugar de decenas de llamadas a la API hechas a mano.
- **🔒 Privacidad y seguridad de la cuenta** — los tokens viven solo en el llavero de `gh` (nunca en chat/logs/archivos); los archivos se escanean en busca de secretos antes del push (`github_pat_`, `ghp_`, `sk-`, claves privadas…); la salida está enmascarada.
- **🛡️ Protección de datos personales** — el perfil local de la máquina (`local-profile.json` / `config.local.json`) **nunca** puede publicarse: el push se aborta en el momento en que aparece un archivo así en el origen, antes de que se ejecute cualquier otra cosa.
- **🗂️ Perfil local de la máquina** — en una máquina con red complicada (p. ej. secuestro de hosts), un solo `local-profile.json` consolida la cuenta, la entrada de gh (un shim en modo proxy) y la asignación de repositorios conocidos, de modo que los pushes solo necesitan `-Profile` — no más búsqueda de cuenta / gh / repo.
- **🔌 Adaptable a múltiples agentes** — el script `pwsh` se ejecuta en Windows/macOS/Linux; asignaciones para DSH / Codex / Claude Code documentadas; sin nombres de herramientas de plataforma codificados.
- **🧩 Inicialización automática de repos vacíos** — detecta repositorios vacíos y siembra el primer archivo mediante la API Contents antes del commit por lotes.
- **🌍 Publicación multilingüe** — la copia de trabajo local permanece en tu idioma elegido (chino por defecto); los lanzamientos incluyen traducciones del README para los 10 idiomas más usados de GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Consulta `references/i18n.md`.

## Cómo funciona

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Localiza automáticamente el binario `gh` (`-GhPath` → PATH → rutas de instalación comunes) y detecta automáticamente `GH_CONFIG_DIR` — sin manipular PATH/config manualmente. Con `-Profile`, la entrada de gh, el directorio de configuración, el repositorio (coincidido por el directorio de origen) y los idiomas (detectados automáticamente desde `README.<lang>.md`) se resuelven automáticamente.
3. **Protección de datos personales** — `local-profile.json` / `config.local.json` en el origen → abortar (nunca deben publicarse).
4. Escaneo de secretos → abortar ante cualquier patrón de clave/token (salvo `-ForceSecret`).
5. Detecta el repositorio vacío comprobando la referencia de la rama (404 = vacío) → siembra el primer archivo (API Contents) si es necesario.
6. Commit por lotes de todos los archivos (API Git Database: blobs → tree → commit → ref).
7. Imprime `PUSHED N files -> https://github.com/owner/repo` — nada más. Repositorio faltante → imprime una pista de `gh repo create`.
8. Comprobación opcional `-Languages`: verifica que exista cada archivo de idioma (p. ej. `README.hi.md`) antes de hacer push y avisa si falta alguno.

## Publicación multilingüe (idioma local + 10 idiomas de lanzamiento)

- **Copia de trabajo local**: permanece en tu idioma configurado (zh o en) — `config.local.json` en el directorio de la skill instalada (por defecto `zh`). Di *"cambia el idioma local predeterminado a inglés"* para cambiarlo; el SKILL.md local se actualiza para que coincida.
- **Lanzamiento**: `SKILL.md` permanece en inglés (el idioma principal universal de GitHub), mientras que `README.<lang>.md` se publica para los 10 idiomas más usados. Consulta `references/i18n.md` para la lista de idiomas, las reglas de traducción y las notas sobre el contrato de activación (todas las versiones de idioma mantienen el mismo `name`).

## Perfil local de la máquina (local-profile)

En máquinas con redes no estándar (p. ej. un archivo hosts que secuestra los dominios de GitHub hacia 127.0.0.1, más un `gh` portátil que debe ejecutarse a través de un shim de proxy local), `E:\ds harness\gh\local-profile.json` consolida el propietario, la entrada de gh, el directorio de configuración y la asignación de repositorios conocidos. El archivo está marcado con `"never_publish": true` — solo vive en la máquina y nunca se hace push. Cualquier acción que lo lea/modifique recibe primero una confirmación explícitamente enfatizada.

## Autocomprobación del entorno (una vez antes del primer push)

- `Get-Command gh` (o deja que el script detecte automáticamente las rutas de instalación); si falta: `winget install GitHub.cli`.
- `gh auth status` muestra una cuenta iniciada (token enmascarado como `github_pat_***…`).
- `gh api repos/{owner}/{repo}` o `gh repo list` devuelven datos.

## Instalación

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # por proyecto
```

Actívala con frases como *"sube esto a GitHub"*, *"publica esta skill en un repositorio"* — o mediante el elemento ⑤ del menú `/skill` de **set-skill**.

## Documentación

- `references/security.md` — privacidad y seguridad de la cuenta
- `references/platform-adapter.md` — asignación para DSH / Codex / Claude Code
- `references/i18n.md` — protocolo de publicación multilingüe (10 idiomas)

## Skills complementarias

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — enumera esta skill como elemento ⑤ del menú `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publica con esta los flujos de trabajo multi-agente que genera.

## Requisitos

- CLI de `gh` (iniciada sesión mediante `gh auth login`) + `pwsh` (PowerShell Core, multiplataforma).

## Disclaimer

> **Esta skill está 100% creada por IA.** Los problemas son inevitables — los debates y las pull requests son bienvenidos. El autor la itera activamente basándose en el uso real.

## Licencia

[MIT](./LICENSE)
