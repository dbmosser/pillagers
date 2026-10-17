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

# PLAYER 2 HIT STOP BY THE HOST RULE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netShotSend(e,dmg,ang,wk,ar,el,sk){
'@ @'
function netShotSend(e,dmg,ang,wk,ar,el,sk,hs){  /*v28.xx (cw-hitstoprule), CLOUD HUNT 2026-10-15: hs marks a heavy gun round (40 or more before multipliers), the host rule for hit stop*/
'@

SubRx @'
  if(el&&ELEM[el]) m.el=el;
'@ @'
  if(hs) m.hs=1;   // v28.xx (cw-hitstoprule), CLOUD HUNT 2026-10-15: the host holds the body by this mark, not by the multiplied number
  if(el&&ELEM[el]) m.el=el;
'@

SubRx @'
netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el,1); else en.hp-=affixSoak(en,edmg);
'@ @'
netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el,1,b.dmg>=HITSTOP_DMG); else en.hp-=affixSoak(en,edmg); /*v28.xx (cw-hitstoprule), CLOUD HUNT 2026-10-15: player 2 round says if it is heavy by the same raw number the host own round uses*/
'@

SubRx @'
e.pHitSeat=s; hitStopOn(e,d); suppHit(e);
'@ @'
e.pHitSeat=s; hitStopOn(e,m.hs===1?HITSTOP_DMG:0); suppHit(e); /*v28.xx (cw-hitstoprule), CLOUD HUNT 2026-10-15: hit stop by the host rule, not by the multiplied number*/
'@

SubRx @'
var VER='28.91';
'@ @'
var VER='28.92';
'@

$pat = "(?m)^  now:'v28\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.92: Heavy rounds from player 2 hold enemies for the same beat and on the same guns as player 1s, and his grenades and melee no longer hold them. Check 28.92 fails on v28.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
