# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Português](./README.pt.md) · [Español](./README.es.md) · [日本語](./README.ja.md) · [Deutsch](./README.de.md) · [Français](./README.fr.md) · [Русский](./README.ru.md) · [한국어](./README.ko.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](./CHANGELOG.md)
[![100%25 AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**git なしで GitHub にファイルを公開 — トークン効率が良く、プライバシー安全、マルチエージェント対応。**

`gh-publisher` は、`gh` CLI + GitHub REST API（Contents / Git Database）を使ってローカルディレクトリを GitHub リポジトリに公開するエージェント向けスキルです — git は不要です。1 つの再利用可能なスクリプトで空リポジトリの初期化とバッチコミットを処理するため、エージェントは API フロー全体を毎回組み立て直すことなく、1 コマンドでプッシュできます。

## 特長

- **🚀 Git 不要のプッシュ** — git がないマシンでも動作し、空のリポジトリを自動的に初期化します。
- **⚡ トークン効率が良い** — 1 つの `scripts/push.ps1` コマンドで、スキャン → 初期化 → バッチコミット → マスク済み出力（`PUSHED N files -> URL` の 1 行だけ）までを実行します。手書きの API 呼び出しを何十回も繰り返す必要はありません。
- **🔒 プライバシーとアカウントの安全** — トークンは `gh` の keyring にだけ置かれます（チャット・ログ・ファイルには決して置かれません）。ファイルはプッシュ前に secret scan されます（`github_pat_`、`ghp_`、`sk-`、秘密鍵など）。出力はマスクされます。
- **🔌 マルチエージェント対応** — `pwsh` スクリプトは Windows / macOS / Linux で動作します。DSH / Codex / Claude Code のマッピングが文書化されており、プラットフォーム固有のツール名はハードコードされていません。
- **🧩 空リポジトリの自動初期化** — 空のリポジトリを検出し、バッチコミットの前に Contents API 経由で最初のファイルを投入します。

## 仕組み

1. `pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "…"`
2. Secret scan → キー／トークンのパターンを検出したら中止します（`-ForceSecret` を指定した場合を除く）。
3. 空のリポジトリを検出 → 必要なら最初のファイルを投入します（Contents API）。
4. 全ファイルをバッチコミットします（Git Database API: blobs → tree → commit → ref）。
5. `PUSHED N files -> https://github.com/owner/repo` を出力します — それ以外は何も出力しません。

## インストール

```
~/.dsh/skills/gh-publisher/    # グローバル
.dsh/skills/gh-publisher/      # プロジェクトごと
```

「*"push this to GitHub"*」や「*"publish this skill to a repo"*」のようなフレーズで呼び出すか、**set-skill** の `/skill` メニュー項目 ⑤ から実行します。

## ドキュメント

- `references/security.md` — プライバシーとアカウントの安全
- `references/platform-adapter.md` — DSH / Codex / Claude Code のマッピング

## 関連スキル

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — このスキルを `/skill` メニュー項目 ⑤ として一覧表示します。
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — これが生成するマルチエージェントワークフローを、このスキルで公開できます。

## 必要環境

- `gh` CLI（`gh auth login` でログイン済み）+ `pwsh`（PowerShell Core、クロスプラットフォーム）。

## 免責事項

> **このスキルは 100% AI が作成したものです。** 問題は避けられません — 議論やプルリクエストを歓迎します。作者は実際の使用状況に基づいて積極的に改善を繰り返しています。

## ライセンス

[MIT](./LICENSE)
