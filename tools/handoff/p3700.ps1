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

# ONLY MACHINES ARE GOLDEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function goldOk(e,p){
  return !!e&&e.hp>0&&!!GOLD.kinds[e.kind]&&
'@ @'
function goldOk(e,p){
  // v37.xx (cw-nogoldpillager), HIS WORDS (2026-10-31): "there should not be golden pillager bots -- pillager bots are meant to replicate live players since we will take the game online eventually".
  // Only machines are golden: a pillager of any kind never qualifies. Rule for later: pillagers stand in for live players, so they get no boss-style buffs.
  return !!e&&e.hp>0&&e.kind!=='raider'&&!!GOLD.kinds[e.kind]&&
'@

SubRx @'
var VER='36.99';
'@ @'
var VER='37.00';
'@

$pat = "(?m)^  now:'v36\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.00: Only machines are golden. The golden enemy is never a pillager. WATCH: a raid where the golden enemy is always a machine; if a raid has none far enough away, no golden enemy that raid. Check 37.00 fails on v36.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
