# push.ps1 - git-free publish to GitHub via gh CLI + REST API
# Usage:  pwsh scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Branch main] [-GhConfigDir <path>] [-ForceSecret]
# Exit codes: 0 = ok, 1 = args/secret/network error
# Security: never prints tokens; secret-scans files before pushing; output is masked/minimal.
param(
  [Parameter(Mandatory = $true)][string]$Source,
  [Parameter(Mandatory = $true)][string]$Repo,
  [Parameter(Mandatory = $true)][string]$Message,
  [string]$Branch = 'main',
  [string]$GhConfigDir = '',
  [switch]$ForceSecret
)
$ErrorActionPreference = 'Stop'
$gh = (Get-Command gh -ErrorAction Stop).Source
if ($GhConfigDir) { $env:GH_CONFIG_DIR = $GhConfigDir }
$srcRoot = (Resolve-Path $Source).Path

# ---------- secret scan ----------
$patterns = @(
  'github_pat_[A-Za-z0-9_]{20,}',
  'ghp_[A-Za-z0-9]{20,}',
  'gho_[A-Za-z0-9]{20,}',
  'ghs_[A-Za-z0-9]{20,}',
  'ghr_[A-Za-z0-9]{20,}',
  '\bsk-[A-Za-z0-9]{20,}\b',
  'AKIA[0-9A-Z]{16}',
  '-----BEGIN (RSA |EC |OPENSSH |PGP )?PRIVATE KEY'
)
$hits = @()
Get-ChildItem $Source -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($srcRoot.Length + 1).Replace('\', '/')
  $txt = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
  if ($txt) {
    foreach ($p in $patterns) {
      if ($txt -match $p) { $hits += "$rel  (pattern: $p)" }
    }
  }
}
if ($hits.Count -gt 0) {
  if (-not $ForceSecret) {
    Write-Host "SECRET SCAN HIT - aborting. Use -ForceSecret to override. Hits:"
    $hits | ForEach-Object { Write-Host "  $_" }
    exit 1
  } else {
    Write-Host "WARN: secret scan hits overridden by -ForceSecret:"
    $hits | ForEach-Object { Write-Host "  $_" }
  }
}

# ---------- gh api helper (body via temp JSON, never via command-line args) ----------
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('ghp-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
function ApiJson($method, $endpoint, $obj) {
  $bf = Join-Path $tmp ('b-' + [guid]::NewGuid().ToString('N') + '.json')
  [IO.File]::WriteAllText($bf, ($obj | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding($false)))
  $raw = (& $gh api --method $method $endpoint --input $bf 2>$null) -join "`n"
  Remove-Item $bf -Force
  if (-not $raw) { throw "gh api failed: $endpoint" }
  return ($raw | ConvertFrom-Json)
}

# ---------- detect empty repo ----------
$isEmpty = $false
$meta = & $gh api "repos/$Repo" 2>$null | ConvertFrom-Json
if ($meta -and $meta.size -eq 0) { $isEmpty = $true }

if ($isEmpty) {
  # initialize: create the first file via Contents API (auto-creates default branch)
  $first = Get-ChildItem $Source -Recurse -File | Sort-Object FullName | Select-Object -First 1
  $rel = $first.FullName.Substring($srcRoot.Length + 1).Replace('\', '/')
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($first.FullName))
  $bf = Join-Path $tmp 'init.json'
  [IO.File]::WriteAllText($bf, (@{ message = 'chore: initialize repository'; content = $b64 } | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding($false)))
  $null = & $gh api --method PUT "repos/$Repo/contents/$rel" --input $bf 2>$null
  Remove-Item $bf -Force
  Write-Host "init: empty repo -> seeded with $rel"
}

# ---------- batch commit via Git Database API ----------
$head = ApiJson 'GET' "repos/$Repo/git/refs/heads/$Branch"
$parent = $head.object.sha
$files = Get-ChildItem $Source -Recurse -File | Sort-Object FullName
$treeItems = @()
foreach ($f in $files) {
  $rel = $f.FullName.Substring($srcRoot.Length + 1).Replace('\', '/')
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($f.FullName))
  $blob = ApiJson 'POST' "repos/$Repo/git/blobs" @{ content = $b64; encoding = 'base64' }
  $treeItems += @{ path = $rel; mode = '100644'; type = 'blob'; sha = $blob.sha }
}
$tree = ApiJson 'POST' "repos/$Repo/git/trees" @{ tree = $treeItems }
$commit = ApiJson 'POST' "repos/$Repo/git/commits" @{ message = $Message; tree = $tree.sha; parents = @($parent) }
$null = ApiJson 'PATCH' "repos/$Repo/git/refs/heads/$Branch" @{ sha = $commit.sha; force = $false }
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ("PUSHED {0} files -> https://github.com/{1} (branch {2})" -f $files.Count, $Repo, $Branch)
