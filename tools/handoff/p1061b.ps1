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

# v10.61, second part. The card a friend reads on the way in is the game's
# introduction, and with an alpha going out in three days it should say what
# the room sounds like now.
SubRx @'
var WHATSNEW_VER='10.60';
'@ @'
var WHATSNEW_VER='10.61';
'@
SubRx @'
  'WALLS ARE SOLID. Nothing goes see-through when you stand behind it, and in the Undercroft nobody can stand inside the part of a wall that is painted, so the people down there stop catching on the counters.',
'@ @'
  'WALLS ARE SOLID. Nothing goes see-through when you stand behind it, and in the Undercroft nobody can stand inside the part of a wall that is painted, so the people down there stop catching on the counters.',
  'THE UNDERCROFT IS DARKER. No bright square wave leading the tune, seventy-six beats a minute instead of a hundred, a closed filter, half the shimmer and a bass held long enough to hum under the room.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
