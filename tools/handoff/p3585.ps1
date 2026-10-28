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

# ELITE LONGSHOT GLINT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function updateEnts(dt){
'@ @'
// v28.xx (cw-cx-longshotglint), his 10-28 yes to #5: half a second of warning before an elite Longshot fires at a player.
const GLINT_T=0.5;
function longshotGlintBot(e){ return !!(e&&e.kind==='raider'&&e.elite&&!e.merc&&!e.friendlyPC&&e.wep&&gunBase(e.wep.id)==='sniper'); }
function updateEnts(dt){
'@

SubRx @'
    if(e.pHitT>0) e.pHitT-=dt;   // v11.37: a hit the PLAYER landed, its own timer
'@ @'
    if(e.pHitT>0) e.pHitT-=dt;   // v11.37: a hit the PLAYER landed, its own timer
    // v28.xx (cw-cx-longshotglint): tick once even when cover, a stun or a different state skips the firing block. An expired tell is spent this frame.
    var _glintDone=false;
    if(e.glint>0){
      if(!longshotGlintBot(e)||e.hp<=0||e.downed||e.finished||(e.state!=='chase'&&e.state!=='extract')) e.glint=0;
      else { e.glint=Math.max(0,e.glint-dt); if(e.glint<1e-7){ e.glint=0; _glintDone=true; } }
    }
'@

SubRx @'
        if(e.cd<=0&&(sees||_rtf)&&d<e.rng&&(_rtf||e.acqT>=(CFG.raiderReact===undefined?0.34:CFG.raiderReact))){
// A planted man aims. Measured off actual displacement rather than a
          // state flag, so it cannot disagree with what he did: half a unit of
          // movement in a frame counts as moving. 0.55 seconds of stillness is
          // the setup time, which is roughly the beat his own right mouse takes
          // to matter. Earshot gated like the roll, because parity is for the
          // fights he can see. The two rnd draws are unchanged in COUNT and only
          // their magnitude moves, so the seeded stream is untouched and every
          // historical number stays reproducible.
if(raiderThrow(e,p,d,dt)){ e.cd=1.2; }
          else {
            // v8.11, his note that fighting them got too hard: a HUMAN misses by
            // an angle, not by a fixed number of units. 8 and 16 were the whole
            // error at any range, which made a planted pillager at 500 units
            // more accurate than anything holding a mouse could be. The old
            // numbers are now the FLOOR, so a brawl plays exactly as it did,
            // and the error opens with distance and with a target that is
            // moving - the two things that actually beat a real player's aim.
            var _rk=(CFG.raiderAim===undefined?1:CFG.raiderAim);
            var _rmv=(p.moving?((p.net?p.sp:G.sprinting)?0.030:0.018):0);   // v15.80: the sprint of whichever player he aims at
            var _rjit=Math.max(e.steady?8:16,
                               d*_rk*((e.steady?0.038:0.062)+_rmv))*(e.pinT>0?2.5:1);   // v26.xx (ai22): a pinned man shoots wild
            fireWeapon(e,e.wep,p.x+rnd(-_rjit,_rjit),p.y+rnd(-_rjit,_rjit),false);
            e.cd=(e.wep.rof/1000)*rnd(1.7,2.9);
          }
        }
'@ @'
        if(e.cd<=0&&(sees||_rtf)&&d<e.rng&&(_glintDone||_rtf||e.acqT>=(CFG.raiderReact===undefined?0.34:CFG.raiderReact))){
// A planted man aims. Measured off actual displacement rather than a
          // state flag, so it cannot disagree with what he did: half a unit of
          // movement in a frame counts as moving. 0.55 seconds of stillness is
          // the setup time, which is roughly the beat his own right mouse takes
          // to matter. Earshot gated like the roll, because parity is for the
          // fights he can see. The two rnd draws are unchanged in COUNT and only
          // their magnitude moves, so the seeded stream is untouched and every
          // historical number stays reproducible.
// v28.xx (cw-cx-longshotglint): throws get first refusal only before the tell; the warning never rolls aim or cooldown dice.
if(longshotGlintBot(e)&&e.glint>0){ /* v28.xx (cw-cx-longshotglint): hold the shot */ }
          else if(!_glintDone&&raiderThrow(e,p,d,dt)){ e.cd=1.2; }
          else if(longshotGlintBot(e)&&!_glintDone){
            e.glint=GLINT_T; if(!G.sim) sfx('charge',e.x,e.y);
          }
          else {
            // v8.11, his note that fighting them got too hard: a HUMAN misses by
            // an angle, not by a fixed number of units. 8 and 16 were the whole
            // error at any range, which made a planted pillager at 500 units
            // more accurate than anything holding a mouse could be. The old
            // numbers are now the FLOOR, so a brawl plays exactly as it did,
            // and the error opens with distance and with a target that is
            // moving - the two things that actually beat a real player's aim.
            var _rk=(CFG.raiderAim===undefined?1:CFG.raiderAim);
            var _rmv=(p.moving?((p.net?p.sp:G.sprinting)?0.030:0.018):0);   // v15.80: the sprint of whichever player he aims at
            var _rjit=Math.max(e.steady?8:16,
                               d*_rk*((e.steady?0.038:0.062)+_rmv))*(e.pinT>0?2.5:1);   // v26.xx (ai22): a pinned man shoots wild
            fireWeapon(e,e.wep,p.x+rnd(-_rjit,_rjit),p.y+rnd(-_rjit,_rjit),false);
            e.cd=(e.wep.rof/1000)*rnd(1.7,2.9)-(longshotGlintBot(e)?GLINT_T:0);
          }
        }
'@

SubRx @'
        if(_rSee&&e.cd<=0&&e.acqT>=(CFG.raiderReact===undefined?0.34:CFG.raiderReact)){
          var _rgk=(CFG.raiderAim===undefined?1:CFG.raiderAim);
          var _rgd=dist(e,p);
          var _rgj=Math.max(18,_rgd*_rgk*(0.062+(p.moving?((p.net?p.sp:G.sprinting)?0.030:0.018):0)));   // v15.80: the sprint of whichever player he aims at
          fireWeapon(e,e.wep,p.x+rnd(-_rgj,_rgj),p.y+rnd(-_rgj,_rgj),false);
          e.cd=(e.wep.rof/1000)*rnd(1.9,3.1);
          e.face=Math.atan2(p.y-e.y,p.x-e.x);
        }
'@ @'
        // v28.xx (cw-cx-longshotglint): the same warning at the ring; this second player-facing firing path cannot bypass it.
        if(_rSee&&e.cd<=0&&(_glintDone||e.acqT>=(CFG.raiderReact===undefined?0.34:CFG.raiderReact))){
          if(longshotGlintBot(e)&&!_glintDone){
            if(!(e.glint>0)){ e.glint=GLINT_T; e.face=Math.atan2(p.y-e.y,p.x-e.x); if(!G.sim) sfx('charge',e.x,e.y); }
          } else {
            var _rgk=(CFG.raiderAim===undefined?1:CFG.raiderAim);
            var _rgd=dist(e,p);
            var _rgj=Math.max(18,_rgd*_rgk*(0.062+(p.moving?((p.net?p.sp:G.sprinting)?0.030:0.018):0)));
            fireWeapon(e,e.wep,p.x+rnd(-_rgj,_rgj),p.y+rnd(-_rgj,_rgj),false);
            e.cd=(e.wep.rof/1000)*rnd(1.9,3.1)-(longshotGlintBot(e)?GLINT_T:0);
            e.face=Math.atan2(p.y-e.y,p.x-e.x);
          }
        }
'@

SubRx @'
function telegraphLane(e){
'@ @'
// v28.xx (cw-cx-longshotglint): a muzzle star over the fog, including a hidden body, only on a clear line to this window. No aim-lane switch or random draws.
function drawLongshotGlints(){
  var p=G.player,e,m,f,r,i,n=0;
  if(!p) return 0;
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!(e.glint>0)||!longshotGlintBot(e)||!(e.hp>0)||e.downed||e.finished) continue;
    if(!losClear(e.x,e.y,p.x,p.y,G.vseg)) continue;
    m=gunMuzzleAt(e,e.wep,e.face); if(!m) continue;
    f=clamp(1-e.glint/GLINT_T,0,1); r=(8+14*f)*(e.glint<=0.05?1.3:1);
    wc.save(); wc.translate(m.x,m.y); wc.globalCompositeOperation='source-over'; wc.globalAlpha=.7+.3*f;
    wc.beginPath(); wc.moveTo(0,-r); wc.lineTo(r*.2,-r*.2); wc.lineTo(r,0); wc.lineTo(r*.2,r*.2);
    wc.lineTo(0,r); wc.lineTo(-r*.2,r*.2); wc.lineTo(-r,0); wc.lineTo(-r*.2,-r*.2); wc.closePath();
    wc.strokeStyle='#11151b'; wc.lineWidth=3; wc.stroke(); wc.fillStyle='#ffffff'; wc.fill();
    wc.fillStyle='#ff3b30'; wc.beginPath(); wc.arc(0,0,2.5+1.5*f,0,Math.PI*2); wc.fill(); wc.restore(); n++;
  }
  return n;
}
function telegraphLane(e){
'@

SubRx @'
  var _wtA=function(){
'@ @'
  var _wtA=function(){
  drawLongshotGlints();   // v28.xx (cw-cx-longshotglint): over the darkness and fog, apart from the visible-body list
'@

SubRx @'
(e.burnT>0?1:0)|((e.downed&&e.getUp>0)?2:0)
'@ @'
(e.burnT>0?1:0)|((e.downed&&e.getUp>0)?2:0)|((e.glint>0)?4:0)
'@

SubRx @'
  e.seenYou=!!(f&256);
'@ @'
  e.seenYou=!!(f&256);
  // v28.xx (cw-cx-longshotglint): ninth-field bit 4 is the tell. Rising edges start it once; repeated snapshots keep its phase and do not repeat the sound.
  if(typeof bx==='number'&&(bx&4)){
    if(!e.glintNet){ e.glint=GLINT_T; if(!G.sim) sfx('charge',e.x,e.y); }
    e.glintNet=1;
  } else { e.glintNet=0; e.glint=0; }
'@

SubRx @'
    if(e.roll>0) e.roll=Math.max(0,e.roll-dt);
'@ @'
    if(e.roll>0) e.roll=Math.max(0,e.roll-dt);
    if(e.glintNet&&e.glint>0) e.glint=Math.max(0.001,e.glint-dt);   // v28.xx (cw-cx-longshotglint): linked-window animation, held on its final flash until the host clears bit 4
'@

SubRx @'
var VER='35.84';
'@ @'
var VER='35.85';
'@

$pat = "(?m)^  now:'v35\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.85: Elite Longshot shots have a half-second muzzle glint in both windows. Check 35.85 fails on v35.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
