$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ==== THE SAME MISTAKE I MADE AT v10.80: the new WHAT IS NEW line went above
# ==== the alpha warning, and v10.38 requires that warning to be the first thing
# ==== a friend reads. The check caught it. The line goes second.
SubRx @'
var WHATSNEW=[
  'X NO LONGER SWAPS WEAPONS. The hotbar does that job, so the key is gone along with its legend lines. Your stowed gun and its ammo are still shown, just without a key in front of them. On a controller, X is still search.',
'@ @'
var WHATSNEW=[
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'X NO LONGER SWAPS WEAPONS. The hotbar does that job, so the key is gone along with its legend lines. Your stowed gun and its ammo are still shown, just without a key in front of them. On a controller, X is still search.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
