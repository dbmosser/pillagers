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

# MACHINES AND EFFECTS: HIS ART PICKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(G.sim) return;
  if(CFG.fxLevel===0) n=Math.ceil(n/3);
'@ @'
  if(G.sim) return;
  if(col!==BLOOD_SPRAY) n=Math.min(70,Math.ceil(n*1.8));   // v32.xx (cw-machfx) a34 B (his pick): chunkier hit sparks, 1.8 times the count (blood keeps its own count)
  if(CFG.fxLevel===0) n=Math.ceil(n/3);
'@

SubRx @'
    wc.fillStyle=sp.c; wc.fillRect(sp.x-1.2,sp.y-9,2.4,2.4);
'@ @'
    var _sz=sp.z||3.4;   // v32.xx (cw-machfx) a34 B: 3.4 px sparks with a white-yellow core (#ffe9a8); blood and metal chunks have no core
    wc.fillStyle=sp.c; wc.fillRect(sp.x-_sz/2,sp.y-7.8-_sz/2,_sz,_sz);
    if(sp.c!==BLOOD_SPRAY&&!sp.nc){ wc.fillStyle='#ffe9a8'; wc.fillRect(sp.x-0.8,sp.y-8.6,1.6,1.6); }
'@

SubRx @'
  spark(x,y,BLOOD_SPRAY,Math.round(3+4*k),150);
  G.puffs.push({x:x+Math.cos(a)*4,y:y+Math.sin(a)*3,t:0,life:.22,c:BLOOD_MIST,r:5+4*k});
  if(fxr()<0.55){ d=fxn(6,14); decal(x+Math.cos(a)*d,y+16+Math.sin(a)*d*0.5,BLOOD_DROP,fxn(2.2,4)*(0.7+0.5*k)); }
'@ @'
  spark(x,y,BLOOD_SPRAY,5,150);   // v32.xx (cw-machfx) a34 B: five droplets, a puff of radius 7+5k and a 4 px floor drop
  G.puffs.push({x:x+Math.cos(a)*4,y:y+Math.sin(a)*3,t:0,life:.22,c:BLOOD_MIST,r:7+5*k});
  if(fxr()<0.55){ d=fxn(6,14); decal(x+Math.cos(a)*d,y+16+Math.sin(a)*d*0.5,BLOOD_DROP,fxn(3.4,4.6)*(0.7+0.5*k)); }
'@

SubRx @'
function drawWindupGlow(e,gx,gy){
  if(e.windup===undefined||e.windup===null) return;
  var wf=1-e.windup/(e.kind==='warden'?0.7:0.4);
  wc.globalCompositeOperation='lighter';
  wc.fillStyle='#ff3b30';
  wc.globalAlpha=.25+.6*wf;
  wc.beginPath(); wc.arc(gx,gy,3+9*wf,0,6.2832); wc.fill();
  wc.globalAlpha=.18*wf;
  wc.beginPath(); wc.arc(gx,gy,12+22*wf,0,6.2832); wc.fill();
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
}

