# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**git 없이 GitHub에 파일을 게시 — 토큰 효율적, 프라이버시 안전, 멀티 에이전트.**

`gh-publisher`는 `gh` CLI + GitHub REST API(Contents / Git Database)를 사용해 로컬 디렉터리를 GitHub 저장소에 게시하는 에이전트 스킬입니다 — git이 필요 없습니다. 빈 저장소 초기화와 일괄 커밋을 재사용 가능한 스크립트 하나로 처리하므로, 에이전트는 전체 API 흐름을 다시 만들어내는 대신 한 번의 명령으로 푸시할 수 있습니다.

## 강점

- **🚀 Git 없는 푸시** — git이 없는 머신에서도 동작하며, 빈 저장소를 자동으로 초기화합니다.
- **⚡ 토큰 효율적** — `scripts/push.ps1` 명령 하나로 스캔 → 초기화 → 일괄 커밋 → 마스킹된 출력(`PUSHED N files -> URL` 한 줄)까지 처리하므로, 수십 개의 수작업 API 호출이 필요 없습니다.
- **🔒 프라이버시 & 계정 보안** — 토큰은 `gh` keyring에만 저장되며(채팅/로그/파일에는 절대 남지 않음), 푸시 전에 파일을 secret scan(`github_pat_`, `ghp_`, `sk-`, 개인 키 등)하고, 출력은 마스킹됩니다.
- **🔌 멀티 에이전트 적응형** — `pwsh` 스크립트는 Windows/macOS/Linux에서 실행되며, DSH / Codex / Claude Code 매핑이 문서화되어 있고, 플랫폼 도구 이름이 하드코딩되어 있지 않습니다.
- **🧩 빈 저장소 자동 초기화** — 빈 저장소를 감지하고, 일괄 커밋 전에 Contents API를 통해 첫 번째 파일을 심습니다.

## 동작 방식

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. 비밀 스캔 → 키/토큰 패턴이 발견되면 중단(`-ForceSecret` 지정 시 제외).
3. 빈 저장소 감지 → 필요 시 첫 번째 파일 심기(Contents API).
4. 모든 파일 일괄 커밋(Git Database API: blobs → tree → commit → ref).
5. `PUSHED N files -> https://github.com/owner/repo` 출력 — 그 외에는 아무것도 출력하지 않습니다.

## 설치

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

*"push this to GitHub"*, *"publish this skill to a repo"* 같은 문구로 트리거하거나, **set-skill**의 `/skill` 메뉴 항목 ⑤를 통해 트리거할 수 있습니다.

## 문서

- `references/security.md` — 프라이버시 & 계정 보안
- `references/platform-adapter.md` — DSH / Codex / Claude Code 매핑

## 연계 스킬

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — 이 스킬을 `/skill` 메뉴 항목 ⑤로 등록합니다.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — 생성하는 멀티 에이전트 워크플로를 이 스킬로 게시합니다.

## 요구 사항

- `gh` CLI(`gh auth login`으로 로그인) + `pwsh`(PowerShell Core, 크로스 플랫폼).

## 면책 조항

> **이 스킬은 100% AI가 제작했습니다.** 문제는 불가피하며 — 논의와 풀 리퀘스트를 환영합니다. 저자는 실제 사용 사례를 바탕으로 지속적으로 개선하고 있습니다.

## 라이선스

[MIT](./LICENSE)
