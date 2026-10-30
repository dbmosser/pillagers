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

# MACHINE TELLS AND OPEN BEATS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WARDEN_ARC=1.0, WARDEN_SOAK=0.4;
'@ @'
// v28.xx (cw-cx-machineopen): his g-29, a short open beat after the cannon and every fourth bulwark shot.
var WARDEN_ARC=1.0, WARDEN_SOAK=0.4;
var WARDEN_OPEN=0.9, BULWARK_OPEN=1.0, BULWARK_SHOT_N=4;
'@

SubRx @'
    var _se=G.ents[_sq];
'@ @'
    var _se=G.ents[_sq];
    // v28.xx (cw-cx-machineopen): one countdown per host tick, including stopped machines.
    if(_se.openT>0) _se.openT=Math.max(0,_se.openT-dt);
'@

SubRx @'
              fireWeapon(e,{dmg:e.dmg,spread:.05,rng:e.rng,noise:520,tint:'#ffc04a'},p.x+rnd(-8,8),p.y+rnd(-8,8),false);
'@ @'
              fireWeapon(e,{dmg:e.dmg,spread:.05,rng:e.rng,noise:520,tint:'#ffc04a'},p.x+rnd(-8,8),p.y+rnd(-8,8),false);
              if(!e.boss) e.openT=WARDEN_OPEN; // v28.xx (cw-cx-machineopen): the Overseer keeps its own vent cycle.
'@

SubRx @'
              fireWeapon(e,{dmg:e.dmg,spread:.10,rng:e.rng,noise:340,tint:'#ff9a6a'},p.x+rnd(-16,16),p.y+rnd(-16,16),false);
'@ @'
              // v28.xx (cw-cx-machineopen): no extra seeded draws; aim scatter and cooldown retain their order.
              fireWeapon(e,{dmg:e.dmg*(e.kind==='bulwark'&&e.bigW?2.5:1),spread:.10,rng:e.rng,noise:340,tint:'#ff9a6a'},p.x+rnd(-16,16),p.y+rnd(-16,16),false);
              if(e.kind==='bulwark'){ e.shotN=(e.shotN||0)+1; if(e.bigW) e.openT=BULWARK_OPEN; }
'@

SubRx @'
            e.cd=rnd(0,.35);
'@ @'
            e.bigW=0;
            e.cd=rnd(0,.35);
'@

SubRx @'
          e.windup=0.4;
'@ @'
          // v28.xx (cw-cx-machineopen): a longer tell precedes every fourth actual bulwark shot.
          e.bigW=(e.kind==='bulwark'&&((e.shotN||0)+1)%BULWARK_SHOT_N===0)?1:0;
          e.windup=e.bigW?0.7:0.4;
'@

