# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**Публикуйте файлы на GitHub без git — экономно по токенам, безопасно для приватности, для нескольких агентов.**

`gh-publisher` — это навык агента, который публикует локальную директорию в репозиторий GitHub с помощью CLI `gh` + GitHub REST API (Contents / Git Database) — git не требуется. Он берёт на себя инициализацию empty repo и пакетный commit одним переиспользуемым скриптом, поэтому агенты пушат одной командой вместо того, чтобы каждый раз заново выводить весь поток API.

## Почему он выделяется

- **🚀 Push без git** — работает на машинах без git; автоматически инициализирует пустые репозитории.
- **⚡ Экономия токенов** — одна команда `scripts/push.ps1` выполняет scan → init → пакетный commit → маскированный вывод (одна строка `PUSHED N files -> URL`) вместо десятков вручную собранных API-вызовов.
- **🔒 Приватность и безопасность аккаунта** — токены живут только в keyring `gh` (никогда в чате/логах/файлах); перед push файлы проходят secret scan (`github_pat_`, `ghp_`, `sk-`, приватные ключи…); вывод маскируется.
- **🔌 Адаптируемость для нескольких агентов** — скрипт `pwsh` работает на Windows/macOS/Linux; задокументированы сопоставления для DSH / Codex / Claude Code; нет захардкоженных имён инструментов конкретных платформ.
- **🧩 Авто-инициализация empty repo** — определяет пустые репозитории и создаёт первый файл через Contents API перед пакетным commit.

## Как это работает

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → прерывание при любом паттерне ключа/токена (кроме `-ForceSecret`).
3. Определение empty repo → при необходимости создаёт первый файл (Contents API).
4. Пакетный commit всех файлов (Git Database API: blobs → tree → commit → ref).
5. Вывод `PUSHED N files -> https://github.com/owner/repo` — и ничего больше.

## Установка

```
~/.dsh/skills/gh-publisher/    # глобально
.dsh/skills/gh-publisher/      # для проекта
```

Запускайте его фразами вроде *«push this to GitHub»*, *«publish this skill to a repo»* — или через пункт ⑤ меню `/skill` навыка **set-skill**.

## Документация

- `references/security.md` — приватность и безопасность аккаунта
- `references/platform-adapter.md` — сопоставление DSH / Codex / Claude Code

## Сопутствующие навыки

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — указывает этот навык как пункт ⑤ меню `/skill`.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — публикуйте созданные им мультиагентные рабочие процессы с помощью этого навыка.

## Требования

- CLI `gh` (вход через `gh auth login`) + `pwsh` (PowerShell Core, кроссплатформенный).

## Дисклеймер

> **Этот навык на 100 % создан ИИ.** Проблемы неизбежны — обсуждения и pull request приветствуются. Автор активно итерирует его, опираясь на реальное использование.

## Лицензия

[MIT](./LICENSE)
