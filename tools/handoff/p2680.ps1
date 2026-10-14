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

# RAID EVENTS: ORBITAL DEBRIS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  evTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@ @'
  evDraw(c);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@

SubRx @'
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@ @'
  evMarks(out);
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@

SubRx @'
    if(!f.told){ f.told=1; try{ d=Math.hypot(f.x-p.x,f.y-p.y); say('FUEL FIRE','warn',{sub:metres(d)+'M '+compass8(f.x-p.x,f.y-p.y)}); }catch(_ft){} }
'@ @'
    if(!f.told){ f.told=1; if(f.src==='fuel'){ try{ d=Math.hypot(f.x-p.x,f.y-p.y); say('FUEL FIRE','warn',{sub:metres(d)+'M '+compass8(f.x-p.x,f.y-p.y)}); }catch(_ft){} } }
'@

SubRx @'
kind:'fire',txt:(f.t<f.warn)?'FIRE':'FIRE',a:(f.t<f.warn)?0.6:1});
'@ @'
kind:'fire',shape:'tri',txt:(f.t<f.warn)?'FIRE':'FIRE',a:(f.t<f.warn)?0.6:1});
'@

SubRx @'
    ctx.beginPath(); ctx.moveTo(s.x,s.y-4.5*R); ctx.lineTo(s.x+3.5*R,s.y+3*R); ctx.lineTo(s.x-3.5*R,s.y+3*R); ctx.closePath(); ctx.fill();
'@ @'
    flowGlyph(ctx,m.shape,s.x,s.y,4.5*R);
'@

SubRx @'
    c.beginPath(); c.moveTo(x,y-6*MZ); c.lineTo(x+5*MZ,y+4*MZ); c.lineTo(x-5*MZ,y+4*MZ); c.closePath(); c.fill();
