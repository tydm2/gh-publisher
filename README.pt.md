# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publique arquivos no GitHub sem git — eficiente em tokens, seguro para privacidade, multiagente e multilíngue.**

`gh-publisher` é uma skill de agente que publica um diretório local em um repositório do GitHub usando a CLI `gh` + GitHub REST API (Contents / Git Database) — sem precisar de git. Ela cuida da inicialização de repositórios vazios e de commits em lote com um único script reutilizável, para que os agentes publiquem em um único comando em vez de reconstruir todo o fluxo da API. Ela também publica **10 dos idiomas mais usados do GitHub** (traduções do README), enquanto a cópia de trabalho local permanece no seu idioma preferido.

## Por que ele se destaca

- **🚀 Push sem git** — funciona em máquinas sem git; inicializa repositórios vazios automaticamente.
- **⚡ Eficiente em tokens** — um único comando `scripts/push.ps1` faz varredura → init → commit em lote → saída mascarada (uma única linha `PUSHED N files -> URL`), em vez de dezenas de chamadas de API feitas à mão.
- **🔒 Privacidade e segurança da conta** — os tokens ficam somente no keyring do `gh` (nunca em chat/logs/arquivos); os arquivos passam por varredura de segredos antes do push (`github_pat_`, `ghp_`, `sk-`, chaves privadas…); a saída é mascarada.
- **🔌 Adaptável a múltiplos agentes** — o script `pwsh` roda em Windows/macOS/Linux; os mapeamentos de DSH / Codex / Claude Code estão documentados; sem nomes de ferramentas de plataforma fixos no código.
- **🧩 Init automático de repositório vazio** — detecta repositórios vazios e insere o primeiro arquivo via Contents API antes do commit em lote.
- **🌍 Publicação multilíngue** — a cópia de trabalho local permanece no idioma escolhido (padrão: chinês); os lançamentos incluem traduções do README para os 10 idiomas mais usados do GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Veja `references/i18n.md`.

## Como funciona

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Localiza automaticamente o binário do `gh` (`-GhPath` → PATH → caminhos de instalação comuns) e detecta automaticamente `GH_CONFIG_DIR` — sem ajustes manuais de PATH/config.
3. Varredura de segredos → aborta em qualquer padrão de chave/token (a menos que `-ForceSecret`).
4. Detecta repositório vazio verificando a ref do branch (404 = vazio) → insere o primeiro arquivo (Contents API) se necessário.
5. Commit em lote de todos os arquivos (Git Database API: blobs → tree → commit → ref).
6. Imprime `PUSHED N files -> https://github.com/owner/repo` — nada além disso. Repositório ausente → imprime uma dica de `gh repo create`.
7. Verificação opcional de `-Languages`: verifica se cada arquivo de idioma existe (ex.: `README.hi.md`) antes do push e avisa se algum estiver ausente.

## Publicação multilíngue (idioma local + 10 idiomas de lançamento)

- **Cópia de trabalho local**: permanece no idioma configurado (zh ou en) — `config.local.json` no diretório da skill instalada (padrão `zh`). Diga *"change local default language to English"* para alternar; o SKILL.md local é atualizado para corresponder.
- **Lançamento**: o `SKILL.md` permanece em inglês (o idioma primário universal do GitHub), enquanto `README.<lang>.md` é publicado para os 10 idiomas mais usados. Veja `references/i18n.md` para a lista de idiomas, regras de tradução e notas de trigger-contract (todas as versões de idioma mantêm o mesmo `name`).

## Autoverificação do ambiente (uma vez antes do primeiro push)

- `Get-Command gh` (ou deixe o script detectar automaticamente os caminhos de instalação); se estiver ausente: `winget install GitHub.cli`.
- `gh auth status` mostra uma conta conectada (token mascarado como `github_pat_***…`).
- `gh api repos/{owner}/{repo}` ou `gh repo list` retorna dados.

## Instalação

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

Acione com frases como *"push this to GitHub"*, *"publish this skill to a repo"* — ou pelo item de menu ⑤ `/skill` do **set-skill**.

## Documentação

- `references/security.md` — privacidade e segurança da conta
- `references/platform-adapter.md` — mapeamento DSH / Codex / Claude Code
- `references/i18n.md` — protocolo de publicação multilíngue (10 idiomas)

## Skills complementares

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lista esta skill como item de menu ⑤ `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publique com esta skill os workflows multiagente que ele gera.

## Requisitos

- CLI `gh` (conectada via `gh auth login`) + `pwsh` (PowerShell Core, multiplataforma).

## Aviso legal

> **Esta skill é 100% criada por IA.** Problemas são inevitáveis — discussões e pull requests são bem-vindos. O autor itera ativamente sobre ela com base no uso real.

## Licença

[MIT](./LICENSE)
