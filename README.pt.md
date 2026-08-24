# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Publique arquivos no GitHub sem git — eficiente em tokens, seguro para a privacidade, multiagente, multilíngue.**

`gh-publisher` é uma skill de agente que publica um diretório local em um repositório do GitHub usando a CLI `gh` + a API REST do GitHub (Contents / Git Database) — sem necessidade de git. Ela lida com a inicialização de repositórios vazios e commits em lote com um único script reutilizável, de modo que os agentes fazem push em um único comando em vez de redescobrir todo o fluxo da API. Ela também publica **10 dos idiomas mais usados do GitHub** (traduções do README) enquanto a cópia de trabalho local permanece no seu idioma preferido.

## Por que ela se destaca

- **🚀 Push sem git** — funciona em máquinas sem git; inicializa repositórios vazios automaticamente.
- **⚡ Eficiente em tokens** — um único comando `scripts/push.ps1` faz guarda → verificação → inicialização → commit em lote → saída mascarada (uma única linha `PUSHED N files -> URL`), em vez de dezenas de chamadas de API feitas manualmente.
- **🌍 Traduções eficientes em tokens** — os READMEs multilíngues são atualizados via **tradução por edição incremental** (subagentes editam apenas os parágrafos alterados sobre a tradução antiga, sem retradução completa): ~70-90% menos tokens de saída, mais rápido, e a terminologia/estilo permanecem estáveis.
- **🔒 Privacidade e segurança da conta** — os tokens vivem apenas no chaveiro do `gh` (nunca no chat/logs/arquivos); os arquivos passam por verificação de segredos antes do push (`github_pat_`, `ghp_`, `sk-`, chaves privadas…); a saída é mascarada.
- **🛡️ Proteção de dados pessoais** — o perfil local da máquina (`local-profile.json` / `config.local.json`) **nunca** pode ser publicado: o push é abortado no momento em que um arquivo desse tipo aparece na origem, antes que qualquer outra coisa seja executada.
- **🗂️ Perfil local da máquina** — em uma máquina com rede complicada (ex.: sequestro via hosts), um único `local-profile.json` consolida a conta, a entrada do gh (um shim de modo proxy) e o mapeamento de repositórios conhecidos, de modo que os pushes precisam apenas de `-Profile` — chega de procurar conta / gh / repositório.
- **🔌 Adaptável a múltiplos agentes** — o script `pwsh` roda em Windows/macOS/Linux; mapeamentos DSH / Codex / Claude Code documentados; sem nomes de ferramentas de plataforma embutidos no código.
- **🧩 Inicialização automática de repositório vazio** — detecta repositórios vazios e semeia o primeiro arquivo via API de Contents antes do commit em lote.
- **🌍 Publicação multilíngue** — a cópia de trabalho local permanece no idioma escolhido (padrão: chinês); os lançamentos incluem traduções do README para os 10 idiomas mais usados do GitHub (en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja). Consulte `references/i18n.md`.

## Como funciona

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. Localiza automaticamente o binário do `gh` (`-GhPath` → PATH → caminhos de instalação comuns) e detecta automaticamente o `GH_CONFIG_DIR` — sem mexer manualmente em PATH/config. Com `-Profile`, a entrada do gh, o diretório de configuração, o repositório (correspondido pelo diretório de origem) e os idiomas (detectados automaticamente a partir de `README.<lang>.md`) são resolvidos automaticamente.
3. **Proteção de dados pessoais** — `local-profile.json` / `config.local.json` na origem → abortar (eles nunca devem ser publicados).
4. Verificação de segredos → abortar em qualquer padrão de chave/token (a menos que `-ForceSecret`).
5. Detecta repositório vazio verificando a referência do branch (404 = vazio) → semeia o primeiro arquivo (API de Contents) se necessário.
6. Commit em lote de todos os arquivos (API Git Database: blobs → tree → commit → ref).
7. Imprime `PUSHED N files -> https://github.com/owner/repo` — nada mais. Repositório ausente → imprime uma dica de `gh repo create`.
8. Verificação opcional de `-Languages`: verifica se cada arquivo de idioma existe (ex.: `README.hi.md`) antes do push e avisa se algum estiver ausente.

## Publicação multilíngue (idioma local + 10 idiomas de lançamento)

