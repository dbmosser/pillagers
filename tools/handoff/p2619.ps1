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

# THE OVERSEER SEES FARTHER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BOSS_NAME='THE OVERSEER';
'@ @'
var BOSS_NAME='THE OVERSEER';
// v26.xx (overseersight), HIS NOTE (2026-10-14): "Overseer needs better sight distance, he was looking right at me and didn't attack".
// Three faults in the warden branch, the worst of them the leash of v17.45. (1) Its sight, which is also its reach (rng), was a plain
// warden's 620, short for a boss that fills the screen: BOSS_SIGHT times that now, 868 (a balance change, allowed by his ruling of
// 2026-10-02; the cone, the speed and the damage are unchanged). (2) Past 1100 from its lair the leash sent its walk home and turned
// its body that way, so the windup it had started ran out facing the lair, the cone lost you and the shot never came: it charged,
// looked at you and did nothing. Now, seeing you inside its reach, it holds where it stands, faces you and fires; the leash still
// stops it CHASING (out of reach it walks home as before). (3) The sprite looks left or right by the sign of cos(face) while the
// cone is 66 degrees either side of the heading, so walking up or down it could face you and not see you: it now sees whatever
// stands on the side it faces, out to its sight, with a clear line. A plain warden is untouched.
var BOSS_SIGHT=1.4;
'@

SubRx @'
rng:(CFG.wardenRng===undefined?620:CFG.wardenRng),
     cone:1.15,hitT:0,seenYou:false,lairX:L.x,lairY:L.y};
'@ @'
rng:Math.round((CFG.wardenRng===undefined?620:CFG.wardenRng)*BOSS_SIGHT),   // v26.xx (overseersight): 868, not 620
     cone:1.15,hitT:0,seenYou:false,lairX:L.x,lairY:L.y};
'@

SubRx @'
    var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee,e.cone,_aSee);
'@ @'
    var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee,e.cone,_aSee);
    if(!sees&&e.boss&&e.kind==='warden'&&(Math.cos(e.face)>=0)===(p.x>=e.x)) sees=canSee(e.x,e.y,Math.atan2(p.y-e.y,p.x-e.x),p.x,p.y,G.vseg,_fSee,e.cone,_aSee);   // v26.xx (overseersight): THE OVERSEER sees what its sprite looks at, the whole side it faces, not only a cone of its heading
'@

SubRx @'
      if(sees){ e.seenYou=true; e.tx=p.x; e.ty=p.y; e.alert=4;
      if(e.boss&&e.lairX!==undefined&&Math.hypot(p.x-e.lairX,p.y-e.lairY)>1100){ e.tx=e.lairX; e.ty=e.lairY; e.seenYou=true; }
'@ @'
      var _bhold=false;   // v26.xx (overseersight): true when THE OVERSEER sees you past its leash inside its reach and holds its ground to shoot
      if(sees){ e.seenYou=true; e.tx=p.x; e.ty=p.y; e.alert=4;
      if(e.boss&&e.lairX!==undefined&&Math.hypot(p.x-e.lairX,p.y-e.lairY)>1100){ e.tx=e.lairX; e.ty=e.lairY; e.seenYou=true; _bhold=(!p.downed&&dist(e,p)<e.rng&&Math.hypot(e.x-e.lairX,e.y-e.lairY)<=1100); }
'@

SubRx @'
navSeek(e,e.tx,e.ty,e.spd,dt); wantW=Math.atan2(e.ty-e.y,e.tx-e.x);
'@ @'
if(_bhold){ wantW=Math.atan2(p.y-e.y,p.x-e.x); e.tx=e.x; e.ty=e.y; }   // v26.xx (overseersight): past its leash but inside its reach it holds, faces you and fires; it does not walk after you
else { navSeek(e,e.tx,e.ty,e.spd,dt); wantW=Math.atan2(e.ty-e.y,e.tx-e.x); }
'@

SubRx @'
var VER='26.18';
'@ @'
var VER='26.19';
'@

$pat = "(?m)^  now:'v26\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.19: THE OVERSEER now sees and shoots from 87 meters instead of 62, and it fires at you from its ground even past its lair, so when it looks at you it is dangerous. Check 26.19 fails on v26.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