'@ @'
// v32.xx (cw-machfx) a27 B (his pick): the lens glow is replaced by a CHARGING RING at the muzzle. It shrinks from 26 to 8 px over the windup,
// 3 px #ff3b30 at alpha .4 to .95, and a 6 px white core flashes in the last 3 frames (0.05 s). Drawn only.
function windupRingR(wf){ return 26-18*clamp(wf,0,1); }
function drawWindupGlow(e,gx,gy){
  if(e.windup===undefined||e.windup===null) return;
  var wf=clamp(1-e.windup/(e.kind==='warden'?0.7:0.4),0,1);
  wc.save();
  wc.globalCompositeOperation='source-over';
  wc.strokeStyle='#ff3b30'; wc.globalAlpha=.4+.55*wf; wc.lineWidth=3;
  wc.beginPath(); wc.arc(gx,gy,windupRingR(wf),0,6.2832); wc.stroke();
  if(e.windup<=0.05){ wc.globalAlpha=1; wc.fillStyle='#ffffff'; wc.beginPath(); wc.arc(gx,gy,3,0,6.2832); wc.fill(); }
  wc.restore();
}
// v32.xx (cw-machfx) a31 B (his pick): lighter fog, day .46 to .30 and night .60 to .42. Enemies are still only drawn where you can see them.
function fogFillStyle(day,BR,lift,flash){
  return day?('rgba(58,46,38,'+clamp(.30-(BR-1)*.06-lift,.14,.38)+')')
            :('rgba(4,7,26,'+clamp(.42-(BR-1)*.09-flash*0.46,.04,.90)+')');
}
// v32.xx (cw-machfx) a35 B (his pick): the blast ring never draws past the real damage radius (dmgR, 190 as the frag default).
var BOOM_DMGR=190;
function boomRingR(b,k){ return Math.min((b.s0||b.s)*(20+160*k),b.dmgR||BOOM_DMGR); }
// v32.xx (cw-machfx) a28 B (his pick): a machine dies in a small blast and smoke (boomFx 0.6, kind bot) plus five metal chunks in its own colours
// flying about 24 px over 0.4 s. Pillager bots (raider) keep their own fall. Drawn only, cosmetic stream.
var MACH_DIE={sentry:1,crawler:1,warden:1,choir:1,howler:1,bulwark:1,listener:1,snitch:1};
function machineBlast(a){
  var i, ang, sp;
  if(!a||!MACH_DIE[a.kind]||typeof G==='undefined'||!G||G.sim||!G.sparks) return 0;
  try{ boomFx(a.x,a.y,0.6,'bot'); }catch(_mb){}
  for(i=0;i<5;i++){ ang=fxn(0,6.2832); sp=60*fxn(0.8,1.2); G.sparks.push({x:a.x,y:a.y,vx:Math.cos(ang)*sp,vy:Math.sin(ang)*sp,t:0,life:.4,c:a.c,nc:1,z:2.6}); }
  return 5;
}

'@

SubRx @'
  try{ gfxOnDeath(G.deathAnims[G.deathAnims.length-1]); }catch(_god){}
'@ @'
  try{ gfxOnDeath(G.deathAnims[G.deathAnims.length-1]); }catch(_god){}
  try{ machineBlast(G.deathAnims[G.deathAnims.length-1]); }catch(_mbl){}   // v32.xx (cw-machfx) a28 B
'@

