---
name: gh-publisher
description: Use when the user wants to publish files, a skill, or a project to a GitHub repository — especially when git is unavailable or the repo is empty. Publishes without git via the gh CLI + GitHub REST API (Contents / Git Database), with a built-in scripts/push.ps1 for one-command pushes; supports a machine-local profile (local-profile) that auto-resolves account/gh/repo; personal-data files are never published; tokens never enter chat/logs/files, files are secret-scanned before push, output is masked; adapts to DSH/Codex/Claude Code. Not for full git history or branch merges.
metadata:
  version: 1.4.0
  languages: [en]
  changelog:
    - 1.4.0: Machine-local optimization — new "machine-local profile (local-profile)": owner / gh entry (proxy-mode shim) / GH_CONFIG_DIR / known repo mapping live in a local-profile.json flagged never_publish (local-only, never pushed); push.ps1 gains -Profile (auto-resolves gh entry / config dir / repo by source match, languages auto-detected from README.<lang>.md), -Repo is now optional; new PERSONAL DATA GUARD — any local-profile.json / config.local.json inside the source aborts the push, and it runs before gh lookup so it fires even when gh is missing; hard rules upgraded to four (personal data never published); action gating: actions touching the local profile / personal data require an explicitly emphasized confirmation, ordinary pushes need only a one-line confirmation
    - 1.3.1: push.ps1 fix — under PS 7.2+ the script-wide $ErrorActionPreference='Stop' turned gh's stderr on expected failures (HTTP 409 "Git Repository is empty" when probing refs of a brand-new repo) into a terminating error that killed the script before the empty-repo init could run; Invoke-GhApi now temporarily downgrades EAP (restored in finally) so $LASTEXITCODE decides, not stderr. Verified end-to-end on a fresh empty repo (auto-seed → batch commit → exit 0)
    - 1.3.0: multilingual is now a DEFAULT push step — before pushing a skill/doc project, generate the 10-language READMEs (parallel agents), run -Languages/-RequireI18n checks, then push; skip only on explicit user opt-out. i18n.md gained an auto-trigger & execution-flow section; push.ps1 gained -RequireI18n (missing language files fail the push)
    - 1.2.0: multilingual publish — configurable local language (zh/en via config.local.json), 10 release languages (en/zh-CN/hi/es/fr/ar/bn/pt/ru/ja), references/i18n.md protocol, push.ps1 -Languages readiness check
    - 1.1.0: gh binary auto-detect (-GhPath) + GH_CONFIG_DIR auto-detect + robust empty-repo detection (git refs) + repo-not-found hint + surfaced API errors + environment self-check section
    - 1.0.0: initial English release for GitHub (the local zh version lives at ~/.dsh/skills/gh-publisher)
user-invocable: true
---

# gh-publisher

Publish a set of local files to a GitHub repository **without git**: use the `gh` CLI to call the GitHub REST API (Contents / Git Database) for empty-repo initialization and batch commits, with a built-in reusable script that runs it all in one command — token-efficient, privacy-safe, cross-platform.

## When to use / when not to use

- **Use**: git is unavailable; first-time init of an empty repo; publishing a skill / docs / project files as a GitHub repo; batch-writing many files (including multi-language READMEs).
- **Don't use**: branch merges, full git history, or multi-contributor development — use `git` or `gh repo` for those.

## Four hard rules (★ follow every time)

1. **Token-efficient**: prefer `scripts/push.ps1` (one command does everything); don't hand-call the API file-by-file or re-derive the blob→tree→commit→ref flow.
2. **Privacy & account security**: tokens never enter chat / logs / files; log in via `gh auth login` (keyring-managed); output is always masked; files are secret-scanned before push; never commit secrets.
3. **Multi-agent adaptable**: the body hardcodes no platform-specific tool names; the script runs on `pwsh` (PowerShell Core, cross-platform); mappings in `references/platform-adapter.md`.
4. **Personal data never leaves the machine (★v1.4)**: the machine-local profile (`local-profile.json` / `config.local.json`) holds account, path, and repo info — it is **never pushed to GitHub under any circumstances**; push.ps1 aborts the moment such a file appears in the source (PERSONAL DATA GUARD). Actions that create/modify/read the local profile or touch personal data require an **explicitly emphasized confirmation** (⚠️ machine-local, not for publishing) first; ordinary skill/doc pushes need only a one-line confirmation.

## Script usage (preferred, token-efficient)

```powershell
pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "commit msg" [-Profile <local-profile.json>] [-Branch main] [-GhConfigDir <path>] [-GhPath <path-to-gh.exe>] [-ForceSecret]
```

- `-ExecutionPolicy Bypass` avoids PowerShell's script-execution policy blocking the file on locked-down machines.
- The script auto-locates the `gh` binary (`-GhPath` → PATH → common install paths) and auto-detects `GH_CONFIG_DIR` (`-GhConfigDir` → env → `%APPDATA%\GitHub CLI`), so no manual PATH/config fiddling is needed.
- **With `-Profile`**: the machine-local profile auto-resolves the gh entry, the config dir, the repo (matched by source dir), and the languages (auto-detected from `README.<lang>.md`) — `-Repo`/`-Languages`/`-GhPath`/`-GhConfigDir` may all be omitted. See "Machine-local profile".
- The script automates: personal-data guard → secret scan → empty-repo detection (init if empty) → batch commit → masked output (prints only `PUSHED N files -> URL`).
- Secret-scan hits abort by default (listing locations); pass `-ForceSecret` to override.
- Repo missing → the script prints a `gh repo create ... --push` hint instead of failing silently.
- Parameters and exit codes are documented at the top of `scripts/push.ps1`.

