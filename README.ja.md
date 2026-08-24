# gh-publisher

[English](./README.md) · [简体中文](./README.zh-CN.md) · [हिन्दी](./README.hi.md) · [Español](./README.es.md) · [Français](./README.fr.md) · [العربية](./README.ar.md) · [বাংলা](./README.bn.md) · [Português](./README.pt.md) · [Русский](./README.ru.md) · [日本語](./README.ja.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.5.0-blue.svg)](./CHANGELOG.md)
[![100% AI-crafted](https://img.shields.io/badge/100%25-AI--crafted-9cf.svg)](#disclaimer)

**git なしで GitHub にファイルを公開 — トークン効率・プライバシー安全・マルチエージェント・多言語対応。**

`gh-publisher` は、`gh` CLI + GitHub REST API（Contents / Git Database）を使ってローカルディレクトリを GitHub リポジトリに公開するエージェントスキルです — git は不要です。空リポジトリの初期化とバッチコミットを 1 つの再利用可能なスクリプトで処理するため、エージェントは API フロー全体を毎回再構築する代わりに、1 コマンドでプッシュできます。また、ローカルの作業コピーはお好みの言語のまま維持しつつ、**GitHub で最も使われている 10 言語**（README 翻訳）も公開します。

## 特長

- **🚀 git 不要のプッシュ** — git のないマシンでも動作し、空リポジトリを自動的に初期化します。
- **⚡ トークン効率** — 1 つの `scripts/push.ps1` コマンドで、ガード → スキャン → 初期化 → バッチコミット → マスク出力（`PUSHED N files -> URL` の 1 行）までを行います。手作業による多数の API 呼び出しは不要です。
- **🌍 トークン効率の高い翻訳** — 多言語 README は**インクリメンタル編集翻訳**で更新されます（サブエージェントが既存の翻訳の上で変更された段落だけを編集し、全文を再翻訳しません）。出力トークンが約 70〜90% 削減され、高速化し、用語・文体も安定します。
- **🔒 プライバシーとアカウントの安全性** — トークンは `gh` キーリングの中だけに存在します（チャット・ログ・ファイルには決して保存されません）。プッシュ前にファイルをシークレットスキャンし（`github_pat_`、`ghp_`、`sk-`、秘密鍵など）、出力はマスクされます。
- **🛡️ 個人データガード** — マシンローカルプロファイル（`local-profile.json` / `config.local.json`）は**決して**公開できません。ソース内にそのようなファイルが現れた瞬間、他の処理が実行される前にプッシュは中止されます。
- **🗂️ マシンローカルプロファイル** — ネットワーク環境が厄介なマシン（例：hosts 乗っ取り）では、1 つの `local-profile.json` にアカウント、gh エントリ（プロキシモードのシム）、既知のリポジトリ対応付けを集約するため、プッシュには `-Profile` だけが必要です — アカウント / gh / リポジトリを探し回る必要はもうありません。
- **🔌 マルチエージェント対応** — `pwsh` スクリプトは Windows/macOS/Linux で動作します。DSH / Codex / Claude Code の対応付けはドキュメント化されており、プラットフォームのツール名はハードコードされていません。
- **🧩 空リポジトリの自動初期化** — 空リポジトリを検出し、バッチコミットの前に Contents API で最初のファイルを投入します。
- **🌍 多言語公開** — ローカルの作業コピーは選択した言語（デフォルトは中国語）のまま維持されます。リリースには GitHub で最も使われている 10 言語（en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja）の README 翻訳が同梱されます。詳細は `references/i18n.md` を参照してください。

## 動作の仕組み

1. `pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Profile <local-profile.json>] [-GhPath <path-to-gh.exe>] [-Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja]`
2. `gh` バイナリ（`-GhPath` → PATH → 一般的なインストールパス）を自動的に特定し、`GH_CONFIG_DIR` も自動検出します — PATH / 設定の手動調整は不要です。`-Profile` を指定すると、gh エントリ、設定ディレクトリ、リポジトリ（ソースディレクトリから一致）、言語（`README.<lang>.md` から自動検出）が自動的に解決されます。
3. **個人データガード** — ソース内に `local-profile.json` / `config.local.json` がある場合 → 中止します（これらは決して公開してはいけません）。
4. シークレットスキャン → キー / トークンのパターンが見つかったら中止します（`-ForceSecret` を指定した場合を除く）。
5. ブランチ ref を確認して空リポジトリを検出（404 = 空）→ 必要に応じて最初のファイルを投入（Contents API）。
6. 全ファイルをバッチコミット（Git Database API: blobs → tree → commit → ref）。
7. `PUSHED N files -> https://github.com/owner/repo` だけを出力します — それ以外は出力しません。リポジトリが存在しない場合は `gh repo create` のヒントを出力します。
8. オプションの `-Languages` チェック: プッシュ前に各言語ファイル（例：`README.hi.md`）の存在を確認し、不足があれば警告します。

## 多言語公開（ローカル言語 + 10 のリリース言語）

- **ローカルの作業コピー**: 設定した言語（zh または en）のまま維持されます — インストールされたスキルディレクトリ内の `config.local.json`（デフォルトは `zh`）。*"change local default language to English"*（＝ローカルのデフォルト言語を英語に変更）と言うと切り替わり、ローカルの SKILL.md もそれに合わせて更新されます。
- **リリース**: `SKILL.md` は英語のまま維持され（GitHub の普遍的プライマリ）、10 の最も使われている言語の `README.<lang>.md` が公開されます。言語リスト、翻訳ルール、トリガー契約の注意点（すべての言語版が同じ `name` を維持すること）については `references/i18n.md` を参照してください。
- **トークン効率の高い固定方式**: 既存の翻訳がある言語はインクリメンタル編集翻訳で更新されます（変更された段落だけを編集し、全文を再翻訳しません）。初回の言語は、用語の基準を確立する完全な翻訳を 1 回受けます。詳細は `references/i18n.md` §1.5 を参照してください。

## マシンローカルプロファイル（local-profile）

非標準的なネットワーク環境のマシン（例：hosts ファイルが GitHub ドメインを 127.0.0.1 に乗っ取っており、さらにローカルプロキシシム経由で実行する必要があるポータブル `gh` を使用している場合）では、`E:\ds harness\gh\local-profile.json` がオーナー、gh エントリ、設定ディレクトリ、既知のリポジトリ対応付けを集約します。このファイルは `"never_publish": true` とフラグ付けされており、マシン上にのみ存在し、プッシュされることは決してありません。このファイルを読み取る / 変更する操作はすべて、最初に明示的に強調された確認を求めます。

## 環境の自己チェック（最初のプッシュ前に一度）

- `Get-Command gh`（またはスクリプトにインストールパスの自動検出を任せる）。なければ: `winget install GitHub.cli`。
- `gh auth status` でログイン中のアカウントが表示されること（トークンは `github_pat_***…` のようにマスクされます）。
- `gh api repos/{owner}/{repo}` または `gh repo list` がデータを返すこと。

## インストール

```
~/.dsh/skills/gh-publisher/    # グローバル
.dsh/skills/gh-publisher/      # プロジェクトごと
```

*"push this to GitHub"*（これを GitHub にプッシュ）、*"publish this skill to a repo"*（このスキルをリポジトリに公開）のようなフレーズで起動します — または **set-skill** の `/skill` メニュー項目 ⑤ から。

## ドキュメント

- `references/security.md` — プライバシーとアカウントの安全性
- `references/platform-adapter.md` — DSH / Codex / Claude Code の対応付け
- `references/i18n.md` — 多言語公開プロトコル（10 言語、インクリメンタル編集翻訳）

## 連携スキル

- **[set-skill](https://github.com/tydm2/create-generate-skill)** — このスキルを `/skill` メニュー項目 ⑤ として一覧表示します。
- **[workflow-builder](https://github.com/tydm2/workflow-builder-skill)** — これが生成するマルチエージェントワークフローを、このスキルで公開します。

## 要件

- `gh` CLI（`gh auth login` でログイン）+ `pwsh`（PowerShell Core、クロスプラットフォーム）。

## Disclaimer

> **このスキルは 100% AI が制作しています。** 問題は避けられません — 議論とプルリクエストを歓迎します。作者は実際の使用状況に基づいて積極的に改良を続けています。

## ライセンス

[MIT](./LICENSE)
