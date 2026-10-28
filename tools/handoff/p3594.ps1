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

# THE OVERSEER BAR ONLY IN A FIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBossBar(){

'@ @'
// v35.xx (cw-bossbarfight), HIS ORDER (2026-10-28, a picture of the bar across the top while the Overseer walked among the crawlers): "the overseer's health bar should go
// away unless i'm actively fighting him eg dealt damage in last few secs". The bar shows for BOSSBAR_HOLD seconds after the last hit you or your partner landed on
// him (pHitT, which every round, charge, blade and air strike of the party sets); a joined window, which does not hold the hit marks, counts a drop in his health.
var BOSSBAR_HOLD=4;
function drawBossBar(){

'@

SubRx @'
  if(!e.barSeen){ var _bsv=false; try{ _bsv=canSee(p.x,p.y,p.face,e.x,e.y,G.vseg); }catch(_bs){ _bsv=false; } if(!_bsv) return; e.barSeen=1; }

'@ @'
  var _bft=+G.t||0, _bfj=(typeof NET==='object'&&NET&&NET.on&&NET.role==='join');
  if((+e.pHitT||0)>0||(_bfj&&typeof e.barHp==='number'&&e.hp<e.barHp)) e.barHitAt=_bft;   // v35.xx (cw-bossbarfight): a hit landed on him
  e.barHp=e.hp;
  if(!(typeof e.barHitAt==='number'&&_bft>=e.barHitAt&&_bft-e.barHitAt<BOSSBAR_HOLD)) return;   // v35.xx (cw-bossbarfight): not in a fight with him, no bar
  if(!e.barSeen){ var _bsv=false; try{ _bsv=canSee(p.x,p.y,p.face,e.x,e.y,G.vseg); }catch(_bs){ _bsv=false; } if(!_bsv) return; e.barSeen=1; }

'@

SubRx @'
var VER='35.93';
'@ @'
var VER='35.94';
'@

$pat = "(?m)^  now:'v35\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.94: the overseer bar shows only while you fight him Check 35.94 fails on v35.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
