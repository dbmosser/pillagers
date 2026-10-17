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

# FEWER GUNS IN LOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var LOOT={
'@ @'
// v28.xx (cw-fewerguns), HIS ORDER (2026-10-15): "fewer guns in loot". Every gun_ row in the locker, safe, body, jackpot and cache tables
// keeps half its old weight and hands the other half to a filler row of loot the table already holds, in the same place in the row. The
// table total and every other boundary stay where they were, so a roll that landed on no gun lands on the same thing, the KEY rows still
// cost their extra draw at the same spot, and the seed 4242 build keeps the same entities and containers (85/374, 165/593).
var LOOT={
'@

SubRx @'
['gun_smg',2],['gun_carbine',2],['gun_magnum',2]
'@ @'
['gun_smg',1],['plate',1],['gun_carbine',1],['stim',1],['gun_magnum',1],['frag',1]
'@

SubRx @'
['gun_rifle',5],['gun_shotgun',4],['gun_lmg',3],['gun_dmr',2],['gun_sniper',2]
'@ @'
['gun_rifle',2.5],['core',2.5],['gun_shotgun',2],['titan',2],['gun_lmg',1.5],['servo',1.5],['gun_dmr',1],['plate',1],['gun_sniper',1],['medkit',1]
'@

SubRx @'
['gun_whisper',2],['gun_lance',1]]
'@ @'
['gun_whisper',1],['comp',1],['gun_lance',0.5],['frag',0.5]]
'@

SubRx @'
['gun_smg',5],['gun_carbine',3]
'@ @'
['gun_smg',2.5],['medkit',2.5],['gun_carbine',1.5],['plate',1.5]
'@

SubRx @'
['gun_lance',7],['gun_whisper',7]
'@ @'
['gun_lance',3.5],['codex',3.5],['gun_whisper',3.5],['bloom',3.5]
'@

SubRx @'
['gun_dmr',8],['gun_rifle',7],['gun_lmg',6],['gun_shotgun',5]
'@ @'
['gun_dmr',4],['titan',4],['gun_rifle',3.5],['core',3.5],['gun_lmg',3],['ledger',3],['gun_shotgun',2.5],['coil',2.5]
'@

SubRx @'
['gun_whisper',4],['gun_lance',3]
'@ @'
['gun_whisper',2],['relay',2],['gun_lance',1.5],['reactor',1.5]
'@

SubRx @'
var VER='28.79';
'@ @'
var VER='28.80';
'@

$pat = "(?m)^  now:'v28\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.80: Guns turn up about half as often in containers and on bodies; other loot takes their place. Check 28.80 fails on v28.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