'@ @'
    flowGlyph(c,m.shape,x,y,6*MZ);
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow5), HIS ANSWER (2026-10-14) to suggestion 2: "give me the events" (all six). THE RAID EVENTS. A raid plans one or two events (1, and a
// second 60 percent of the time) on the side stream EV.tag of its seed, once the raid is 3 s old: which, from the events the game has, and when:
// the first 150 to 215 s in, the second 150 to 200 s after it. Each event is launched when its time comes, never over another event, never in
// the called window of an extraction (the siege), never in the last 100 s of a clock. Every event has a WARN countdown (a ring on the ground that
// fills round as the time runs down, with its name and the seconds, and a mark on the minimap and the sector map with the time), then it is LIVE,
// then it ends. An event is a row in EVENTS: name, sub, warn, dur, r (the ring), pick(ev) (where; false when it has no ground), start, tick,
// done, end, draw and live (the words while live). The place is picked on a side stream of the event number. DEMO and CAREER are the same.
// THE FIRST EVENT, ORBITAL DEBRIS: 22 s warning over a ring 300 wide, then five pieces come down inside it 2.3 s apart, each shown by a shadow
// and a dashed ring for 2.2 s before it lands (72 wide). A piece that lands hurts everything inside it (up to 180, you too), and leaves a BURNING
// WRECK: a fire of 58 that burns 45 s (impassable, as the fuel fires) and a wreck on its edge with two good items (a safe roll and a locker roll),
// marked on the maps until it is opened.
var EV={tag:62,first:[150,215],gap:[150,200],warn:25,retry:12};
var EV_IDS=['debris','convoy','bounty','cool','lock','rampage'];
var EVENTS={};
function evS(){ var S=flowS(); if(!S.ev) S.ev={plan:null,live:[],n:0,wrecks:[]}; return S.ev; }
function evEligible(){
  var out=[], i, d;
  for(i=0;i<EV_IDS.length;i++){ d=EVENTS[EV_IDS[i]]; if(d&&(!d.ok||d.ok())) out.push(EV_IDS[i]); }
  return out;
}
function evPlan(E){
  var ids=evEligible(), plan=[];
  if(!ids.length){ E.plan=plan; return plan; }
  sideStream((G.seed>>>0)||1,EV.tag,function(){
    var n=1+(rr()<0.6?1:0), t=EV.first[0]+rr()*(EV.first[1]-EV.first[0]), pool=ids.slice(), k, ix;
    for(k=0;k<n;k++){
      if(!pool.length) pool=ids.slice();
      ix=Math.floor(rr()*pool.length); plan.push({id:pool.splice(ix,1)[0],at:t,tries:0,on:0});
      t+=EV.gap[0]+rr()*(EV.gap[1]-EV.gap[0]);
    }
  });
  E.plan=plan;
  return plan;
}
function evStream(ev,fn){ sideStream((((G.seed>>>0)^Math.imul((ev.n|0)+1,7919))>>>0)||1,EV.tag,fn); }
function evLaunch(id){
  var E=evS(), def=EVENTS[id], ev;
  if(!def) return null;
  ev={id:id,n:E.n,name:def.name,t:0,warn:def.warn||EV.warn,dur:def.dur||30,ph:'warn',lt:0,et:0,fade:def.fade||4,x:0,y:0,r:def.r||300,d:{}};
  if(def.pick&&!def.pick(ev)) return null;
  E.n++; E.live.push(ev);
  try{ say(def.name,'warn',{sub:def.sub?(def.sub+'  '+Math.round(ev.warn)+'S'):(Math.round(ev.warn)+'S')}); }catch(_el){}
  return ev;
}
function evTick(dt){
  var E=evS(), i, ev, def, pl, t=G.t||0, busy=0;
  if(!E.plan){ if(t<3) return; evPlan(E); }
  for(i=0;i<E.live.length;i++) if(E.live[i].ph!=='end') busy=1;
  for(i=0;i<E.plan.length;i++){
    pl=E.plan[i];
    if(pl.on||t<pl.at||busy) continue;
    if(siegeCalled()||G.nuking||(raidClockOn()&&G.timeLeft<100)) continue;
    pl.on=1;
    if(!evLaunch(pl.id)){ pl.tries++; if(pl.tries<4){ pl.on=0; pl.at=t+EV.retry; } }
    busy=1;
  }
  for(i=E.live.length-1;i>=0;i--){
    ev=E.live[i]; def=EVENTS[ev.id]; ev.t+=dt;
    if(ev.ph==='warn'&&ev.t>=ev.warn){ ev.ph='live'; ev.lt=0; if(def.start) def.start(ev); }
    if(ev.ph==='live'){
      ev.lt+=dt;
      if(def.tick) def.tick(ev,dt);
      if((def.done&&def.done(ev))||ev.lt>=ev.dur){ ev.ph='end'; ev.et=0; if(def.end) def.end(ev); }
    } else if(ev.ph==='end'){ ev.et+=dt; if(ev.et>=ev.fade) E.live.splice(i,1); }
  }
  for(i=E.wrecks.length-1;i>=0;i--) if(!E.wrecks[i]||E.wrecks[i].opened||G.containers.indexOf(E.wrecks[i])<0) E.wrecks.splice(i,1);
}
function evDraw(c){
  var E=G.flow&&G.flow.ev, i, ev, def, s, q, z, R, rem, txt, t=G.t||0, U, lx, ly, pulse;
  if(!E||!E.live.length) return;
  q=ZOOM(); z=Math.max(1,hudRes()); U=function(v){ return LH(v)*z; };
  c.save();
  for(i=0;i<E.live.length;i++){
    ev=E.live[i]; def=EVENTS[ev.id]; if(!def) continue;
    s=w2s(def.mx?def.mx(ev):ev.x,0,def.my?def.my(ev):ev.y); R=ev.r*q; pulse=0.5+0.5*Math.sin(t*8); txt='';
    if(ev.ph==='warn'){
      rem=Math.max(0,ev.warn-ev.t);
      c.setLineDash([10*z,8*z]); c.strokeStyle='rgba(255,196,90,.55)'; c.lineWidth=2*z; c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.stroke(); c.setLineDash([]);
      c.strokeStyle='rgba(255,196,90,'+(0.8+0.2*pulse).toFixed(3)+')'; c.lineWidth=4*z; c.beginPath(); c.arc(s.x,s.y,R,-1.5708,-1.5708+6.2832*(1-rem/ev.warn)); c.stroke();
      txt=def.name+'  '+fmtClock(Math.ceil(rem));
    } else if(ev.ph==='live'){
      c.strokeStyle='rgba(255,98,66,'+(0.55+0.35*pulse).toFixed(3)+')'; c.lineWidth=3*z; c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.stroke();
      txt=def.name+(def.live?('  '+def.live(ev)):'');
    } else {
      c.globalAlpha=Math.max(0,1-ev.et/ev.fade)*0.6; c.strokeStyle='rgba(255,98,66,.5)'; c.lineWidth=2*z; c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.stroke(); c.globalAlpha=1;
    }
    if(def.draw) def.draw(ev,c,s,q,z);
    if(txt){
      lx=clamp(s.x,U(90),W-U(90)); ly=clamp(s.y-R-U(10),U(130),H-U(170));
      c.textAlign='center'; c.font=hudFS(TYPE.head); c.fillStyle='#ffe2a0'; hudText(txt,lx,ly);
    }
  }
  c.restore();
}
function evMarks(out){
  var E=G.flow&&G.flow.ev, i, ev, def, rem, c;
  if(!E) return;
  for(i=0;i<E.live.length;i++){
    ev=E.live[i]; if(ev.ph==='end') continue;
    def=EVENTS[ev.id]; if(!def) continue;
    rem=(ev.ph==='warn')?Math.ceil(ev.warn-ev.t):0;
    out.push({x:def.mx?def.mx(ev):ev.x,y:def.my?def.my(ev):ev.y,r:ev.r,col:def.col||'#ffcf5a',shape:'dia',kind:'ev',txt:def.name+(rem>0?('  '+fmtClock(rem)):''),pin:1,a:1});
  }
  for(i=0;i<E.wrecks.length;i++){ c=E.wrecks[i]; if(c&&!c.opened) out.push({x:c.x,y:c.y,r:0,col:'#ffc04a',shape:'sq',kind:'loot',txt:c.tag||'LOOT',pin:0,a:1}); }
}
function flowGlyph(c,shape,x,y,u){
  c.beginPath();
  if(shape==='dia'){ c.moveTo(x,y-u); c.lineTo(x+u*0.8,y); c.lineTo(x,y+u); c.lineTo(x-u*0.8,y); }
  else if(shape==='sq'){ c.rect(x-u*0.6,y-u*0.6,u*1.2,u*1.2); }
  else { c.moveTo(x,y-u); c.lineTo(x+u*0.8,y+u*0.65); c.lineTo(x-u*0.8,y+u*0.65); }
  c.closePath(); c.fill();
}
function debrisWreck(ev,pt){
  var L=[], c=null, k, a=0, wx, wy, E=evS(), seed=(((G.seed>>>0)^Math.imul((((ev.n|0)&255)<<5)+((pt.i|0)&31)+1,2654435761))>>>0)||1;
  sideStream(seed,EV.tag+1,function(){ L.push(rollLoot(LOOT.safe)); L.push(rollLoot(LOOT.locker)); a=rr()*6.2832; });
  for(k=0;k<8;k++){ wx=pt.x+Math.cos(a+k*0.785)*95; wy=pt.y+Math.sin(a+k*0.785)*95; if(spotFree(G.map,wx,wy,16)) break; }
  if(k>=8){ wx=pt.x+Math.cos(a)*95; wy=pt.y+Math.sin(a)*95; }
  sideStream(seed,EV.tag+2,function(){ c=setLoot(mkContainer(wx,wy,'botwreck'),L); });
  c.time=2.4; c.tag='DEBRIS WRECK'; c.wreck=1; G.containers.push(c); E.wrecks.push(c);
  return c;
}
function debrisImpact(ev,pt){
  var p=G.player, R=72, j, e, de, d;
  sfx('boom',pt.x,pt.y);
  spark(pt.x,pt.y,'#ffcf7a',30,340); flash(pt.x,pt.y,300,'#ffb267',.5);
  try{ boomFx(pt.x,pt.y,1.4,'frag'); }catch(_de){}
  try{ gfxBlastScar(pt.x,pt.y,1.3,false); }catch(_ds){}
  G.shake=Math.max(G.shake||0,Math.max(3,9-dist(p,pt)/120));
  d=Math.hypot(p.x-pt.x,p.y-pt.y);
  if(d<R+(p.r||11)&&!p.downed&&!p.dying&&!p.specOut) damagePlayer(Math.round(150*(1-d/(R+(p.r||11)))+30),'debris','ORBITAL DEBRIS',pt.x,pt.y);
  for(j=G.ents.length-1;j>=0;j--){
    e=G.ents[j];
    if(!e||!(e.hp>0)||e.kind==='snitch') continue;
    de=dist(e,pt); if(de>=R+e.r) continue;
    e.hp-=Math.round(150*(1-Math.max(0,de-e.r)/R)+30); e.hitT=.2;
  }
  fireAdd(pt.x,pt.y,58,45,'debris',0);
  debrisWreck(ev,pt);
}
EVENTS.debris={name:'ORBITAL DEBRIS',sub:'GET CLEAR',warn:22,dur:20,r:300,fade:4,col:'#ffcf5a',
  pick:function(ev){
    var p=G.player, got=null;
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<60&&!got;k++){
        a=rr()*6.2832; d=500+rr()*500; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d;
        if(x<300||y<300||x>WORLD_W-300||y>WORLD_H-300) continue;
        if(!spotFree(G.map,x,y,40)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)||flowZoneNear(x,y,420)) continue;
        got={x:x,y:y};
      }
    });
    if(!got) return false;
    ev.x=got.x; ev.y=got.y;
    return true;
  },
  start:function(ev){
    var pts=[];
    evStream(ev,function(){
      var k, tries, a, d, x, y;
      for(k=0;k<5;k++){
        for(tries=0;tries<30;tries++){
          a=rr()*6.2832; d=rr()*ev.r*0.85; x=ev.x+Math.cos(a)*d; y=ev.y+Math.sin(a)*d;
          if(spotFree(G.map,x,y,40)&&!flowZoneNear(x,y,200)){ pts.push({x:x,y:y,at:2.2+k*2.3+rr()*0.6,done:0,i:k}); break; }
        }
      }
    });
    ev.d.pts=pts;
    try{ say('DEBRIS INBOUND','crit'); }catch(_ds2){}
  },
  tick:function(ev){
    var pts=ev.d.pts||[], i;
    for(i=0;i<pts.length;i++) if(!pts[i].done&&ev.lt>=pts[i].at){ pts[i].done=1; debrisImpact(ev,pts[i]); }
  },
  done:function(ev){
    var pts=ev.d.pts||[], i, last=0;
    for(i=0;i<pts.length;i++){ if(!pts[i].done) return false; last=Math.max(last,pts[i].at); }
    return ev.lt>=last+3;
  },
  live:function(ev){ var pts=ev.d.pts||[], n=0, i; for(i=0;i<pts.length;i++) if(!pts[i].done) n++; return n+' TO COME'; },
  draw:function(ev,c,s,q,z){
    var pts=ev.d.pts||[], i, pt, k, ps, R=72*q, t=G.t||0;
    if(ev.ph!=='live') return;
    for(i=0;i<pts.length;i++){
      pt=pts[i]; if(pt.done||ev.lt<pt.at-2.2) continue;
      k=clamp((ev.lt-(pt.at-2.2))/2.2,0,1); ps=w2s(pt.x,0,pt.y);
      c.fillStyle='rgba(0,0,0,'+(0.18+0.22*k).toFixed(3)+')'; c.beginPath(); c.arc(ps.x,ps.y,R*(0.35+0.65*k),0,6.2832); c.fill();
      c.strokeStyle='rgba(255,80,50,'+(0.5+0.4*Math.sin(t*16)).toFixed(3)+')'; c.lineWidth=2*z; c.setLineDash([6*z,6*z]);
      c.beginPath(); c.arc(ps.x,ps.y,R,0,6.2832); c.stroke(); c.setLineDash([]);
    }
  }
};
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.79';
'@ @'
var VER='26.80';
'@

$pat = "(?m)^  now:'v26\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.80: Raids now plan one or two events with a countdown ring and a map mark; the first is orbital debris with burning loot wrecks. Check 26.80 fails on v26.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
