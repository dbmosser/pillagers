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

# LOOT NAMES FADE SOONER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
LBL_STEP=Math.max(LBL_STEP,_lph+2);
'@ @'
LBL_STEP=ik?_lph:Math.max(LBL_STEP,_lph+2);   // v25.xx (lootfade): loot names stack plate on plate, no gap, so several pickups do not make a tall wall
'@

SubRx @'
life:(ik?6.0:1.9),big:!!big,ik:ik||null,w:myW});
'@ @'
life:(ik?4.0:1.9),big:!!big,ik:ik||null,w:myW});   // v25.xx (lootfade), HIS NOTE 2026-10-13: a loot name lives 4 s, not 6 (it impeded vision); the others are as they were
'@

SubRx @'
var _hold=lb.life*0.45;
'@ @'
var _hold=lb.life*(lb.ik?0.2:0.45);   // v25.xx (lootfade): a loot name holds a fifth of its life, then fades
'@

SubRx @'
var la=clamp(lb.t<=_hold?1:(1-(lb.t-_hold)/(lb.life-_hold)),0,1);
'@ @'
var la=clamp(lb.t<=_hold?1:(1-(lb.t-_hold)/(lb.life-_hold)),0,1)*(lb.ik?0.85:1);   // v25.xx (lootfade): and never quite full strength
'@

SubRx @'
var VER='25.79';
'@ @'
var VER='25.80';
'@

$pat = "(?m)^  now:'v25\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.80: Looted item names now fade after four seconds instead of six, start fading sooner and stack tighter. Check 25.80 fails on v25.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
