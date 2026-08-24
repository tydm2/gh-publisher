# Changelog

All notable changes to `gh-publisher` are documented here. The skill follows [Semantic Versioning](https://semver.org/).

## [1.1.0] — 2026-08-24 — usage-driven iteration

Iterated from real-world usage (pushing office-studio + office-imagegen-skill revealed six friction points):

- **Auto-detect the `gh` binary**: new `-GhPath` parameter + common install-path probing (`Program Files\GitHub CLI`, `LocalAppData`, `Program Files\gh`) — previously the script hard-failed when `gh` was not on PATH.
- **Auto-detect `GH_CONFIG_DIR`**: `-GhConfigDir` → `$env:GH_CONFIG_DIR` → `%APPDATA%\GitHub CLI` — no manual config fiddling.
- **Robust empty-repo detection**: now checks the branch git ref (404 = no commit yet = empty) instead of `repo.size == 0`, which falsely treated README-only repos as empty.
- **Repo-not-found hint**: prints `gh repo create <owner>/<repo> --public --source <dir> --push` instead of failing silently.
- **Surfaced API errors**: `gh api` stderr tail is now included in failure messages for diagnosis.
- **Documented `-ExecutionPolicy Bypass`** usage (PowerShell policy blocked `& script.ps1` on locked-down machines).
- **Environment self-check section** added to SKILL.md (en/zh) and README (en/zh): gh availability, `gh auth status`, connectivity probe.
- Multi-language READMEs other than en/zh-CN remain v1.0.0 snapshots; en/zh-CN are the source of truth.

## [1.0.0] — Initial English release

- First public release for GitHub.
- `SKILL.md` + `references/security.md` + `references/platform-adapter.md` in English.
- `scripts/push.ps1`: one-command git-free publish (secret scan → empty-repo init → batch commit → masked output).
- Multi-language README (10 languages).
- MIT license + AI-crafted disclaimer.

> The local Chinese version lives at `~/.dsh/skills/gh-publisher/` and remains the working copy on the author's machine.
