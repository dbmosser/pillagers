# Saves the CURRENT dark_raiders.html into builds/ under its own version number,
# and refreshes builds/index.json from git so the folder always lists every build
# that has ever been committed, whether or not its HTML is sitting here.
#
# Run this on every build, after the version bump and before the commit.
#
#   powershell -ExecutionPolicy Bypass -File tools\archive-build.ps1
#
# builds/ is gitignored on purpose. Git already stores every version of the game
# losslessly and delta compressed; a second copy of 846 near identical 1.6MB files
# would cost about half a gigabyte to say the same thing twice. What git cannot do
# is hand you a file you can double click, which is what this folder is for.
# Anything not here can be pulled back with tools\restore-build.ps1.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root 'dark_raiders.html'
$dir  = Join-Path $root 'builds'
if (-not (Test-Path $dir)) { New-Item -ItemType Directory $dir | Out-Null }

$text = [IO.File]::ReadAllText($src)
$m = [regex]::Match($text, "var VER='([0-9]+\.[0-9]+)';")
if (-not $m.Success) { throw 'could not read VER out of dark_raiders.html' }
$ver = $m.Groups[1].Value

$dst = Join-Path $dir ("v$ver.html")
Copy-Item $src $dst -Force
Write-Output "archived v$ver -> builds\v$ver.html"

# The index lists EVERY version in git history, and says which ones are playable
# from this folder right now.
Push-Location $root
$have = @{}
Get-ChildItem $dir -Filter 'v*.html' | ForEach-Object {
  $have[($_.BaseName -replace '^v','')] = $_.Length
}
$rows = @()
$seen = @{}
$log = & git log --date=format:'%Y-%m-%d %H:%M' --pretty='%H%x1f%ad%x1f%s'
foreach ($line in $log) {
  $p = $line -split ([char]31)
  if ($p.Count -lt 3) { continue }
  $vm = [regex]::Match($p[2], '^v([0-9]+\.[0-9]+): (.*)$')
  if (-not $vm.Success) { continue }
  $v = $vm.Groups[1].Value
  if ($seen.ContainsKey($v)) { continue }
  $seen[$v] = $true
  $rows += [pscustomobject]@{
    version  = $v
    date     = $p[1]
    commit   = $p[0].Substring(0,7)
    summary  = $vm.Groups[2].Value
    playable = $have.ContainsKey($v)
  }
}
Pop-Location

$idx = [pscustomobject]@{
  note     = 'Every version ever committed. playable=true means builds\v<version>.html is here now; anything else can be pulled back with tools\restore-build.ps1 -Ver <version>.'
  total    = $rows.Count
  onDisk   = ($rows | Where-Object { $_.playable }).Count
  builds   = $rows
}
$json = $idx | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText((Join-Path $dir 'index.json'), $json, (New-Object Text.UTF8Encoding $false))
Write-Output ("index.json: " + $rows.Count + " builds known, " + $idx.onDisk + " playable on disk")
