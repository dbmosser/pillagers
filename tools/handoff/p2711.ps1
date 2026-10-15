$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# WAVES GROW THE LONGER YOU STAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeWaveTick(dt){
'@ @'
// v27.xx (waveramp), HIS ANSWER 28 (2026-10-13): "waves grow the longer you stay -- i thought we already discussed that". They did not: the
// wave tier was the team score over 4,000, so a man who hid or fought little met the same small packs at minute nine as at minute one. The tier
// now also has a floor that rises with the raid clock, one step every two minutes up to tier 4 (packs of 4, sentries from minute 2, hostile
// pillagers from minute 4, the first body of each pack an elite from minute 8); the score still lifts it higher, to the same 8. DEMO and CAREER
// run this one tick, so both ramp alike. Gentle on purpose: the clock floor stops at 4.
function waveTier(score){
  var st=Math.max(0,Math.min(8,Math.floor((+score||0)/4000))), tt=Math.max(0,Math.min(4,Math.floor((+elapsed()||0)/120)));
  return Math.max(st,tt);
}
function arcadeWaveTick(dt){
'@

SubRx @'
var tier=Math.max(0,Math.min(8,Math.floor((G.arcade?arcadeTeam():Math.max(0,WS.s|0))/4000))), iv=
'@ @'
var tier=waveTier(G.arcade?arcadeTeam():Math.max(0,WS.s|0)), iv=
'@

SubRx @'
var VER='27.10';
'@ @'
var VER='27.11';
'@

$pat = "(?m)^  now:'v27\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.11: The longer you stay in a raid, the bigger the waves get, even when you are not scoring. Check 27.11 fails on v27.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