SubRx @'
function boomFx(x,y,size,kind){
'@ @'
function boomFx(x,y,size,kind,dmgR){
'@

SubRx @'
  var s=clamp(+size||1,0.3,2.5), thin=(CFG.fxLevel===0)
'@ @'
  var s0=clamp(+size||1,0.3,2.5), s=(String(kind||'')==='bot')?s0:clamp(s0*1.6,0.3,2.5), thin=(CFG.fxLevel===0)
'@

SubRx @'
var b={g:G,x:x,y:y,s:s,kind:String(kind||''),t0:G.t||0,deb:[],smoke:[]};
'@ @'
var b={g:G,x:x,y:y,s:s,s0:s0,dmgR:+dmgR||BOOM_DMGR,kind:String(kind||''),t0:G.t||0,deb:[],smoke:[]};
'@

SubRx @'
k=t/0.22; R=b.s*(20+100*k);
'@ @'
k=t/0.22; R=boomRingR(b,k);   // v32.xx (cw-machfx) a35 B: ring R=20+160k, capped at the damage radius
'@

SubRx @'
    try{ boomFx(x,y,1.2,'frag'); }catch(_bfx){}
'@ @'
    try{ boomFx(x,y,1.2,'frag',R); }catch(_bfx){}
'@

SubRx @'
  try{ boomFx(q.x,q.y,1.2,'frag'); }catch(_ab){}
'@ @'
  try{ boomFx(q.x,q.y,1.2,'frag',R); }catch(_ab){}
'@

SubRx @'
  sfx('debrisLand',pt.x,pt.y);   // v27.82 (snd2): and in the linked window
  spark(pt.x,pt.y,'#ffcf7a',30,340); flash(pt.x,pt.y,300,'#ffb267',.5);
  try{ boomFx(pt.x,pt.y,1.4,'frag'); }catch(_de){}
'@ @'
  sfx('debrisLand',pt.x,pt.y);   // v27.82 (snd2): and in the linked window
  spark(pt.x,pt.y,'#ffcf7a',30,340); flash(pt.x,pt.y,300,'#ffb267',.5);
  try{ boomFx(pt.x,pt.y,1.4,'frag',R); }catch(_de){}
'@

SubRx @'
  sfx('debrisLand',pt.x,pt.y);   // v27.82 (snd2): the debris blast has its own sound (recorded crunch, sub drop, metal crash), the same ring and range as boom
  spark(pt.x,pt.y,'#ffcf7a',30,340); flash(pt.x,pt.y,300,'#ffb267',.5);
  try{ boomFx(pt.x,pt.y,1.4,'frag'); }catch(_de){}
'@ @'
  sfx('debrisLand',pt.x,pt.y);   // v27.82 (snd2): the debris blast has its own sound (recorded crunch, sub drop, metal crash), the same ring and range as boom
  spark(pt.x,pt.y,'#ffcf7a',30,340); flash(pt.x,pt.y,300,'#ffb267',.5);
  try{ boomFx(pt.x,pt.y,1.4,'frag',R); }catch(_de){}
'@

SubRx @'
  if(scarStamp('scorch',x,y,{r:26*k})) n++;
'@ @'
  if(scarStamp('scorch',x,y,{r:26*k*1.6})) n++;   // v32.xx (cw-machfx) a35 B: the scorch grows with the blast (look only)
'@

SubRx @'
var DAY_SHEET=0.13, NIGHT_SHEET=0.55, NIGHT_MOOD=1;
'@ @'
var DAY_SHEET=0.13, NIGHT_SHEET=0.45, NIGHT_MOOD=1;   // v32.xx (cw-machfx) a30 B (his pick): moonlit blue night, sheet .55 to .45 in rgba(10,20,60), fog .50 to .42 below
'@

SubRx @'
                       :('rgba(7,7,26,'+clamp(NIGHT_SHEET/BR,.05,.82)+')');
'@ @'
                       :('rgba(10,20,60,'+clamp(NIGHT_SHEET/BR,.05,.82)+')');
'@

SubRx @'
  S=day?[22,28,54]:[7,7,26]; 
'@ @'
  S=day?[22,28,54]:[10,20,60]; 
'@

SubRx @'
    wc.fillRect(0,0,W,H);
    TD=tod();
'@ @'
    wc.fillRect(0,0,W,H);
    if(!day){ wc.globalCompositeOperation='screen'; wc.fillStyle='rgba(20,40,90,.10)'; wc.fillRect(0,0,W,H); wc.globalCompositeOperation='lighter'; }   // v32.xx (cw-machfx) a30 B: a cool screen fill over the world at night
    TD=tod();
'@

SubRx @'
  fx2.fillStyle=isDay()?('rgba(58,46,38,'+clamp(.46-(BR-1)*.06-_lift,.22,.54)+')')
'@ @'
  fx2.fillStyle=fogFillStyle(isDay(),BR,_lift,_flash);   // v32.xx (cw-machfx) a31 B: lighter fog
'@

SubRx @'
                       :('rgba(4,7,26,'+clamp(.60-(BR-1)*.09-_flash*0.46,.04,.90)+')');

'@ @'
                       // v32.xx (cw-machfx) a31 B: the night fog (rgba(4,7,26), now .42) moved into fogFillStyle

'@

SubRx @'
var VER='32.70';
'@ @'
var VER='32.71';
'@

$pat = "(?m)^  now:'v32\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.71: Machines charge a shrinking red ring, die in a small blast with chunks, nights are moonlit blue, fog is lighter, hit sparks are chunkier and explosions are 60 percent bigger. Check 32.71 fails on v32.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