SubRx @'
} else if((en.kind==='bulwark'||(xf('xfWarden')&&en.kind==='warden'&&!en.boss))&&(function(){
'@ @'
} else if(!(en.openT>0)&&(en.kind==='bulwark'||(xf('xfWarden')&&en.kind==='warden'&&!en.boss))&&(function(){
'@

SubRx @'
  if(e.kind==='sentry') tot=0.4; else if(e.kind==='warden') tot=0.7; else return null;
'@ @'
  if(e.kind==='sentry') tot=0.4; else if(e.kind==='warden') tot=0.7; else if(e.kind==='bulwark'&&e.bigW) tot=0.7; else return null;
'@

SubRx @'
w:(e.kind==='warden')?(e.boss?12:8):4
'@ @'
w:(e.kind==='warden')?(e.boss?12:8):(e.kind==='bulwark'?8:4)
'@

SubRx @'
function telegraphLane(e){
'@ @'
// v28.xx (cw-cx-machineopen): his g-20, only a local warning at the feet, never the hidden machine location.
function unseenTell(e,p){
  if(!xf('xfTell')||!e||!(e.hp>0)||e.seen||!(e.windup>0)||!p||p.downed||p.finished||!(p.hp>0)) return null;
  var tot=e.kind==='warden'?0.7:(e.kind==='sentry'?0.4:(e.kind==='bulwark'?(e.bigW?0.7:0.4):0));
  if(!tot||!(dist(e,p)<e.rng*1.2)||(NET.on&&netTargetFor(e)!==p)) return null;
  var dx=e.x-p.x,dy=e.y-p.y,d=Math.sqrt(dx*dx+dy*dy);
  if(!(d>0)) return null;
  dx/=d; dy/=d;
  return {x1:p.x+dx*14,y1:p.y+dy*14,x2:p.x+dx*78,y2:p.y+dy*78,f:clamp(1-e.windup/tot,0,1)};
}
function drawUnseenTells(p){
  var n=0;
  for(var i=0;i<G.ents.length;i++){
    var t=unseenTell(G.ents[i],p); if(!t) continue;
    var dx=(t.x2-t.x1)/64,dy=(t.y2-t.y1)/64,w=2+3*t.f;
    wc.save(); wc.globalCompositeOperation='source-over'; wc.globalAlpha=0.3+0.6*t.f;
    wc.fillStyle=wc.strokeStyle='rgb(255,36,28)'; wc.lineWidth=w;
    wc.beginPath(); wc.moveTo(t.x1-dy*w/2,t.y1+dx*w/2); wc.lineTo(t.x2,t.y2); wc.lineTo(t.x1+dy*w/2,t.y1-dx*w/2); wc.closePath(); wc.fill();
    wc.lineWidth=0.5; wc.beginPath(); wc.moveTo(t.x1,t.y1); wc.lineTo(t.x2,t.y2); wc.stroke(); wc.restore(); n++;
  }
  return n;
}
function telegraphLane(e){
'@

SubRx @'
e.windup/(e.kind==='warden'?0.7:0.4)
'@ @'
e.windup/((e.kind==='warden'||(e.kind==='bulwark'&&e.bigW))?0.7:0.4)
'@

SubRx @'
  // v26.xx (ai24): the Overseer sweeping laser, a wide red beam on the ground from the machine to the first wall.
'@ @'
  // v28.xx (cw-cx-machineopen): hidden-machine streaks share the ground pass, after visible aim lanes.
  drawUnseenTells(p);
  // v26.xx (ai24): the Overseer sweeping laser, a wide red beam on the ground from the machine to the first wall.
'@

SubRx @'
((e.glint>0)?4:0),animHitAngle(e)
'@ @'
((e.glint>0)?4:0)|((e.openT>0)?8:0)|((e.bigW&&e.windup>0)?16:0),animHitAngle(e)
'@

SubRx @'
  if(f&512){ if(e.windup===undefined||e.windup===null) e.windup=(e.kind==='warden')?0.7:0.4; } else e.windup=null;
'@ @'
  // v28.xx (cw-cx-machineopen): ninth-field bits 8/16, preserving burn, get-up, glint and target-seat bits.
  e.openT=(typeof bx==='number'&&(bx&8))?(e.kind==='warden'?WARDEN_OPEN:BULWARK_OPEN):0;
  e.bigW=(typeof bx==='number'&&(bx&16))?1:0;
  if(f&512){ if(e.windup===undefined||e.windup===null) e.windup=(e.kind==='warden'||e.bigW)?0.7:0.4; } else { e.windup=null; e.bigW=0; }
'@

SubRx @'
  if(PIXM.paint||!MACH_KIND[e.kind]||!pixOn()||
'@ @'
  if(e.openT>0||PIXM.paint||!MACH_KIND[e.kind]||!pixOn()||
'@

SubRx @'
  // BELLY PLATE: oxide, hazard stencils

'@ @'
  // v28.xx (cw-cx-machineopen): parted armour reveals a bright core during the opening.
  if(!B&&e.openT>0){
    wc.fillStyle=P.ink; rrF(-15,-31,23,14,2);
    wc.fillStyle='#ff6b32'; rrF(-8,-28,9,9,2);
    wc.fillStyle='#fff0b0'; wc.fillRect(-5,-26,3,5);
    wc.fillStyle=P.ox[1]; rrF(-18,-30,7,13,2); rrF(4,-30,7,13,2);
    wc.fillStyle=P.och; wc.fillRect(-17,-28,5,2); wc.fillRect(5,-28,5,2);
  } else {
  // BELLY PLATE: oxide, hazard stencils

'@

SubRx @'
  // THE HEAD: set low between the shoulders, a visor slit in the sensor language (the Overseer: a crown of three sensor masts and one big lens)
'@ @'
  }
  // THE HEAD: set low between the shoulders, a visor slit in the sensor language (the Overseer: a crown of three sensor masts and one big lens)
'@

SubRx @'
  wc.save(); wc.translate(x,y-18); wc.rotate(e.face); if(Math.cos(e.face)<-0.01) wc.scale(1,-1);
'@ @'
  // v28.xx (cw-cx-machineopen): lower the slab within the existing 1.5x body transform.
  wc.save(); wc.translate(x,y-18+(e.openT>0?15:0)); wc.rotate(e.face); if(Math.cos(e.face)<-0.01) wc.scale(1,-1); if(e.openT>0) wc.scale(1,0.3);
'@

SubRx @'
var VER='36.64';
'@ @'
var VER='36.65';
'@

$pat = "(?m)^  now:'v36\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.65: Wardens open for 0.9s after firing. Every fourth bulwark shot charges for 0.7s, hits 2.5x, then opens its shield for 1s. Hidden machine windups warn only their target at their feet. Check 36.65 fails on v36.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
