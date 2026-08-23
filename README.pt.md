# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publique arquivos no GitHub sem git — eficiente em tokens, seguro para a privacidade e multiagente.**

`gh-publisher` é uma skill de agente que publica um diretório local em um repositório do GitHub usando a CLI `gh` + a REST API do GitHub (Contents / Git Database) — sem precisar de git. Ela cuida da inicialização de repositórios vazios e de commits em lote com um único script reutilizável, para que os agentes façam o push em um comando só, em vez de rederivar todo o fluxo da API.

## Por que ele se destaca

- **🚀 Push sem git** — funciona em máquinas sem git; inicializa repositórios vazios automaticamente.
- **⚡ Eficiente em tokens** — um único comando `scripts/push.ps1` faz varredura → init → commit em lote → saída mascarada (uma única linha `PUSHED N files -> URL`), em vez de dezenas de chamadas de API escritas à mão.
- **🔒 Privacidade e segurança da conta** — os tokens ficam apenas no keyring do `gh` (nunca no chat, em logs ou arquivos); os arquivos passam por varredura de segredos antes do push (`github_pat_`, `ghp_`, `sk-`, chaves privadas…); a saída é mascarada.
- **🔌 Adaptável a múltiplos agentes** — o script `pwsh` roda no Windows/macOS/Linux; mapeamentos para DSH / Codex / Claude Code documentados; sem nomes de ferramentas de plataforma fixados no código.
- **🧩 Inicialização automática de repo vazio** — detecta repositórios vazios e cria o primeiro arquivo via Contents API antes do commit em lote.

## Como funciona

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Varredura de segredos → aborta ao encontrar qualquer padrão de chave/token (a menos que `-ForceSecret`).
3. Detecta repo vazio → cria o primeiro arquivo (Contents API) se necessário.
4. Commit em lote de todos os arquivos (Git Database API: blobs → tree → commit → ref).
5. Imprime `PUSHED N files -> https://github.com/owner/repo` — e nada mais.

## Instalação

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # por projeto
```

Ative-a com frases como *"push this to GitHub"*, *"publish this skill to a repo"* — ou pelo item ⑤ do menu `/skill` do **set-skill**.

## Documentação

- `references/security.md` — privacidade e segurança da conta
- `references/platform-adapter.md` — mapeamento para DSH / Codex / Claude Code

## Skills complementares

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lista esta skill como o item ⑤ do menu `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publique com esta skill os fluxos de trabalho multiagente que ele gera.

## Requisitos

- CLI `gh` (autenticada via `gh auth login`) + `pwsh` (PowerShell Core, multiplataforma).

## Aviso legal

> **Esta skill é 100% criada por IA.** Problemas são inevitáveis — discussões e pull requests são bem-vindos. O autor a itera ativamente com base no uso real.

## Licença

[MIT](./LICENSE)