- **Cópia de trabalho local**: permanece no idioma configurado (zh ou en) — `config.local.json` no diretório da skill instalada (padrão `zh`). Diga *"altere o idioma local padrão para inglês"* para alternar; o SKILL.md local é atualizado para corresponder.
- **Lançamento**: o `SKILL.md` permanece em inglês (o idioma universal primário do GitHub), enquanto `README.<lang>.md` é publicado para os 10 idiomas mais usados. Consulte `references/i18n.md` para a lista de idiomas, as regras de tradução e as notas sobre o contrato de gatilho (todas as versões de idioma mantêm o mesmo `name`).
- **Esquema fixo eficiente em tokens**: idiomas com tradução existente são atualizados via tradução por edição incremental (edite apenas os parágrafos alterados — sem retradução completa); idiomas sem tradução recebem uma tradução completa que estabelece a linha de base da terminologia. Consulte `references/i18n.md` §1.5.

## Resultados medidos: v1.4.0 → v1.5.0 (tradução por edição incremental)

A atualização do README em 11 idiomas para este lançamento foi a primeira execução do esquema de edição incremental. Nós a medimos em comparação com a retradução completa anterior, usando os arquivos reais da v1.4.0 (obtidos do repositório no commit `40dcf1f`) vs. os arquivos da v1.5.0 publicados (diff em nível de linha):

| Métrica | Retradução completa (era v1.4) | Edição incremental (v1.5) | Economia |
|---|---|---|---|
| Conteúdo de saída, 11 idiomas | 68,292 caracteres | 7,717 caracteres | **88.7%** |
| Aprox. tokens de saída (~3 caracteres/token) | ~22,800 | ~2,600 | **~88.7%** |
| Terminologia / estilo | pode variar a cada lançamento | traduções antigas byte-idênticas exceto pelos parágrafos alterados | estável |
| Esforço por idioma | regenerar o arquivo inteiro | ~4 edições direcionadas | mais rápido |

Proporção de mudança por idioma (caracteres alterados / arquivo completo antigo): zh-CN 9.1% · hi 10.8% · es 11.9% · fr 12.5% · ar 12.2% · bn 11.3% · pt 11.6% · ru 12.0% · ja 8.9% · de 12.3% · ko 9.4% — **apenas ~9-12% de cada arquivo realmente mudou**, então a retradução completa gastou ~8-11× mais saída do que o necessário.

*Método: arquivos da v1.4.0 obtidos do repositório no commit `40dcf1f`; diff em nível de linha por idioma (linhas adicionadas/modificadas) vs. os arquivos da v1.5.0 publicados; tokens aproximados em ~3 caracteres/token para READMEs em idiomas mistos. Os custos do lado da entrada também diferem (a edição incremental lê a tradução antiga), mas a saída é a parte dominante e mais cara da tradução por LLM.*

## Perfil local da máquina (local-profile)

Em máquinas com rede não padronizada (ex.: um arquivo hosts sequestrando domínios do GitHub para 127.0.0.1, além de um `gh` portátil que precisa rodar por meio de um shim de proxy local), `E:\ds harness\gh\local-profile.json` consolida o proprietário, a entrada do gh, o diretório de configuração e o mapeamento de repositórios conhecidos. O arquivo é marcado com `"never_publish": true` — ele existe apenas na máquina e nunca é enviado. Qualquer ação que o leia/modifique recebe antes uma confirmação explicitamente enfatizada.

## Autoverificação do ambiente (uma vez antes do primeiro push)

- `Get-Command gh` (ou deixe o script detectar automaticamente os caminhos de instalação); se ausente: `winget install GitHub.cli`.
- `gh auth status` mostra uma conta conectada (token mascarado como `github_pat_***…`).
- `gh api repos/{owner}/{repo}` ou `gh repo list` retorna dados.

## Instalação

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # por projeto
```

Acione-a com frases como *"publique isto no GitHub"*, *"publique esta skill em um repositório"* — ou pelo item ⑤ do menu `/skill` do **set-skill**.

## Documentação

- `references/security.md` — privacidade e segurança da conta
- `references/platform-adapter.md` — mapeamento DSH / Codex / Claude Code
- `references/i18n.md` — protocolo de publicação multilíngue (10 idiomas, tradução por edição incremental)

## Skills complementares

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — lista esta skill como item ⑤ do menu `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — publique com esta os fluxos de trabalho multiagente que ela gera.

## Requisitos

- CLI `gh` (conectada via `gh auth login`) + `pwsh` (PowerShell Core, multiplataforma).

## Disclaimer

> **Esta skill é 100% criada por IA.** Problemas são inevitáveis — discussões e pull requests são bem-vindos. O autor a itera ativamente com base no uso no mundo real.

## Licença

[MIT](./LICENSE)