## Machine-local profile (local-profile, ★v1.4)

On this machine (tydm2 deployment) the account / path / repo info is consolidated in `E:\ds harness\gh\local-profile.json` (JSON, flagged `"never_publish": true`):

- **Contents**: owner (tydm2), gh portable entry (a proxy-mode shim that bypasses Steam++'s hosts hijacking of GitHub domains), `GH_CONFIG_DIR` (`E:\ds harness\gh\.config`), the known repo mapping (workflow-builder-skill / create-generate-skill / gh-publisher / mode-creator-skill and their local source dirs), and network/auth notes.
- **Usage**: `push.ps1 -Profile <path> -Source <dir> -Message "..."` — the gh entry, config dir, repo, and languages are resolved automatically; no more hunting for account / gh / repo.
- **Personal-data guard (hard rule)**: any file named `local-profile.json` / `config.local.json` is **never pushed to GitHub**; push.ps1 aborts when detected; the profile lives only on this machine and is never published.
- **Action gating**: creating/modifying/reading the local profile, or any action touching personal data, requires an **explicitly emphasized confirmation** (⚠️ machine-local, not for publishing); ordinary pushes need only a one-line confirmation.
- **Machine migration**: copy the whole `E:\ds harness\gh\` directory (profile + portable gh).

## Environment self-check (run once before first push)

1. **gh available?** — `Get-Command gh` (or the script auto-detects install paths). If missing: `winget install GitHub.cli`, or pass `-GhPath <path-to-gh.exe>`.
2. **Logged in?** — `gh auth status` must show a logged-in account (token is masked as `github_pat_***…`; never paste a raw token anywhere).
3. **Config dir?** — usually automatic (`%APPDATA%\GitHub CLI`); if the agent cannot write there, set `GH_CONFIG_DIR` or pass `-GhConfigDir`.
4. **Test connectivity** — `gh api repos/{owner}/{repo}` or `gh repo list` should return data before the first push.

## Multilingual publish (DEFAULT push step for skill/doc projects)

**Before pushing a skill or documentation project to GitHub, the 10-language step runs by default** — skip only when the user explicitly says so (e.g. *"single-language push, no translations"*).

- **Local working copy stays in your language**: the installed skill dir holds `config.local.json` with `{"local_lang": "zh"|"en"}` (default `zh`). Say *"change local default language to English"* to switch — the local SKILL.md is updated to match. Read it before translating any local docs.
- **Release = 10 GitHub most-used languages**: `README.<lang>.md` for en, zh-CN, hi, es, fr, ar, bn, pt, ru, ja (full list + translation rules + trigger-contract notes in `references/i18n.md`). `SKILL.md` stays in one primary language (English for gh-publisher; the project's own convention otherwise); all language versions share the same `name`.
- **Default execution flow (mandatory unless opted out)**:
  1. Check whether the source already has the 10 `README.<lang>.md` files; for each missing one, generate the translation (parallel subagents; source = the primary README).
  2. Run the readiness check: `push.ps1 -Languages en,zh-CN,hi,es,fr,ar,bn,pt,ru,ja` — missing files are WARN (with `-Profile`, languages are auto-detected, so this can be omitted).
  3. For hard enforcement, add `-RequireI18n`: missing language files then **FAIL the push** (exit 1) instead of warning.
  4. Push.
- **See `references/i18n.md`** for the auto-trigger protocol, language list, translation rules, and opt-out wording.

## Manual flow (only when the script is unavailable)

1. Confirm source dir, target `owner/repo`, commit message, branch (default main).
2. **Personal-data check + secret scan** (see "Security red lines") — never publish `local-profile.json` / `config.local.json`.
3. Detect empty: `gh api repos/{owner}/{repo}` → check `size`, or `GET contents` returns 404 "empty".
4. Empty repo → write the first file via **Contents API** `PUT /contents/{path}` (auto-creates the default branch) → then batch-commit the rest via **Git Database API**; non-empty → Git Database API directly (blobs→tree→commit→PATCH ref).
5. Print only commit count + final URL — **never any token/secret**.

## Security red lines (self-check every item)

- [ ] Log in via `gh auth login` / keyring; tokens never appear in scripts or logs
- [ ] Secret-scan all files before push: `github_pat_`, `ghp_`, `gho_`, `ghs_`, `ghr_`, `sk-`, `AKIA…`, `-----BEGIN … PRIVATE KEY-----` — abort on hit
- [ ] Mask output: `gh auth status` shows tokens as `github_pat_***…`
- [ ] Never echo or write a token the user pasted into chat
- [ ] Commit message and files contain no keys, passwords, or private data
- [ ] (v1.4) **Personal-data guard**: `local-profile.json` / `config.local.json` in the source → push.ps1 aborts (PERSONAL DATA GUARD), never published
- [ ] (v1.4) **Action gating**: actions touching the local profile / personal data get an explicitly emphasized confirmation (⚠️ machine-local); ordinary pushes need only a one-line confirmation

## References

- `references/security.md` — privacy & account security (masking, secret-scan checklist, key rotation)
- `references/platform-adapter.md` — DSH / Codex / Claude Code mapping (GH_CONFIG_DIR, subagents, popup equivalents)
- `references/i18n.md` — multilingual publish protocol (10 languages, translation rules)
