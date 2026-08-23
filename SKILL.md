---
name: gh-publisher
description: Use when the user wants to publish files, a skill, or a project to a GitHub repository — especially when git is unavailable or the repo is empty. Publishes without git via the gh CLI + GitHub REST API (Contents / Git Database), with a built-in scripts/push.ps1 for one-command pushes; tokens never enter chat/logs/files, files are secret-scanned before push, output is masked; adapts to DSH/Codex/Claude Code. Not for full git history or branch merges.
metadata:
  version: 1.0.0
  languages: [en]
  changelog:
    - 1.0.0: initial English release for GitHub (the local zh version lives at ~/.dsh/skills/gh-publisher)
user-invocable: true
---

# gh-publisher

Publish a set of local files to a GitHub repository **without git**: use the `gh` CLI to call the GitHub REST API (Contents / Git Database) for empty-repo initialization and batch commits, with a built-in reusable script that runs it all in one command — token-efficient, privacy-safe, cross-platform.

## When to use / when not to use

- **Use**: git is unavailable; first-time init of an empty repo; publishing a skill / docs / project files as a GitHub repo; batch-writing many files (including multi-language READMEs).
- **Don't use**: branch merges, full git history, or multi-contributor development — use `git` or `gh repo` for those.

## Three hard rules (★ follow every time)

1. **Token-efficient**: prefer `scripts/push.ps1` (one command does everything); don't hand-call the API file-by-file or re-derive the blob→tree→commit→ref flow.
2. **Privacy & account security**: tokens never enter chat / logs / files; log in via `gh auth login` (keyring-managed); output is always masked; files are secret-scanned before push; never commit secrets.
3. **Multi-agent adaptable**: the body hardcodes no platform-specific tool names; the script runs on `pwsh` (PowerShell Core, cross-platform); mappings in `references/platform-adapter.md`.

## Script usage (preferred, token-efficient)

```powershell
pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "commit msg" [-Branch main] [-GhConfigDir <path>]
```

- The script automates: secret scan → empty-repo detection (init if empty) → batch commit → masked output (prints only `PUSHED N files -> URL`).
- Secret-scan hits abort by default (listing locations); pass `-ForceSecret` to override.
- Parameters and exit codes are documented at the top of `scripts/push.ps1`.

## Manual flow (only when the script is unavailable)

1. Confirm source dir, target `owner/repo`, commit message, branch (default main).
2. **Secret scan** (see "Security red lines").
3. Detect empty: `gh api repos/{owner}/{repo}` → check `size`, or `GET contents` returns 404 "empty".
4. Empty repo → write the first file via **Contents API** `PUT /contents/{path}` (auto-creates the default branch) → then batch-commit the rest via **Git Database API**; non-empty → Git Database API directly (blobs→tree→commit→PATCH ref).
5. Print only commit count + final URL — **never any token/secret**.

## Security red lines (self-check every item)

- [ ] Log in via `gh auth login` / keyring; tokens never appear in scripts or logs
- [ ] Secret-scan all files before push: `github_pat_`, `ghp_`, `gho_`, `ghs_`, `ghr_`, `sk-`, `AKIA…`, `-----BEGIN … PRIVATE KEY-----` — abort on hit
- [ ] Mask output: `gh auth status` shows tokens as `github_pat_***…`
- [ ] Never echo or write a token the user pasted into chat
- [ ] Commit message and files contain no keys, passwords, or private data

## References

- `references/security.md` — privacy & account security (masking, secret-scan checklist, key rotation)
- `references/platform-adapter.md` — DSH / Codex / Claude Code mapping (GH_CONFIG_DIR, subagents, popup equivalents)
