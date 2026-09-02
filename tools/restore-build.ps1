# Pulls any historical build back out of git and drops it in builds/ as a file you
# can open in a browser.
#
#   powershell -ExecutionPolicy Bypass -File tools\restore-build.ps1 -Ver 8.42
#   powershell -ExecutionPolicy Bypass -File tools\restore-build.ps1 -From 9.00
#
# -Ver  one version.
# -From every version from that one up to the newest.
# -All  every version ever committed. About 1.4GB, so it asks for -Force.
param(
  [string]$Ver,
  [string]$From,
  [switch]$All,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root 'builds'
if (-not (Test-Path $dir)) { New-Item -ItemType Directory $dir | Out-Null }
Push-Location $root

function VerNum([string]$v){ $p = $v -split '\.'; return [double]$p[0] * 1000 + [double]$p[1] }

# newest commit per version, which is the one that shipped it
$map = [ordered]@{}
$log = & git log --reverse --pretty='%H%x1f%s'
foreach ($line in $log) {
  $p = $line -split ([char]31)
  if ($p.Count -lt 2) { continue }
  $vm = [regex]::Match($p[1], '^v([0-9]+\.[0-9]+): ')
  if ($vm.Success) { $map[$vm.Groups[1].Value] = $p[0] }
}

$want = @()
if ($Ver)      { $want = @($Ver) }
elseif ($From) { $want = $map.Keys | Where-Object { (VerNum $_) -ge (VerNum $From) } }
elseif ($All)  {
  if (-not $Force) { Pop-Location; throw 'All builds is about 1.4GB. Re-run with -Force if you mean it.' }
  $want = $map.Keys
}
else { Pop-Location; throw 'Give one of -Ver, -From or -All.' }

$done = 0; $missing = @()
foreach ($v in $want) {
  if (-not $map.Contains($v)) { $missing += $v; continue }
  $dst = Join-Path $dir ("v$v.html")
  # PowerShell 5.1 re-encodes on > and produced UTF-16 files at twice the size.
  # cmd writes the raw stdout bytes, so the copy is byte for byte what git holds.
  & cmd /c "git show $($map[$v]):dark_raiders.html > `"$dst`""
  if ((Get-Item $dst).Length -lt 1000) { Remove-Item $dst -Force; $missing += $v; continue }
  $done++
}
Pop-Location
Write-Output "restored $done build(s) into builds\"
if ($missing.Count) { Write-Output ("not found in history: " + ($missing -join ', ')) }
