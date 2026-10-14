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

# HIT STOP AND THE LANCE KICK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function elemHold(e,dt){
'@ @'
// v26.xx (feel10), HIS ORDER (2026-10-14): "hit stop to enemies - do minor player knock back on using the meridian lance". WHAT WAS WRONG: a
// round that landed changed nothing about the body it hit, so a Magnum or a Longshot hit read the same as a pistol tap. A HEAVY ROUND (40 or
// more) NOW STOPS THE BODY IT HITS FOR HITSTOP_T SECONDS: it neither moves nor shoots, held by the same hold the shock stun uses (elemHold),
// and the stop is ticked off with the other element timers (elemTick). A body that dies from the round is not held, a boss is never held, and
// the stop is live play only (G.sim never sets it, so G.elemAny stays unset in the bot raids). THE MERIDIAN LANCE KICKS YOU BACK: firing it
// shoves the player backwards along the shot for LANCE_KICK_T seconds at LANCE_KICK_V, through the wall push-out, so it never goes into a wall.
// Nothing here draws from the seeded stream.
var HITSTOP_DMG=40, HITSTOP_T=0.06, LANCE_KICK_V=190, LANCE_KICK_T=0.12;
function hitStopOn(e,dmg){
  if(!G||G.sim||!e||e.boss||e.downed||e.finished||!(e.hp>0)||!(dmg>=HITSTOP_DMG)) return false;
  e.stopT=HITSTOP_T; G.elemAny=1;
  return true;
}
function lanceKick(p,ang){
  if(!G||G.sim||!p||!isFinite(ang)) return false;
  p.kickVx=-Math.cos(ang)*LANCE_KICK_V; p.kickVy=-Math.sin(ang)*LANCE_KICK_V; p.kickT=LANCE_KICK_T;
  return true;
}
function elemHold(e,dt){
  if(e.stopT>0&&e.hp>0&&!e.downed){ e.moving=false; return true; }   // v26.xx (feel10): held for the beat a heavy round lands
'@

SubRx @'
if(e.stunT>0){ e.stunT-=dt; if(e.stunT<0) e.stunT=0; }
'@ @'
if(e.stopT>0){ e.stopT-=dt; if(e.stopT<0) e.stopT=0; }   // v26.xx (feel10): the hit-stop clock
    if(e.stunT>0){ e.stunT-=dt; if(e.stunT<0) e.stunT=0; }
'@

SubRx @'
              en.hitT=.16;
'@ @'
              en.hitT=.16; hitStopOn(en,b.dmg);   // v26.xx (feel10): a heavy round stops the body for a beat
'@

SubRx @'
e.hp-=d; e.hitT=.16; e.pHitT=.3; e.pHitSeat=s;
'@ @'
e.hp-=d; e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,d);
'@

SubRx @'
    G.player.recoil=1; G.player.combatT=0; G.tel.shots+=shots;
'@ @'
    G.player.recoil=1; G.player.combatT=0; G.tel.shots+=shots;
    if(gunBase(wep.id)==='lance'&&!G.sim) lanceKick(G.player,ang);   // v26.xx (feel10): the Meridian Lance shoves you back a step
'@

SubRx @'
  if(p.recoil>0) p.recoil-=dt*7;
'@ @'
  if(p.recoil>0) p.recoil-=dt*7;
  if(p.kickT>0){ var _lkd=Math.min(dt,p.kickT); p.kickT-=dt; p.x+=(p.kickVx||0)*_lkd; p.y+=(p.kickVy||0)*_lkd; collide(p,G.map.walls); }   // v26.xx (feel10): the Lance kick
'@

SubRx @'
var VER='26.54';
'@ @'
var VER='26.55';
'@

$pat = "(?m)^  now:'v26\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.55: Heavy rounds stop what they hit for a beat, and the Meridian Lance kicks you back a step. Check 26.55 fails on v26.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
