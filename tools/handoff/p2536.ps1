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

# ENEMIES MISS MORE AT LONG RANGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
// 2026-10-12 (accfall), HIS ANSWER 8 a: enemies a little less accurate at long range. Every round an enemy fires (machines and
// pillagers alike) spreads wider the farther its aim point is: as before out to ACC_NEAR, then the spread grows by a third for every
// ACC_SPAN beyond it, up to ACC_FALL more (1.8 times the spread from about 830 out). Close fights and every player gun are unchanged,
// and no draw moved: the one spread roll per pellet is the same roll, only wider.
var ACC_NEAR=350, ACC_SPAN=600, ACC_FALL=0.8;
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@

SubRx @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1);
'@ @'
var spx=wep.spread*(((fromPlayer&&G.player.ads)||(!fromPlayer&&sh&&sh.steady))?0.4:1);
  if(!fromPlayer&&sh&&isFinite(tx)&&isFinite(ty)){ var _afd=Math.hypot(tx-sh.x,ty-sh.y); if(_afd>ACC_NEAR) spx*=1+Math.min(ACC_FALL,(_afd-ACC_NEAR)/ACC_SPAN); }   // 2026-10-12 (accfall): wider at long range
'@

SubRx @'
var VER='25.35';
'@ @'
var VER='25.36';
'@

$pat = "(?m)^  now:'v25\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.36: Enemy fire now spreads wider at long range, so distant shooters miss more; close fights are unchanged. Check 25.36 fails on v25.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
