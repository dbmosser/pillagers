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

# TITLE: A LIVE PILLAGER AND ROBOT FIGHT BEHIND THE MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function tickHubCrowd(dt){

'@ @'
// v28.xx (cw-title-fight), HIS ANSWERS 10-18 (Q52, Q54): "behind the title, the scoreboard and the how-to pages, show the live map, dimmed, with REAL
// pillager-versus-robot combat happening in it (no recorded clip). It must not cost frame rate: 60 fps at 4K on the title." Two fights on the Undercroft
// floor under the glass, one each side of the menu: a pillager with a rifle or an smg strafes and fires bursts at a sentry, the sentry winds up (its red
// lens) and answers with twin shots, hits spark, the machine blows up and a new one rolls in, the pillager goes down now and then and gets up. The bodies
// are the game's own drawOp and drawSentryS, the shots are tracers; it runs only while the title or the attract is up, on its own little random
// generator (never the raid seed), 4 bodies, a few shots and at most 90 sparks a frame, so it costs nothing at 4K.
var TSK=null;
function tskOn(){ var a=false; try{ a=!!(ATT&&ATT.on); }catch(_a){} return titleOn()||a; }
function tskRnd(){ TSK.s=(Math.imul(TSK.s,1664525)+1013904223)>>>0; return TSK.s/4294967296; }
function tskInit(){
  var A=[[62,392,152,392],[638,392,548,392]], i, a, P, R;
  TSK={s:20261018,t:0,ents:[],bolts:[],fx:[],ar:[],n:{shots:0,hits:0,kills:0,downs:0}};
  for(i=0;i<2;i++){
    a=A[i];
    P={tk:1,kind:'pil',x:a[0],y:a[1],ax:a[0],ay:a[1],face:i?Math.PI:0,hp:100,max:100,down:0,cd:.6+i*.7,burst:0,muz:0,step:0,t:i*2.1,hitT:0,coat:i?'#6a3f38':'#35566e',own:{wep:{id:i?'smg':'rifle'}}};
    R={tk:1,kind:'sentry',r:SENTRY_R0,x:a[2],y:a[3],face:i?0:Math.PI,hp:100,max:100,dead:0,cd:1+i*.9,windup:undefined,muzzle:0,step:0,state:'chase',hitT:0,fade:1,elite:false};
    TSK.ents.push(P,R); TSK.ar.push({p:P,r:R});
  }
}
function tskSpark(n,x,y,c,sp){
  var i, a, v;
  for(i=0;i<n;i++){ a=tskRnd()*6.2832; v=(.3+tskRnd())*sp; TSK.fx.push({x:x,y:y,vx:Math.cos(a)*v,vy:Math.sin(a)*v-sp*.3,l:.25+tskRnd()*.3,m:.5,c:c,s:1+tskRnd()*1.4}); }
  while(TSK.fx.length>90) TSK.fx.shift();
}
function tskShot(fx,fy,tx,ty,team,tgt){
  TSK.bolts.push({sx:fx,sy:fy,tx:tx,ty:ty,x:fx,y:fy,u:0,len:Math.hypot(tx-fx,ty-fy)||1,team:team,tgt:tgt,hit:tskRnd()<(team==='p'?.85:.7)});
  TSK.n.shots++;
}
function tskStep(dt){
  var o=TSK, i, k, a, P, R, b, tg;
  if(!o) return;
  if(!isFinite(dt)||dt<=0) return;
  if(dt>.05) dt=.05;
  o.t+=dt;
  for(i=0;i<o.ar.length;i++){
    a=o.ar[i]; P=a.p; R=a.r;
    P.hitT=Math.max(0,P.hitT-dt); P.muz=Math.max(0,P.muz-dt); R.muzzle=Math.max(0,R.muzzle-dt);
    P.t+=dt;
    if(P.down>0){ P.down-=dt; if(P.down<=0){ P.hp=P.max; P.cd=.8; } }
    else {
      P.y=P.ay+Math.sin(P.t*1.25)*20; P.x=P.ax+Math.sin(P.t*.6)*8; P.step+=dt*3;
      P.face=Math.atan2((R.y-20)-(P.y-14),R.x-P.x);
      P.cd-=dt;
      if(R.dead<=0&&P.cd<=0){
        if(P.burst>0){ P.burst--; P.cd=.12; P.muz=.06; tskShot(P.x+Math.cos(P.face)*18,P.y-14+Math.sin(P.face)*18,R.x+(tskRnd()-.5)*16,R.y-20+(tskRnd()-.5)*16,'p',R); }
        else { P.burst=4+((tskRnd()*4)|0); P.cd=.9+tskRnd()*.9; }
      }
    }
    if(R.dead>0){
      R.dead-=dt;
      if(R.dead<=0){ R.hp=R.max; R.fade=0; R.windup=undefined; R.cd=1.2; }
    } else {
      R.fade=Math.min(1,R.fade+dt*2.5);
      R.step+=dt*(R.fade<1?4:0);
      R.face=Math.atan2((P.y-14)-(R.y-25),P.x-R.x);
      if(R.windup!==undefined){
        R.windup-=dt;
        if(R.windup<=0){
          R.windup=undefined; R.cd=1.3+tskRnd()*.9; R.muzzle=.08;
          if(P.down<=0){
            tskShot(R.x+Math.cos(R.face)*32,R.y-25+Math.sin(R.face)*32-3,P.x,P.y-14,'r',P);
            tskShot(R.x+Math.cos(R.face)*32,R.y-25+Math.sin(R.face)*32+3,P.x,P.y-14,'r',P);
          }
        }
      } else if(P.down<=0&&R.fade>=1){ R.cd-=dt; if(R.cd<=0) R.windup=.4; }
    }
  }
  for(k=o.bolts.length-1;k>=0;k--){
    b=o.bolts[k]; b.u+=(b.team==='p'?420:300)*dt/b.len; b.x=b.sx+(b.tx-b.sx)*b.u; b.y=b.sy+(b.ty-b.sy)*b.u;
    if(b.u<1) continue;
    o.bolts.splice(k,1); tg=b.tgt;
    if(!b.hit){ tskSpark(3,b.tx,b.ty+10,'#9aa4ad',60); continue; }
    o.n.hits++; tskSpark(6,b.tx,b.ty,b.team==='p'?'#ffd27a':'#ff6a4a',90); tg.hitT=.18;
    if(tg.kind==='sentry'){
      if(tg.dead>0) continue;
      tg.hp-=7;
      if(tg.hp<=0){ tg.dead=2.4; o.n.kills++; tskSpark(28,tg.x,tg.y-22,'#ffb25a',150); tskSpark(14,tg.x,tg.y-22,'#6b747c',60); o.fx.push({ring:1,x:tg.x,y:tg.y-22,l:.4,m:.4,c:'#ffb25a'}); }
    } else {
      if(tg.down>0) continue;
      tg.hp-=11;
      if(tg.hp<=0){ tg.down=2.4; tg.burst=0; o.n.downs++; }
    }
  }
  for(k=o.fx.length-1;k>=0;k--){
    b=o.fx[k]; b.l-=dt;
    if(b.l<=0){ o.fx.splice(k,1); continue; }
    if(!b.ring){ b.x+=b.vx*dt; b.y+=b.vy*dt; b.vy+=260*dt; }
  }
}
function tskDraw(e){
  var o=TSK, i, b, f, dx, dy, d;
  if(!o||!wc) return;
  if(e.kind==='pil'){
    drawOp(e.x,e.y,e.face,e.step*3,e.coat,0.3,e.muz>0?1:0,e.down>0?'down':'none',0,{hero:0,moving:e.down<=0,sprint:false,ads:false,hurt:e.hitT,rl:0,own:e.own});
  } else if(e.kind==='sentry'){
    if(e.dead>0) return;
    if(e.fade<1){ wc.save(); wc.globalAlpha=Math.max(.05,e.fade); drawSentryS(e); wc.restore(); } else drawSentryS(e);
  } else {
    wc.save(); wc.globalCompositeOperation='lighter';
    for(i=0;i<o.bolts.length;i++){
      b=o.bolts[i]; dx=b.tx-b.sx; dy=b.ty-b.sy; d=Math.hypot(dx,dy)||1;
      wc.strokeStyle=b.team==='p'?'rgba(255,224,138,.9)':'rgba(255,90,60,.9)'; wc.lineWidth=1.6;
      wc.beginPath(); wc.moveTo(b.x-dx/d*12,b.y-dy/d*12); wc.lineTo(b.x,b.y); wc.stroke();
    }
    for(i=0;i<o.fx.length;i++){
      f=o.fx[i];
      if(f.ring){ wc.strokeStyle='rgba(255,178,90,'+(f.l/f.m*.8).toFixed(2)+')'; wc.lineWidth=2; wc.beginPath(); wc.arc(f.x,f.y,(1-f.l/f.m)*38+4,0,6.2832); wc.stroke(); }
      else { wc.globalAlpha=Math.min(1,f.l/.25); wc.fillStyle=f.c; wc.fillRect(f.x,f.y,f.s,f.s); wc.globalAlpha=1; }
    }
    wc.restore();
  }
}
function tickHubCrowd(dt){

'@

SubRx @'
  // v15.75 (multiplayer, build 2): the party, sorted with the walls, the posts, the crowd and him. Only while a party is on.

'@ @'
  // v28.xx (cw-title-fight), Q52/Q54: the fights under the title and the attract pages, sorted with everything else.
  if(tskOn()){ try{ if(!TSK) tskInit(); tskStep(dt); for(i=0;i<TSK.ents.length;i++) DR.push({k:TSK.ents[i].y,tk:TSK.ents[i]}); DR.push({k:99999,tk:{kind:'fx'}}); }catch(_tk){} }
  // v15.75 (multiplayer, build 2): the party, sorted with the walls, the posts, the crowd and him. Only while a party is on.

'@

SubRx @'
} else if(it.np){

'@ @'
} else if(it.tk){ try{ tskDraw(it.tk); }catch(_td){ try{ wc.restore(); }catch(_tr){} }
    } else if(it.np){

'@

SubRx @'
var VER='30.68';
'@ @'
var VER='30.69';
'@

$pat = "(?m)^  now:'v30\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.69: Behind the title and the scoreboard a pillager and a robot fight, live. Check 30.69 fails on v30.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
