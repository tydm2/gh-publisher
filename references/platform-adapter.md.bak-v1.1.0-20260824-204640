# Multi-agent platform adaptation (platform-adapter)

`gh-publisher` is cross-platform: the core script is **PowerShell Core (pwsh)**, which runs on Windows/macOS/Linux; mechanisms map per platform, and no platform-specific command is hardcoded.

## Mechanism mapping

| Mechanism | DSH | Codex CLI | Claude Code |
|-----------|-----|-----------|-------------|
| Login | `gh auth login` (keyring) | same | same |
| Push script | `pwsh scripts/push.ps1 …` | same (shell) | same (bash/command) |
| Config dir | `$env:GH_CONFIG_DIR = <dir>` (when %APPDATA% is unwritable) | same | same |
| Confirm/clarify | `ask_user_question` popup | option-based text question | same as Codex |
| Secret scan | built into the script | built in | built in |

## Degradation without pwsh

1. If `pwsh` is unavailable, follow `SKILL.md`'s "Manual flow" with `gh api` step-by-step (Contents / Git Database) — identical logic.
2. Empty-repo init equivalent: Contents API `PUT /contents/{path}` to write the first file → auto-creates the default branch.

## What GH_CONFIG_DIR does

When an agent can't write `%APPDATA%\GitHub CLI` (sandbox / restricted account), point gh's config dir at a writable location:

```powershell
$env:GH_CONFIG_DIR = 'E:\ds harness\gh\.config'   # or any writable dir
```

This makes `gh auth login`'s hosts.yml land somewhere controllable and lets later `gh` calls find the login state; the token still goes to the system keyring, not this dir.

## General conventions

- The script depends only on `gh` (Go's own TLS — no system schannel/openssl quirks) and `pwsh`.
- Output is kept to the minimum number of lines so any agent can consume it at low token cost.
- All confirmations use option-based text questions for cross-platform consistency.
