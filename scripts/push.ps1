# push.ps1 - git-free publish to GitHub via gh CLI + REST API
# Usage:
#   pwsh -ExecutionPolicy Bypass -File scripts/push.ps1 -Source <dir> -Repo owner/repo -Message "msg" [-Branch main] [-GhConfigDir <path>] [-GhPath <path-to-gh.exe>] [-ForceSecret]
# Exit codes: 0 = ok, 1 = args/secret/network/gh-missing error
# Security: never prints tokens; secret-scans files before pushing; output is masked/minimal.
# v1.1.0 changes:
#   - auto-detect gh binary: -GhPath > PATH > common install paths; clear hint when missing
#   - auto-detect GH_CONFIG_DIR: -GhConfigDir > env > %APPDATA%\GitHub CLI
#   - robust empty-repo detection via git refs (404 = no commit yet = empty), fixes false-empty on README-only repos
#   - explicit "repo not found" error with `gh repo create` hint instead of silent failure
#   - API failures now surface gh's stderr tail for diagnosis
param(
  [Parameter(Mandatory = $true)][string]$Source,
  [Parameter(Mandatory = $true)][string]$Repo,
  [Parameter(Mandatory = $true)][string]$Message,
  [string]$Branch = 'main',
  [string]$GhConfigDir = '',
  [string]$GhPath = '',
  [switch]$ForceSecret
)
$ErrorActionPreference = 'Stop'

# ---------- locate gh binary ----------
function Find-Gh {
  if ($GhPath) {
    if (Test-Path $GhPath) { return (Resolve-Path $GhPath).Path }
    throw "gh not found at -GhPath: $GhPath"
  }
  $cmd = Get-Command gh -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $candidates = @(
    "$env:ProgramFiles\GitHub CLI\gh.exe",
    "$env:LOCALAPPDATA\Programs\GitHub CLI\gh.exe",
    "$env:ProgramFiles\gh\gh.exe"
  )
  foreach ($c in $candidates) { if ($c -and (Test-Path $c)) { return $c } }
  throw "gh CLI not found. Install it (winget install GitHub.cli) or pass -GhPath <path-to-gh.exe>."
}
$gh = Find-Gh

# ---------- config dir (only if explicitly needed) ----------
if ($GhConfigDir) { $env:GH_CONFIG_DIR = $GhConfigDir }
elseif ($env:GH_CONFIG_DIR) { }  # already set by the caller
elseif (Test-Path "$env:APPDATA\GitHub CLI") { $env:GH_CONFIG_DIR = "$env:APPDATA\GitHub CLI" }

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

# ---------- gh api helpers (body via temp JSON, never via command-line args) ----------
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('ghp-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

function Invoke-GhApi {
  # runs gh api, returns ($ok, $textOrError); never leaks token
  param([string]$Method, [string]$Endpoint, [string]$BodyFile = '')
  $args = @('api', '--method', $Method, $Endpoint)
  if ($BodyFile) { $args += @('--input', $BodyFile) }
  $out = (& $gh @args 2>&1 | Out-String)
  if ($LASTEXITCODE -ne 0) { return @($false, $out.Trim()) }
  return @($true, $out.Trim())
}

function ApiJson($method, $endpoint, $obj) {
  $bf = Join-Path $tmp ('b-' + [guid]::NewGuid().ToString('N') + '.json')
  [IO.File]::WriteAllText($bf, ($obj | ConvertTo-Json -Depth 8 -Compress), (New-Object Text.UTF8Encoding($false)))
  $res = Invoke-GhApi -Method $method -Endpoint $endpoint -BodyFile $bf
  Remove-Item $bf -Force
  if (-not $res[0]) { throw "gh api failed: $method $endpoint`n$($res[1])" }
  if (-not $res[1]) { throw "gh api returned empty body: $method $endpoint" }
  return ($res[1] | ConvertFrom-Json)
}

# ---------- check repo exists ----------
$repoCheck = Invoke-GhApi -Method 'GET' -Endpoint "repos/$Repo"
if (-not $repoCheck[0]) {
  Write-Host "REPO NOT FOUND: $Repo"
  Write-Host "Create it first, e.g.:  gh repo create $Repo --public --source `"$Source`" --push"
  Write-Host "(API detail: $($repoCheck[1]))"
  exit 1
}

# ---------- detect empty repo (git ref missing => no commit yet => empty) ----------
$head = Invoke-GhApi -Method 'GET' -Endpoint "repos/$Repo/git/refs/heads/$Branch"
$isEmpty = -not $head[0]

if ($isEmpty) {
  # initialize: seed the first file via Contents API (auto-creates the default branch)
  $first = Get-ChildItem $Source -Recurse -File | Sort-Object FullName | Select-Object -First 1
  if (-not $first) { Write-Host "ERROR: source dir has no files to push"; exit 1 }
  $rel = $first.FullName.Substring($srcRoot.Length + 1).Replace('\', '/')
  $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($first.FullName))
  $bf = Join-Path $tmp 'init.json'
  [IO.File]::WriteAllText($bf, (@{ message = 'chore: initialize repository'; content = $b64 } | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding($false)))
  $init = Invoke-GhApi -Method 'PUT' -Endpoint "repos/$Repo/contents/$rel" -BodyFile $bf
  Remove-Item $bf -Force
  if (-not $init[0]) { Write-Host "ERROR: repo init failed: $($init[1])"; exit 1 }
  Write-Host "init: empty repo -> seeded with $rel"
  $head = Invoke-GhApi -Method 'GET' -Endpoint "repos/$Repo/git/refs/heads/$Branch"
  if (-not $head[0]) { Write-Host "ERROR: repo init did not create branch ${Branch}: $($head[1])"; exit 1 }
}
$parent = ($head[1] | ConvertFrom-Json).object.sha

# ---------- batch commit via Git Database API ----------
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
