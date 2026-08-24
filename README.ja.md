# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**git を使わずにファイルを GitHub へ公開 — トークン効率・プライバシー安全・マルチエージェント・多言語対応。**

`gh-publisher` は、`gh` CLI + GitHub REST API（Contents / Git Database）を使ってローカルディレクトリを GitHub リポジトリへ公開するエージェント向けスキルです — git は不要です。空リポジトリの初期化と一括コミットを 1 つの再利用可能なスクリプトで処理するため、エージェントは API フロー全体を毎回組み立て直すことなく、1 コマンドでプッシュできます。さらに、ローカルの作業コピーをお好みの言語のまま維持しつつ、**GitHub で最も使用されている 10 言語**（README 翻訳）も公開します。

## 際立つポイント

- **🚀 Git 不要のプッシュ** — git のないマシンでも動作し、空リポジトリを自動的に初期化します。
- **⚡ トークン効率** — 1 つの `scripts/push.ps1` コマンドでスキャン → 初期化 → 一括コミット → マスク済み出力（`PUSHED N files -> URL` の 1 行だけ）を実行し、手作業の API 呼び出し数十回分を代替します。
- **🔒 プライバシーとアカウントの安全** — トークンは `gh` の keyring のみに置かれ（チャット／ログ／ファイルには決して置かれません）、プッシュ前にファイルのシークレットスキャンが行われ（`github_pat_`、`ghp_`、`sk-`、秘密鍵など）、出力はマスクされます。
- **🔌 マルチエージェント対応** — `pwsh` スクリプトは Windows／macOS／Linux で動作し、DSH / Codex / Claude Code の対応表を文書化。プラットフォーム固有のツール名をハードコードしません。
- **🧩 空リポジトリの自動初期化** — 空リポジトリを検出し、一括コミットの前に Contents API 経由で最初のファイルを投入します。
- **🌍 多言語公開** — ローカルの作業コピーは選択した言語（デフォルトは中国語）のまま維持し、リリースには GitHub で最も使用されている 10 言語（en、zh-CN、hi、es、fr、ar、bn、pt、ru、ja）の README 翻訳を同梱します。`references/i18n.md` を参照。

## 仕組み

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. `gh` バイナリを自動検出し（`-GhPath` → PATH → 一般的なインストールパス）、`GH_CONFIG_DIR` を自動判別します — PATH／設定の手動調整は不要です。
3. シークレットスキャン → キー／トークンのパターンがあれば中止します（`-ForceSecret` 指定時を除く）。
4. ブランチ ref を確認して空リポジトリを検出し（404 = 空）、必要なら最初のファイルを投入します（Contents API）。
5. 全ファイルを一括コミットします（Git Database API: blobs → tree → commit → ref）。
6. `PUSHED N files -> https://github.com/owner/repo` だけを出力します。リポジトリが無い場合は `gh repo create` のヒントを表示します。
7. 任意の `-Languages` チェック: プッシュ前に各言語ファイルの存在（例: `README.hi.md`）を検証し、欠けている場合は警告します。

## 多言語公開（ローカル言語 + 10 のリリース言語）

- **ローカル作業コピー**: 設定した言語（zh または en）のまま維持されます — インストール済みスキルディレクトリ内の `config.local.json`（デフォルトは `zh`）。切り替えには *"change local default language to English"*（ローカルの既定言語を英語に変更）と言うだけで、ローカルの SKILL.md も合わせて更新されます。
- **リリース**: `SKILL.md` は英語（GitHub の共通プライマリ）のまま維持し、`README.<lang>.md` は最も使用されている 10 言語で公開されます。言語リスト、翻訳ルール、トリガー契約に関する注意（全言語版で同じ `name` を維持）は `references/i18n.md` を参照してください。

## 環境のセルフチェック（初回プッシュ前に 1 回）

- `Get-Command gh`（またはスクリプトにインストールパスを自動検出させます）。無い場合は `winget install GitHub.cli`。
- `gh auth status` でログイン済みアカウントが表示されます（トークンは `github_pat_***…` のようにマスクされます）。
- `gh api repos/{owner}/{repo}` または `gh repo list` がデータを返します。

## インストール

```
~/.dsh/skills/gh-publisher/    # global
.dsh/skills/gh-publisher/      # per project
```

トリガーは *"push this to GitHub"*、*"publish this skill to a repo"* のようなフレーズ、または **set-skill** の `/skill` メニュー項目 ⑤ です。

## ドキュメント

- `references/security.md` — プライバシーとアカウントの安全
- `references/platform-adapter.md` — DSH / Codex / Claude Code の対応
- `references/i18n.md` — 多言語公開プロトコル（10 言語）

## 関連スキル

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — このスキルを `/skill` メニュー項目 ⑤ として掲載します。
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — これが生成するマルチエージェントワークフローを本スキルで公開できます。

## 必要環境

- `gh` CLI（`gh auth login` でログイン済み）+ `pwsh`（PowerShell Core、クロスプラットフォーム）。

## 免責事項

> **このスキルは 100% AI 製です。** 不具合は避けられないため、議論やプルリクエストを歓迎します。作者は実際の利用状況に基づいて継続的に改善を重ねています。

## ライセンス

[MIT](./LICENSE)
