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

# RICHER ANIMATION: HIT JOLTS AND DEATHS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawWardenS(e){
'@ @'
// v17.47, HIS PICK 29 (2026-09-30): RICHER ANIMATION, drawn only (nothing a fight reads moves). A HIT JOLT: while its hit
// flash runs (hitT), a body is drawn pushed a few pixels away from the player who hit it, easing back as the flash fades. A
// DEATH ANIMATION: a body that dies leaves a silhouette in its colour that turns, flattens and fades over 0.8 seconds where it
// fell, beside the puff and the decal it always left; a linked window plays it from the death word (netEntDeathFx).
var DEATH_COL={warden:'#6a5a3a',choir:'#5a4a3a',sentry:'#56606c',crawler:'#46525c',raider:'#7a5446',snitch:'#6a6040',howler:'#5a4a52',bulwark:'#4c5460',listener:'#4a4a58',stray:'#6a5a4a'};
function animHitShift(e){
  var p, dx, dy, d, a;
  if(!e||!(e.hitT>0)||typeof G==='undefined'||!G||!G.player) return null;
  p=G.player; dx=e.x-p.x; dy=e.y-p.y; d=Math.hypot(dx,dy);
  if(!(d>0.5)) return null;
  a=5*Math.max(0,Math.min(1,e.hitT/0.16));
  return {x:dx/d*a,y:dy/d*a};
}
function deathAnimAdd(e){
  if(!e||typeof G==='undefined'||!G||G.sim) return 0;
  if(!G.deathAnims) G.deathAnims=[];
  if(G.deathAnims.length>40) G.deathAnims.shift();
  G.deathAnims.push({x:e.x,y:e.y,r:Math.max(8,Math.min(48,e.r||14)),face:+e.face||0,c:DEATH_COL[e.kind]||'#555c64',t0:G.t||0});
  return G.deathAnims.length;
}
function drawDeathAnims(){
  var i, a, f, k;
  if(typeof G==='undefined'||!G||!G.deathAnims||!G.deathAnims.length) return 0;
  for(i=G.deathAnims.length-1;i>=0;i--){
    a=G.deathAnims[i]; f=((G.t||0)-a.t0)/0.8;
    if(!(f>=0&&f<1)){ G.deathAnims.splice(i,1); continue; }
    k=1-f;
    wc.save(); wc.globalAlpha=0.85*k; wc.translate(a.x,a.y); wc.rotate(a.face+f*1.4); wc.scale(1-0.35*f,0.55+0.45*k);
    wc.fillStyle=a.c; wc.beginPath(); wc.ellipse(0,0,a.r,a.r*0.8,0,0,6.2832); wc.fill();
    wc.strokeStyle='rgba(0,0,0,'+(0.5*k).toFixed(3)+')'; wc.lineWidth=2; wc.stroke();
    wc.restore();
  }
  return G.deathAnims.length;
}function drawWardenS(e){
'@

SubRx @'
      if(eLift>0){ wc.save(); _svd++; wc.translate(0,-eLift); }
'@ @'
      if(eLift>0){ wc.save(); _svd++; wc.translate(0,-eLift); }
      var _kb=animHitShift(e2); if(_kb){ wc.save(); _svd++; wc.translate(_kb.x,_kb.y); }   // v17.47: his pick 29, the hit jolt
'@

SubRx @'
      if(eLift>0) wc.restore();
'@ @'
      if(_kb){ wc.restore(); _svd--; }
      if(eLift>0) wc.restore();
'@

SubRx @'
  for(i=0;i<G.puffs.length;i++){
'@ @'
  try{ drawDeathAnims(); }catch(_dda){}   // v17.47: his pick 29
  for(i=0;i<G.puffs.length;i++){
'@

SubRx @'
      if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
'@ @'
      deathAnimAdd(e);   // v17.47: his pick 29, the death animation
      if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
'@

SubRx @'
        if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:'#d8a13a',r:26});
'@ @'
        deathAnimAdd(e);   // v17.47: his pick 29
        if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:'#d8a13a',r:26});
'@

SubRx @'
function netEntDeathFx(e){
'@ @'
function netEntDeathFx(e){
  try{ deathAnimAdd(e); }catch(_dz){}   // v17.47: his pick 29, the death animation in a linked window
'@

SubRx @'
var VER='17.46';
'@ @'
var VER='17.47';
'@

$pat = "(?m)^  now:'v17\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.47: RICHER ANIMATION, his pick from the feature list: a hit jolts a body a few pixels away from the player who hit it while its flash runs, and a body that dies turns, flattens and fades over 0.8 seconds where it fell, in both windows of a party. Drawing only; nothing a fight reads moves. Check 17.47 fails on v17.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
