# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**git 없이 파일을 GitHub에 게시 — 토큰 효율적, 개인정보 안전, 다중 에이전트, 다국어 지원.**

`gh-publisher`는 `gh` CLI + GitHub REST API(Contents / Git Database)를 사용하여 로컬 디렉터리를 GitHub 저장소에 게시하는 에이전트 스킬입니다 — git이 필요 없습니다. 재사용 가능한 스크립트 하나로 빈 저장소 초기화와 배치 커밋을 처리하므로, 에이전트는 전체 API 흐름을 다시 파악할 필요 없이 한 번의 명령으로 푸시할 수 있습니다. 또한 로컬 작업 복사본은 선호하는 언어로 유지하면서 **GitHub에서 가장 많이 사용되는 10개 언어**(README 번역)도 게시합니다.

## 차별점

- **🚀 git 없이 푸시** — git이 없는 머신에서도 작동하며, 빈 저장소를 자동으로 초기화합니다.
- **⚡ 토큰 효율적** — 하나의 `scripts/push.ps1` 명령이 가드 → 스캔 → 초기화 → 배치 커밋 → 마스킹 출력(단일 `PUSHED N files -> URL` 줄)을 처리하므로, 수십 번의 수작업 API 호출이 필요 없습니다.
- **🌍 토큰 효율적 번역** — 다국어 README는 **증분 편집 번역**으로 업데이트됩니다(서브에이전트가 기존 번역 위에서 변경된 단락만 편집하며, 전체 재번역이 필요 없음): 출력 토큰이 약 70-90% 절감되고, 더 빠르며, 용어/스타일이 안정적으로 유지됩니다.
- **🔒 개인정보 및 계정 보안** — 토큰은 `gh` 키링에만 존재합니다(대화/로그/파일에 절대 저장되지 않음). 파일은 푸시 전에 비밀 스캔됩니다(`github_pat_`, `ghp_`, `sk-`, 개인 키…). 출력은 마스킹됩니다.
- **🛡️ 개인 데이터 가드** — 머신 로컬 프로필(`local-profile.json` / `config.local.json`)은 **절대** 게시될 수 없습니다. 소스에 이러한 파일이 나타나는 순간, 다른 어떤 작업이 실행되기 전에 푸시가 중단됩니다.
- **🗂️ 머신 로컬 프로필** — 네트워킹이 까다로운 머신(예: 호스트 하이재킹)에서 하나의 `local-profile.json`이 계정, gh 항목(프록시 모드 셤), 알려진 저장소 매핑을 통합하므로 푸시에는 `-Profile`만 있으면 됩니다 — 더 이상 계정/gh/저장소를 찾아 헤맬 필요가 없습니다.
- **🔌 다중 에이전트 호환** — `pwsh` 스크립트는 Windows/macOS/Linux에서 실행됩니다. DSH / Codex / Claude Code 매핑이 문서화되어 있으며 하드코딩된 플랫폼 도구 이름이 없습니다.
- **🧩 빈 저장소 자동 초기화** — 빈 저장소를 감지하여 배치 커밋 전에 Contents API를 통해 첫 번째 파일을 시드합니다.
- **🌍 다국어 게시** — 로컬 작업 복사본은 선택한 언어(기본값: 중국어)로 유지됩니다. 릴리스에는 GitHub에서 가장 많이 사용되는 10개 언어(en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja)용 README 번역이 포함됩니다. `references/i18n.md`를 참조하세요.

## 작동 방식

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. `gh` 바이너리를 자동으로 찾고(`-GhPath` → PATH → 일반적인 설치 경로) `GH_CONFIG_DIR`을 자동 감지합니다 — PATH/config를 수동으로 만질 필요가 없습니다. `-Profile`을 사용하면 gh 항목, 구성 디렉터리, 저장소(소스 디렉터리로 매칭) 및 언어(`README.<lang>.md`에서 자동 감지)가 자동으로 해석됩니다.
3. **개인 데이터 가드** — 소스에 `local-profile.json` / `config.local.json`이 있으면 → 중단합니다(절대 게시되면 안 됩니다).
4. 비밀 스캔 → 키/토큰 패턴이 있으면 중단합니다(`-ForceSecret`가 아닌 경우).
5. 브랜치 ref를 확인하여 빈 저장소를 감지합니다(404 = 비어 있음) → 필요 시 첫 번째 파일을 시드합니다(Contents API).
6. 모든 파일을 배치 커밋합니다(Git Database API: blobs → tree → commit → ref).
7. `PUSHED N files -> https://github.com/owner/repo`만 출력합니다 — 그 외에는 아무것도 출력하지 않습니다. 저장소가 없으면 → `gh repo create` 힌트를 출력합니다.
8. 선택적 `-Languages` 검사: 푸시 전에 각 언어 파일(예: `README.hi.md`)이 존재하는지 확인하고, 누락된 파일이 있으면 경고합니다.

## 다국어 게시(로컬 언어 + 10개 릴리스 언어)

