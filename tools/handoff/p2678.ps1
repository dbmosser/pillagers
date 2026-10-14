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

# FIRE HAZARDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  goalsTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  goalsTick(dt);
  fireTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  airDraw(c,p);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@ @'
  fireDraw(c);
  airDraw(c,p);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@

SubRx @'
  // the party's marks and pings, then your waypoint
'@ @'
  try{ flowMm(at,R,sc); }catch(_fmm){}   // v26.xx (flow4): the raid flow marks (fires now, the events and strongholds after)
  // the party's marks and pings, then your waypoint
'@

SubRx @'
  // THE STRONGBOX. Marked from the start: it is not a secret, it is a dare.
'@ @'
  try{ flowMap(ctx,ox,oy,sc,_MZ,FS); }catch(_fmp){}   // v26.xx (flow4): the raid flow marks on the sector map
  // THE STRONGBOX. Marked from the start: it is not a secret, it is a dare.
'@

SubRx @'
  if(flowZoneNear(x,y,DIR.ring)) return false;   // v26.xx (flow1): the Director never lands a pack on an extraction ring
'@ @'
  if(flowZoneNear(x,y,DIR.ring)) return false;   // v26.xx (flow1): the Director never lands a pack on an extraction ring
  if(fireAt(x,y,60)) return false;   // v26.xx (flow4): and never in a fire
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow4), HIS YES (2026-10-14) to suggestion 7, in his words: "fire as a hazard that makes spots impassable, NOT from the map edges". FIRE HAZARDS.
// A raid plans FIRE.n (2) fuel fires on the side stream FIRE.tag of its seed: spots on open, reachable floor at least 700 from the drop and 300
// from any extraction ring, lit at 70 to 110 s and then every 90 to 140 s. A fire is a disc (FIRE.r, 92) that smoulders for FIRE.warn (4 s, a
// dashed ring on the ground and FUEL FIRE in the alert lane with the way to it), burns FIRE.life (55 s) and glows 8 s more as embers. WHILE IT
// BURNS IT IS IMPASSABLE: every frame (after the player has moved, before the bodies do) whoever stands in the disc is put back on its edge,
// the player, the machines and the pillagers alike (not the hovering Crier), and whoever stands at the edge is burned: the player for 6 every half
// second (so 12 a second, half that in the DEMO), the bodies 22 a second, with nobody credited. The Director never lands a pack in a fire. The
// fires are marks on the minimap and the sector map. fireAdd(x,y,r,life,src,warn) is the one door, for the raid events that burn. Bullets fly over
// fire. The flames are drawn on the HUD, deterministic from the clock, with sparks on the cosmetic stream (fxn). DEMO and CAREER are the same.
var FIRE={r:92,life:55,warn:4,ember:8,burn:6,ebur:22,n:2,first:[70,110],gap:[90,140],tag:63,pad:14};
function fireS(){ var S=flowS(); if(!S.fires) S.fires=[]; return S.fires; }
function fireAdd(x,y,r,life,src,warn){
  var S=flowS(), F=fireS(), f={x:x,y:y,r:r||FIRE.r,t:0,life:life||FIRE.life,warn:(warn===undefined?FIRE.warn:warn),src:src||'fuel',id:(S.fireN=(S.fireN|0)+1),bt:0,told:0};
  F.push(f); return f;
}
function fireLit(f){ return !!f&&f.t>=f.warn&&f.t<f.warn+f.life; }
function fireAt(x,y,pad){
  var F=G&&G.flow&&G.flow.fires, i;
  for(i=0;F&&i<F.length;i++) if(fireLit(F[i])&&Math.hypot(x-F[i].x,y-F[i].y)<F[i].r+(pad||0)) return F[i];
  return null;
}
function firePlan(S){
  var p=G.player, k, tries, x, y, t, plan=[];
  sideStream((G.seed>>>0)||1,FIRE.tag,function(){
    t=FIRE.first[0]+rr()*(FIRE.first[1]-FIRE.first[0]);
    for(k=0;k<FIRE.n;k++){
      for(tries=0;tries<60;tries++){
        x=120+rr()*(WORLD_W-240); y=120+rr()*(WORLD_H-240);
        if(Math.hypot(x-p.x,y-p.y)<700) continue;
        if(!spotFree(G.map,x,y,30)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)||flowZoneNear(x,y,300)) continue;
        plan.push({x:x,y:y,at:t,on:0}); break;
      }
      t+=FIRE.gap[0]+rr()*(FIRE.gap[1]-FIRE.gap[0]);
    }
  });
  S.fplan=plan;
  return plan;
}
// put a body back on the edge of a lit fire; true when it was inside
function fireKeep(o,rad){
  var F=G.flow.fires, i, f, d, R, a, nx, ny, k, ta;
  for(i=0;i<F.length;i++){
    f=F[i]; if(!fireLit(f)) continue;
    d=Math.hypot(o.x-f.x,o.y-f.y); R=f.r+rad;
    if(d>=R) continue;
    a=(d>0.5)?Math.atan2(o.y-f.y,o.x-f.x):((o.id|0)*1.7+0.3);
    for(k=0;k<5;k++){
      ta=a+((k===0)?0:((k&1)?1:-1)*Math.ceil(k/2)*0.55);
      nx=f.x+Math.cos(ta)*(R+1); ny=f.y+Math.sin(ta)*(R+1);
      if(nx>20&&ny>20&&nx<WORLD_W-20&&ny<WORLD_H-20&&spotFree(G.map,nx,ny,Math.max(6,rad*0.6))){ o.x=nx; o.y=ny; break; }
    }
    return true;
  }
  return false;
}
function fireNear(o,rad){
  var F=G.flow.fires, i, f;
  for(i=0;i<F.length;i++){ f=F[i]; if(fireLit(f)&&Math.hypot(o.x-f.x,o.y-f.y)<f.r+rad+FIRE.pad) return f; }
  return null;
}
function fireTick(dt){
  var S=flowS(), F, i, f, t=G.t||0, p=G.player, e, a, r, any=0, pl, hit, d;
  if(!S.fplan) firePlan(S);
  for(i=0;i<S.fplan.length;i++) if(!S.fplan[i].on&&t>=S.fplan[i].at){ S.fplan[i].on=1; fireAdd(S.fplan[i].x,S.fplan[i].y,FIRE.r,FIRE.life,'fuel',FIRE.warn); }
  F=fireS();
  for(i=F.length-1;i>=0;i--){
    f=F[i]; f.t+=dt;
    if(!f.told){ f.told=1; try{ d=Math.hypot(f.x-p.x,f.y-p.y); say('FUEL FIRE','warn',{sub:metres(d)+'M '+compass8(f.x-p.x,f.y-p.y)}); }catch(_ft){} }
    if(f.t>=f.warn+f.life+FIRE.ember){ F.splice(i,1); continue; }
    if(fireLit(f)){ any=1; if(fxr()<dt*5){ a=fxn(0,6.2832); r=fxn(0,f.r*0.9); spark(f.x+Math.cos(a)*r,f.y+Math.sin(a)*r,'#ff9a3c',2,70); } }
  }
  if(!any) return;
  if(p&&!p.specOut){
    fireKeep(p,p.r||11);
    pl=fireNear(p,p.r||11);
    if(pl){
      pl.bt+=dt;
      if(pl.bt>=0.5){ pl.bt=0; if(!p.downed&&!p.dying) damagePlayer(FIRE.burn,'fire','THE FIRE'); }
    }
  }
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!e||!(e.hp>0)||e.kind==='snitch') continue;
    fireKeep(e,e.r||12);
    if(fireNear(e,e.r||12)){ e.hp-=FIRE.ebur*dt; e.hitT=Math.max(e.hitT||0,0.1); }
  }
}
function fireDraw(c){
  var F=G.flow&&G.flow.fires, i, j, f, s, q, z, R, t=G.t||0, n, ang, bx, by, hh, ww, fade, gr, k;
  if(!F||!F.length) return;
  q=ZOOM(); z=Math.max(1,hudRes());
  c.save();
  for(i=0;i<F.length;i++){
    f=F[i]; s=w2s(f.x,0,f.y); R=f.r*q;
    if(s.x<-R*1.5||s.y<-R*1.5||s.x>W+R*1.5||s.y>H+R*1.5) continue;
    if(f.t<f.warn){
      k=f.t/Math.max(0.1,f.warn);
      c.setLineDash([8*z,7*z]); c.strokeStyle='rgba(255,140,60,'+(0.35+0.4*Math.abs(Math.sin(t*9))).toFixed(3)+')'; c.lineWidth=2*z;
      c.beginPath(); c.arc(s.x,s.y,R*(1.1-0.1*k),0,6.2832); c.stroke(); c.setLineDash([]);
      continue;
    }
    fade=(f.t<f.warn+f.life)?1:Math.max(0,1-(f.t-f.warn-f.life)/FIRE.ember);
    if(fade<=0) continue;
    c.globalCompositeOperation='source-over';
    c.fillStyle='rgba(22,10,6,'+(0.38*fade).toFixed(3)+')'; c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.fill();
    c.globalCompositeOperation='lighter';
    gr=c.createRadialGradient(s.x,s.y,R*0.2,s.x,s.y,R*1.35);
    gr.addColorStop(0,'rgba(255,150,50,'+(0.42*fade).toFixed(3)+')'); gr.addColorStop(0.7,'rgba(255,90,20,'+(0.22*fade).toFixed(3)+')'); gr.addColorStop(1,'rgba(255,60,10,0)');
    c.fillStyle=gr; c.beginPath(); c.arc(s.x,s.y,R*1.35,0,6.2832); c.fill();
    if(fade>=1){
      for(k=0;k<2;k++){
        n=k?9:14;
        for(j=0;j<n;j++){
          ang=j/n*6.2832+0.3*Math.sin(t*1.3+j+k);
          bx=s.x+Math.cos(ang)*R*(k?0.42:0.78); by=s.y+Math.sin(ang)*R*(k?0.42:0.78);
          hh=R*((k?0.22:0.3)+0.2*Math.abs(Math.sin(t*6.5+j*1.9+k*2.3))); ww=R*(k?0.1:0.13);
          c.fillStyle=k?'rgba(255,214,120,.55)':'rgba(255,128,36,.5)';
          c.beginPath(); c.moveTo(bx-ww,by); c.quadraticCurveTo(bx-ww*0.3,by-hh*0.6,bx+Math.sin(t*5+j)*R*0.05,by-hh); c.quadraticCurveTo(bx+ww*0.3,by-hh*0.6,bx+ww,by); c.closePath(); c.fill();
        }
      }
    }
  }
  c.restore();
}
// the marks of the raid flow, for the minimap and the sector map: each {x,y,r,col,kind,txt,pin}
function fireMarks(out){
  var F=G.flow&&G.flow.fires, i, f;
  for(i=0;F&&i<F.length;i++){
    f=F[i]; if(f.t>=f.warn+f.life) continue;
    out.push({x:f.x,y:f.y,r:f.r,col:'#ff7a2a',kind:'fire',txt:(f.t<f.warn)?'FIRE':'FIRE',a:(f.t<f.warn)?0.6:1});
  }
}
function flowMarks(){
  var out=[];
  if(!G||!G.flow) return out;
  fireMarks(out);
  // FLOW-MARKS (the next flow builds add their marks above this line)
  return out;
}
function flowMm(at,R,sc){
  var M=flowMarks(), i, m, s, rad;
  for(i=0;i<M.length;i++){
    m=M[i]; s=at(m.x,m.y);
    if(s.out){ if(m.pin) mmArrow(s,R,m.col); continue; }
    rad=Math.max(5*R,(m.r||0)*sc);
    ctx.globalAlpha=(m.a===undefined)?1:m.a;
    ctx.fillStyle=m.col; ctx.strokeStyle=m.col; ctx.lineWidth=1.6*R;
    ctx.globalAlpha*=0.22; ctx.beginPath(); ctx.arc(s.x,s.y,rad,0,6.2832); ctx.fill();
    ctx.globalAlpha=(m.a===undefined)?1:m.a; ctx.beginPath(); ctx.arc(s.x,s.y,rad,0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(s.x,s.y-4.5*R); ctx.lineTo(s.x+3.5*R,s.y+3*R); ctx.lineTo(s.x-3.5*R,s.y+3*R); ctx.closePath(); ctx.fill();
    MMAP.ops+=3; ctx.globalAlpha=1;
  }
}
function flowMap(c,ox,oy,sc,MZ,FSf){
  var M=flowMarks(), i, m, x, y, rad;
  for(i=0;i<M.length;i++){
    m=M[i]; x=ox+m.x*sc; y=oy+m.y*sc; rad=Math.max(9*MZ,(m.r||0)*sc);
    c.globalAlpha=(m.a===undefined)?1:m.a; c.fillStyle=m.col; c.strokeStyle=m.col; c.lineWidth=1.8*MZ;
    c.globalAlpha*=0.2; c.beginPath(); c.arc(x,y,rad,0,6.2832); c.fill();
    c.globalAlpha=(m.a===undefined)?1:m.a; c.beginPath(); c.arc(x,y,rad,0,6.2832); c.stroke();
    c.beginPath(); c.moveTo(x,y-6*MZ); c.lineTo(x+5*MZ,y+4*MZ); c.lineTo(x-5*MZ,y+4*MZ); c.closePath(); c.fill();
    if(m.txt){ c.textAlign='center'; c.font=FSf(TYPE.micro); c.fillText(m.txt,x,y-rad-4*MZ); c.textAlign='left'; }
    c.globalAlpha=1;
  }
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.77';
'@ @'
var VER='26.78';
'@

$pat = "(?m)^  now:'v26\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.78: Two fuel fires per raid burn as impassable discs of flame that stop and burn anyone at their edge. Check 26.78 fails on v26.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
