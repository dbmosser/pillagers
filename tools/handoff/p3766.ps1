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

# LOOSE FLOOR DEBRIS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxBlastScar(x,y,size,onRoof){
'@ @'
// v28.xx (cw-cx-floorbits): his pick 79, light papers, boxes and bolts scatter and stay for the raid. Draw only; no stream, sound or collision.
var FLOORBIT_CAP=240, FLOORBIT_ATLAS=null;
function floorBitHash(n){ n=Math.imul(n^(n>>>16),0x45d9f3b); n=Math.imul(n^(n>>>16),0x45d9f3b); return ((n^(n>>>16))>>>0)/4294967296; }
function floorBitState(){
  if(!G||G.sim||!G.map) return null;
  if(G.floorBits) return G.floorBits;
  var s=G.floorBits={list:[],track:{},sample:0,frame:-1,kicks:0}, cs=G.containers||[], i,j,c,x,y,h;
  for(i=0;i<FLOORBIT_CAP*4&&s.list.length<FLOORBIT_CAP;i++){
    h=(G.seed|0)^Math.imul(i+1,7919); c=cs.length?cs[(Math.floor(i/3)*17)%cs.length]:null;
    x=c?c.x+(floorBitHash(h)-.5)*112:40+floorBitHash(h)*(WORLD_W-80);
    y=c?c.y+(floorBitHash(h+13)-.5)*112:40+floorBitHash(h+13)*(WORLD_H-80);
    if(x<16||y<16||x>WORLD_W-16||y>WORLD_H-16||!spotFree(G.map,x,y,8)||inWaterMap(G.map,x,y)) continue;
    j=s.list.length;
    s.list.push({x:x,y:y,vx:0,vy:0,a:floorBitHash(h+29)*6.283185,k:j%3});
  }
  return s;
}
function floorBitKick(x,y,r,power){
  if(!isFinite(x)||!isFinite(y)||!(r>0)) return 0;
  var s=floorBitState(),i,b,dx,dy,d,q,n=0;
  if(!s) return 0;
  if(s.frame!==G.frameN){ s.frame=G.frameN; s.kicks=0; }
  if(s.kicks>=12) return 0;
  s.kicks++;
  for(i=0;i<s.list.length;i++){
    b=s.list[i]; dx=b.x-x; dy=b.y-y;
    if(Math.abs(dx)>=r||Math.abs(dy)>=r) continue;
    d=Math.sqrt(dx*dx+dy*dy); if(d>=r) continue;
    if(d<.01){ dx=Math.cos(b.a); dy=Math.sin(b.a); d=1; }
    q=power*(1-d/r)*(b.k===0?1:(b.k===1?.62:.84));
    b.vx=Math.max(-500,Math.min(500,b.vx+dx/d*q)); b.vy=Math.max(-500,Math.min(500,b.vy+dy/d*q)); n++;
  }
  return n;
}
function floorBitBody(b,id,elapsed,sprint){
  var s=G.floorBits, old=s.track[id],dx,dy,d;
  if(!b||!isFinite(b.x)||!isFinite(b.y)) return;
  s.track[id]={x:b.x,y:b.y};
  if(!old||b.downed||b.dn||b.hp<=0||Math.abs(b.x-G.player.x)>1100||Math.abs(b.y-G.player.y)>800) return;
  dx=b.x-old.x; dy=b.y-old.y; d=Math.sqrt(dx*dx+dy*dy);
  if(d>1&&d<750*elapsed&&(sprint||d/elapsed>220)) floorBitKick(b.x,b.y,62,105);
}
function floorBitStep(dt){
  var s=floorBitState(),i,b,decay,step,elapsed,m;
  if(!s) return;
  dt=Math.max(0,Math.min(.1,+dt||0)); decay=Math.exp(-5*dt); step=(1-decay)/5;
  for(i=0;i<s.list.length;i++){
    b=s.list[i]; if(!b.vx&&!b.vy) continue;
    b.x=Math.max(10,Math.min(WORLD_W-10,b.x+b.vx*step)); b.y=Math.max(10,Math.min(WORLD_H-10,b.y+b.vy*step));
    b.a+=(b.vx+b.vy)*dt*(b.k===0?.035:.012); b.vx*=decay; b.vy*=decay;
    if(b.vx*b.vx+b.vy*b.vy<9){ b.vx=0; b.vy=0; }
  }
  s.sample+=dt;
  if(s.sample<.08) return;
  elapsed=s.sample; s.sample=0;
  floorBitBody(G.player,'p',elapsed,!!G.sprinting);
  m=typeof netMates==='function'?netMates():[];
  for(i=0;i<m.length;i++) floorBitBody(m[i],'n'+m[i].seat,elapsed,false);
  for(i=0;i<G.ents.length;i++) floorBitBody(G.ents[i],'e'+i,elapsed,false);
}
function floorBitAtlas(){
  if(FLOORBIT_ATLAS) return FLOORBIT_ATLAS;
  var a=document.createElement('canvas'),c,i,k;
  a.width=1152; a.height=24; c=a.getContext('2d');
  for(k=0;k<3;k++) for(i=0;i<16;i++){
    c.save(); c.translate((k*16+i)*24+12,12); c.rotate(i*Math.PI/8);
    c.fillStyle='rgba(0,0,0,.24)'; c.fillRect(-5,-2,11,7);
    if(k===0){
      c.fillStyle='#bdb4a0'; c.beginPath(); c.moveTo(-6,-4); c.lineTo(4,-5); c.lineTo(6,3); c.lineTo(-5,5); c.closePath(); c.fill();
      c.fillStyle='#ded5be'; c.beginPath(); c.moveTo(1,-4); c.lineTo(4,-5); c.lineTo(5,-1); c.closePath(); c.fill();
      c.fillStyle='#827e73'; c.fillRect(-3,-1,5,1); c.fillRect(-3,1,3,1);
    }else if(k===1){
      c.fillStyle='#67503a'; c.fillRect(-5,-4,10,9); c.fillStyle='#967958'; c.fillRect(-5,-5,9,7);
      c.fillStyle='#b29a75'; c.fillRect(-1,-5,2,7); c.fillStyle='#4d4032'; c.fillRect(4,-4,2,8);
    }else{
      c.fillStyle='#666f73'; c.fillRect(-1,-4,3,8); c.fillStyle='#a5adb0'; c.fillRect(-1,-4,1,7);
      c.fillStyle='#8e989b'; c.fillRect(-3,-5,6,3); c.fillStyle='#40494d'; c.fillRect(-1,-4,2,1);
    }
    c.restore();
  }
  FLOORBIT_ATLAS=a; return a;
}
function floorBitDraw(c,ox,oy,vw,vh){
  var s=floorBitState(),a,i,b,frame,n=0;
  if(!s) return 0;
  a=floorBitAtlas();
  for(i=0;i<s.list.length;i++){
    b=s.list[i]; if(b.x<ox-12||b.y<oy-12||b.x>ox+vw+12||b.y>oy+vh+12) continue;
    frame=((Math.round(b.a*8/Math.PI)%16)+16)%16;
    c.drawImage(a,(b.k*16+frame)*24,0,24,24,b.x-12,b.y-12,24,24); n++;
  }
  return n;
}
function gfxBlastScar(x,y,size,onRoof){
'@

SubRx @'
  if(onRoof||G.sim||!G.ground) return 0;
'@ @'
  if(onRoof||G.sim||!G.ground) return 0;
  floorBitKick(x,y,190*k,360); // v28.xx (cw-cx-floorbits): floor-level blast, including remote copies.
'@

SubRx @'
  brlTick(dt);   // v27.xx (barrels): the lit explosive barrels (nothing to do with none lit, and the bot raid has none)
'@ @'
  floorBitStep(dt); // v28.xx (cw-cx-floorbits): cosmetic movement, frozen with the raid.
  brlTick(dt);   // v27.xx (barrels): the lit explosive barrels (nothing to do with none lit, and the bot raid has none)
'@

SubRx @'
  // shimmer, drawn over the baked floor but under everything else
'@ @'
  floorBitDraw(wc,ox,oy,VW,VH); // v28.xx (cw-cx-floorbits): below bodies, props, fog and lighting.
  // shimmer, drawn over the baked floor but under everything else
'@

SubRx @'
function wallImpactFx(w,x,y,ux,uy){
'@ @'
function wallImpactFx(w,x,y,ux,uy){
  if(G&&!G.sim) floorBitKick(x,y,76,135); // v28.xx (cw-cx-floorbits): penetrating and bouncing rounds too.
'@

SubRx @'
    if(hit||b.life<=0){ if(b.rkt&&b.player) rocketBlast(b); G.bullets.splice(i,1); }   // v28.xx (cw-rocket): a rocket goes off where it ends, on a body, a wall or the end of its range
'@ @'
  if(hit&&!G.sim) floorBitKick(b.x,b.y,76,135); // v28.xx (cw-cx-floorbits): a round striking a body or prop.
    if(hit||b.life<=0){ if(b.rkt&&b.player) rocketBlast(b); G.bullets.splice(i,1); }   // v28.xx (cw-rocket): a rocket goes off where it ends, on a body, a wall or the end of its range
'@

SubRx @'
  if(!gfxHook('shot')||!sh) return false;
'@ @'
  if(!gfxHook('shot')||!sh) return false;
  floorBitKick(sh.x,sh.y,48,70); // v28.xx (cw-cx-floorbits): muzzle wash, no gameplay force.
'@

SubRx @'
  if(GFX.bypass||!G||G.sim||!isFinite(x)||!isFinite(y)||!isFinite(ang)) return false;
'@ @'
  if(GFX.bypass||!G||G.sim||!isFinite(x)||!isFinite(y)||!isFinite(ang)) return false;
  floorBitKick(x,y,48,70); // v28.xx (cw-cx-floorbits): the teammate shot in this window.
'@

SubRx @'
var VER='37.65';
'@ @'
var VER='37.66';
'@

$pat = "(?m)^  now:'v37\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.66: Light floor clutter reacts to movement and combat. LOCAL: no linked review. Each window animates its own cosmetic scraps from existing body and effect copies; no packets or shared gameplay fields change. Check 37.66 fails on v37.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