- **로컬 작업 복사본**: 구성된 언어(zh 또는 en)로 유지됩니다 — 설치된 스킬 디렉터리의 `config.local.json`(기본값 `zh`). *"change local default language to English"*라고 말하면 전환되며, 로컬 SKILL.md도 그에 맞게 업데이트됩니다.
- **릴리스**: `SKILL.md`는 영어(보편적인 GitHub 기본 언어)로 유지되고, `README.<lang>.md`는 가장 많이 사용되는 10개 언어로 게시됩니다. 언어 목록, 번역 규칙, 트리거 계약 참고 사항은 `references/i18n.md`를 참조하세요(모든 언어 버전은 동일한 `name`을 유지합니다).
- **토큰 효율적 고정 방식**: 기존 번역이 있는 언어는 증분 편집 번역으로 업데이트됩니다(변경된 단락만 편집 — 전체 재번역 없음). 처음 번역하는 언어는 용어 기준을 확립하는 전체 번역을 한 번 수행합니다. `references/i18n.md` §1.5를 참조하세요.

## 측정 결과: v1.4.0 → v1.5.0(증분 편집 번역)

이번 릴리스의 11개 언어 README 업데이트는 증분 편집 방식의 첫 실행이었습니다. 이전의 전체 재번역과 비교하여 측정했으며, 실제 v1.4.0 파일(저장소에서 커밋 `40dcf1f`로 가져옴)과 배포된 v1.5.0 파일(줄 단위 diff)을 사용했습니다:

| 지표 | 전체 재번역(v1.4 시대) | 증분 편집(v1.5) | 절감 |
|---|---|---|---|
| 출력 콘텐츠, 11개 언어 | 68,292자 | 7,717자 | **88.7%** |
| 대략적 출력 토큰(~3자/토큰) | ~22,800 | ~2,600 | **~88.7%** |
| 용어 / 스타일 | 릴리스마다 달라질 수 있음 | 변경된 단락 외에는 기존 번역이 바이트 단위로 동일 | 안정적 |
| 언어당 노력 | 전체 파일 재생성 | 약 4회의 목표 편집 | 더 빠름 |

언어별 변경 비율(변경된 문자 수 / 기존 전체 파일): zh-CN 9.1% · hi 10.8% · es 11.9% · fr 12.5% · ar 12.2% · bn 11.3% · pt 11.6% · ru 12.0% · ja 8.9% · de 12.3% · ko 9.4% — **각 파일의 약 9-12%만 실제로 변경되었으므로**, 전체 재번역은 필요한 것보다 약 8-11배 더 많은 출력을 사용했습니다.

*방법: 커밋 `40dcf1f`에서 저장소에서 가져온 v1.4.0 파일; 배포된 v1.5.0 파일과 언어별 줄 단위 diff(추가/수정된 줄); 혼합 언어 README의 경우 토큰을 ~3자/토큰으로 근사 계산. 입력 측 비용도 다릅니다(증분 편집은 기존 번역을 읽음), 그러나 출력이 LLM 번역에서 지배적이고 가장 비용이 큰 부분입니다.*

## 머신 로컬 프로필(local-profile)

비표준 네트워킹(예: hosts 파일이 GitHub 도메인을 127.0.0.1로 하이재킹하고, 로컬 프록시 셤을 통해 실행해야 하는 휴대용 `gh`가 있는 경우)이 있는 머신에서 `E:\ds harness\gh\local-profile.json`이 owner, gh 항목, 구성 디렉터리 및 알려진 저장소 매핑을 통합합니다. 이 파일은 `"never_publish": true`로 표시되어 있습니다 — 머신에만 존재하며 절대 푸시되지 않습니다. 이 파일을 읽거나 수정하는 모든 작업은 먼저 명시적으로 강조된 확인을 받습니다.

## 환경 자가 점검(첫 푸시 전 1회)

- `Get-Command gh`(또는 스크립트가 설치 경로를 자동 감지하도록 함). 없으면: `winget install GitHub.cli`.
- `gh auth status`가 로그인된 계정을 표시합니다(토큰은 `github_pat_***…`로 마스킹됨).
- `gh api repos/{owner}/{repo}` 또는 `gh repo list`가 데이터를 반환합니다.

## 설치

```
~/.dsh/skills/gh-publisher/    # 전역
.dsh/skills/gh-publisher/      # 프로젝트별
```

*"push this to GitHub"*, *"publish this skill to a repo"* 같은 문구로 트리거하거나 — **set-skill**의 `/skill` 메뉴 항목 ⑤를 통해 트리거할 수 있습니다.

## 문서

- `references/security.md` — 개인정보 및 계정 보안
- `references/platform-adapter.md` — DSH / Codex / Claude Code 매핑
- `references/i18n.md` — 다국어 게시 프로토콜(10개 언어, 증분 편집 번역)

## 연계 스킬

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — 이 스킬을 `/skill` 메뉴 항목 ⑤로 나열합니다.
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — 이 스킬로 workflow-builder가 생성한 다중 에이전트 워크플로를 게시하세요.

## 요구 사항

- `gh` CLI(`gh auth login`으로 로그인) + `pwsh`(PowerShell Core, 크로스 플랫폼).

## Disclaimer

> **이 스킬은 100% AI로 제작되었습니다.** 문제가 발생할 수 있습니다 — 논의와 풀 리퀘스트를 환영합니다. 작성자는 실제 사용 경험을 바탕으로 지속적으로 개선하고 있습니다.

## 라이선스

[MIT](./LICENSE)
