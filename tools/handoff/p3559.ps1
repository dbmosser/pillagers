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

# HIT JOLT FOLLOWS THE ROUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function animHitShift(e){
  var p, dx, dy, d, a;
  if(!e||!(e.hitT>0)||typeof G==='undefined'||!G||!G.player) return null;
  p=G.player; dx=e.x-p.x; dy=e.y-p.y; d=Math.hypot(dx,dy);
  if(!(d>0.5)) return null;
  a=(HIT_JOLT[e.kind]||5)*Math.max(0,Math.min(1,e.hitT/0.16));
  return {x:dx/d*a,y:dy/d*a};
}
'@ @'
// v28.xx (cw-cx-hitjolt): record the incoming bearing for drawing only; no hit, damage, movement or random draw changes.
function animHitFrom(e,dx,dy){
  if(!e) return;
  e.hitJoltA=(typeof dx==='number'&&typeof dy==='number'&&isFinite(dx)&&isFinite(dy)&&Math.hypot(dx,dy)>0.0001)?Math.atan2(dy,dx):null;
  e.hitJoltUntil=((typeof G!=='undefined'&&G&&G.t)||0)+0.16;
}
// v28.xx (cw-cx-hitjolt): a bearing belongs only to this flash, never a later unrelated hit.
function animHitAngle(e){
  return (e&&e.hitT>0&&typeof e.hitJoltA==='number'&&isFinite(e.hitJoltA)&&e.hitJoltUntil>=((typeof G!=='undefined'&&G&&G.t)||0))?e.hitJoltA:null;
}
function animHitShift(e){
  var p, dx, dy, d, a, ha;
  if(!e||!(e.hitT>0)||typeof G==='undefined'||!G||!G.player) return null;
  ha=animHitAngle(e);
  if(ha!==null){ dx=Math.cos(ha); dy=Math.sin(ha); d=1; }
  else { p=G.player; dx=e.x-p.x; dy=e.y-p.y; d=Math.hypot(dx,dy); }
  if(!(d>0.5)) return null;
  a=(HIT_JOLT[e.kind]||5)*Math.max(0,Math.min(1,e.hitT/0.16));
  return {x:dx/d*a,y:dy/d*a};
}
'@

SubRx @'
              en.hitT=.16; hitStopOn(en,b.dmg);   // v26.xx (feel10): a heavy round stops the body for a beat
'@ @'
              en.hitT=.16; animHitFrom(en,b.vx,b.vy); hitStopOn(en,b.dmg);   // v26.xx (feel10): a heavy round stops the body for a beat // v28.xx (cw-cx-hitjolt): the incoming round, including the linked shooter prediction
'@

SubRx @'
              en3.hp-=b.dmg; en3.hitT=.16;
'@ @'
              en3.hp-=b.dmg; en3.hitT=.16; animHitFrom(en3,b.vx,b.vy); // v28.xx (cw-cx-hitjolt): bot and hired companion rounds use their own bearing too
'@

SubRx @'
  e.hp-=(m.sk?affixSoak(e,d):d); e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,m.hs===1?HITSTOP_DMG:0); /*v28.xx (cw-nearmiss), CLOUD HUNT 2026-10-15: no suppHit here: a gun round already counted by its sup word as it reached him, and the host own frag, fists, finisher, air strike and screen clear never pin*/ /*v28.xx (cw-hitstoprule), CLOUD HUNT 2026-10-15: hit stop by the host rule, not by the multiplied number*/   // v26.xx (ai22): and player 2's rounds that land pin him as yours do   // v17.31, co-op hunt 2026-09-28: and whose round it was, so a man who made peace turned by it charges that seat   // v28.xx (cw-blastshield), CLOUD HUNT 2026-10-15: only a round soaks on the shield (v26.72), as on the host
'@ @'
  e.hp-=(m.sk?affixSoak(e,d):d); e.hitT=.16; e.pHitT=.3; e.pHitSeat=s; hitStopOn(e,m.hs===1?HITSTOP_DMG:0); /*v28.xx (cw-nearmiss), CLOUD HUNT 2026-10-15: no suppHit here: a gun round already counted by its sup word as it reached him, and the host own frag, fists, finisher, air strike and screen clear never pin*/ /*v28.xx (cw-hitstoprule), CLOUD HUNT 2026-10-15: hit stop by the host rule, not by the multiplied number*/   // v26.xx (ai22): and player 2's rounds that land pin him as yours do   // v17.31, co-op hunt 2026-09-28: and whose round it was, so a man who made peace turned by it charges that seat   // v28.xx (cw-blastshield), CLOUD HUNT 2026-10-15: only a round soaks on the shield (v26.72), as on the host
  // v28.xx (cw-cx-hitjolt): the partner shot already carries its bearing; older blow words can use the shooter position.
  if(m.sk&&typeof m.a==='number'&&isFinite(m.a)) animHitFrom(e,Math.cos(m.a),Math.sin(m.a));
  else animHitFrom(e,e.x-sx,e.y-sy);
'@

SubRx @'
  return [e.nid,(k<0)?0:k,Math.round(e.x),Math.round(e.y),+(+e.face||0).toFixed(2),(s<0)?0:s,Math.ceil(clamp(e.hp/mh,0,1)*20),netEntFlags(e),(e.burnT>0?1:0)|((e.downed&&e.getUp>0)?2:0)];  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: bit 8388608 is both burning and getting up, so the row carries the two apart
'@ @'
  return [e.nid,(k<0)?0:k,Math.round(e.x),Math.round(e.y),+(+e.face||0).toFixed(2),(s<0)?0:s,Math.ceil(clamp(e.hp/mh,0,1)*20),netEntFlags(e),(e.burnT>0?1:0)|((e.downed&&e.getUp>0)?2:0),animHitAngle(e)];  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: bit 8388608 is both burning and getting up, so the row carries the two apart // v28.xx (cw-cx-hitjolt): optional tenth column is a cosmetic bearing; zero is valid
'@

SubRx @'
    netEntFlagsApply(e,fl,(typeof r[8]==='number'&&isFinite(r[8]))?(r[8]|0):undefined);  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: the burn and get-up apart
'@ @'
    netEntFlagsApply(e,fl,(typeof r[8]==='number'&&isFinite(r[8]))?(r[8]|0):undefined);  // v28.28 (cloud-coop-getup-vs-burn), CLOUD HUNT 2026-10-15: the burn and get-up apart
    // v28.xx (cw-cx-hitjolt): every viewer takes the host bearing, with old nine-column snapshots still accepted.
    if((fl&64)&&typeof r[9]==='number'&&isFinite(r[9])) animHitFrom(e,Math.cos(r[9]),Math.sin(r[9]));
'@

SubRx @'
var VER='35.58';
'@ @'
var VER='35.59';
'@

$pat = "(?m)^  now:'v35\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.59: Hit jolts follow the incoming round in both windows. Check 35.59 fails on v35.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
