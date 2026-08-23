# Privacy & Account Security (security)

Security when publishing to GitHub is a hard constraint; this file expands `gh-publisher`'s security red lines.

## 1. Tokens never land anywhere (core)

- Log in only via `gh auth login`; the token is stored in the system credential manager (keyring), and the script uses it implicitly through the `gh` CLI — it never reads the token itself.
- A temporary `GH_TOKEN` env var is removed immediately after use (`Remove-Item Env:GH_TOKEN`), never left in the session.
- Never write a token into: chat, logs, script source, commit messages, or repo files.
- If the user pastes a token into chat: do not echo, repeat, or write it to a file; point them to GitHub → Settings → Developer settings to check/rotate.

## 2. Output masking

- `gh auth status` shows tokens as `github_pat_***…` (prefix + mask), never in full.
- The script prints only: secret-scan hits, an init note, and `PUSHED N files -> URL`. Never request bodies or token fields from responses.
- If an error message leaks a token (e.g., in a URL query), regex-replace `github_pat_[A-Za-z0-9_]+` / `ghp_[A-Za-z0-9]+` before displaying.

## 3. Secret-scan checklist (must run before push)

`push.ps1` ships these patterns and aborts on hit:

| Pattern | Meaning |
|---------|---------|
| `github_pat_` | GitHub fine-grained PAT |
| `ghp_` / `gho_` / `ghs_` / `ghr_` | GitHub classic PAT scopes |
| `sk-[A-Za-z0-9]{20,}` | OpenAI-style / vendor API key prefix |
| `AKIA[0-9A-Z]{16}` | AWS Access Key |
| `-----BEGIN … PRIVATE KEY-----` | private keys (RSA/EC/OpenSSH/PGP) |

Also eyeball: `.env`, `*.pem`, `*.key`, `secrets.*`, `credentials.*`, `id_rsa`, DB connection strings, SMTP passwords — over-scan rather than under-scan.

## 4. When a secret leaks

- Found before push → abort, list hits, delete or placeholder (`<YOUR_TOKEN>`) and re-push.
- Already pushed → **rotate immediately** (revoke + regenerate); public-repo history cannot be truly deleted, so rotation is the only effective remedy.

## 5. Repo hygiene

- Confirm `.gitignore` isn't missing build artifacts / caches / local config.
- Never put in a public repo: personal data beyond a public email, internal addresses, unredacted log samples.
