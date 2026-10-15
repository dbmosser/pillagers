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

# ARCADE POWER-UPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
'@ @'
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk){}   // v26.xx (party1): the style bonuses and medals
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk){}   // v26.xx (party2): a kill may drop a power-up
'@

SubRx @'
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk2){}   // v26.xx (party1): the same style bonuses in a CAREER raid
'@ @'
  try{ styleKill(k,el,boss,x,y,ke); }catch(_sk2){}   // v26.xx (party1): the same style bonuses in a CAREER raid
  try{ pwrKill(k,el,boss,x,y,ke); }catch(_pk2){}   // v26.xx (party2): and in a CAREER raid
'@

SubRx @'
  try{ styleTick(p,dt); }catch(_sty){}   // v26.xx (party1): the calm clock and the medal plates
'@ @'
  try{ styleTick(p,dt); }catch(_sty){}   // v26.xx (party1): the calm clock and the medal plates
  try{ pwrTick(p,dt); }catch(_pwt){}   // v26.xx (party2): the pickups, the timers and the bottomless clip
'@

SubRx @'
  // reticle at the cursor
'@ @'
  try{ pwrDraw(ctx,p); }catch(_pwd){}   // v26.xx (party2): the power-ups on the floor, the aura and the timer chips
  // reticle at the cursor
'@

SubRx @'
          p.ammo--; p.lastShot=now; p.fired=true;
          fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true);
'@ @'
          if(!pwrClip()) p.ammo--; p.lastShot=now; p.fired=true;
          fireWeapon(p,p.wep,p.x+Math.cos(p.face)*100,p.y+Math.sin(p.face)*100,true);
'@

SubRx @'
now-p.lastShot>p.wep.rof*spinMul(p)
'@ @'
now-p.lastShot>p.wep.rof*spinMul(p)*pwrRof()
'@

SubRx @'
*((fromPlayer&&!G.sim&&G.player.arBonus>0)?AR_BONUS:1),
'@ @'
*((fromPlayer&&!G.sim&&G.player.arBonus>0)?AR_BONUS:1)*pwrMul('dmg',fromPlayer),
'@

SubRx @'
var _mdm=wep.dmg;
'@ @'
var _mdm=wep.dmg*pwrMul('dmg',fromPlayer);
'@

SubRx @'
// PARTY-MODULE-END (the next party builds add their code above this line)
'@ @'
// v26.xx (party2), HIS YES (2026-10-14) to suggestion 40, ARCADE POWER-UPS, in his words: "make one bottomless clip/infinite ammo for a limited time. Look at COD Zombies".
// A kill may drop a walk-over pickup, at a low rate like the Zombies power-ups: PWR.drop (5 percent) of the kills, four times that for an elite,
// every boss, and one at least every PWR.pity (30) kills; never closer than PWR.gap (15 s) after the last and never more than PWR.max (3) on the floor.
// The roll is made on a side stream (tag PWR.tag) of the raid seed and the kill's number in the raid, so the seeded stream does not move and the
// same raid with the same kills drops the same ones. A pickup shines for PWR.life (16 s), blinking over the last 4, and is taken by walking
// over it (PWR.pick, 34 units). Each is TIMED and has its own colour, glyph and note on the sting bus (no voice):
//   BOTTOMLESS CLIP (20 s): a shot costs no round and the magazine is topped up every step, so there is no reload and no dry gun;
//   DOUBLE DAMAGE (15 s): every round and swing you make hits twice as hard;
//   RAPID FIRE (15 s): the gap between shots is half the gun's own.
// The same kind again refreshes its clock. Going down for good clears them. A timer chip for each runs above the belt, the player has a ring of
// its colour at his feet while it runs (blinking over the last 3 s, with a tick each second), and the end is a falling note. Live play in a DEMO
// or CAREER raid only (the same in both); each window drops for its own kills and the pickups are its own.
var PWR={drop:0.05,eliteX:4,pity:30,gap:15,life:16,blink:4,pick:34,max:3,tag:71,warn:3};
var PWR_KINDS=[
  {k:'clip',n:'BOTTOMLESS CLIP',sec:20,w:22,hex:'#ffd24a',rgb:'255,210,74'},
  {k:'dmg',n:'DOUBLE DAMAGE',sec:15,w:20,hex:'#ff4a3a',rgb:'255,74,58'},
  {k:'rapid',n:'RAPID FIRE',sec:15,w:20,hex:'#7dff4a',rgb:'125,255,74'},
  // PWR-KINDS (the next party builds add their rows above this line)
];
var PWR_SND={
  clip:[[0,523,523,0.1,'triangle',0.05],[0.06,659,659,0.1,'triangle',0.05],[0.12,784,784,0.1,'triangle',0.05],[0.18,1047,1047,0.1,'triangle',0.05],[0.24,1568,1568,0.4,'sine',0.045],[0.24,2093,2093,0.3,'sine',0.014]],
  dmg:[[0,110,220,0.3,'sawtooth',0.07],[0,165,330,0.3,'sawtooth',0.05],[0.12,440,440,0.3,'square',0.03]],
  rapid:[[0,1175,1175,0.05,'square',0.04],[0.06,1319,1319,0.05,'square',0.04],[0.12,1568,1568,0.05,'square',0.04],[0.18,1760,1760,0.05,'square',0.04],[0.24,2093,2093,0.2,'square',0.04]],
  spawn:[[0,1319,1319,0.08,'sine',0.03],[0.07,1760,1760,0.18,'sine',0.03]],
  end:[[0,660,330,0.2,'triangle',0.04]],
  tick:[[0,1500,1500,0.04,'square',0.03]],
  // PWR-SND (the next party builds add their notes above this line)
};
function pwrS(){ if(!G.pwr) G.pwr={items:[],act:{},kn:0,since:0,lastDrop:-99,drops:0,log:[],id:0}; return G.pwr; }
function pwrDef(k){ var i; for(i=0;i<PWR_KINDS.length;i++) if(PWR_KINDS[i].k===k) return PWR_KINDS[i]; return null; }
function pwrOn(k){ return !!(G&&G.pwr&&G.pwr.act&&G.pwr.act[k]>0); }
function pwrClip(){ return pwrOn('clip'); }
function pwrMul(w,fromPlayer){ return (fromPlayer&&w==='dmg'&&pwrOn('dmg'))?2:1; }
function pwrRof(){ return pwrOn('rapid')?0.5:1; }
function pwrDrop(kd,x,y){
  var S=pwrS(), D=pwrDef(kd), t=+G.t||0;
  if(!D) return null;
  S.items.push({k:kd,x:x,y:y,t:0,life:PWR.life,id:(S.id=(S.id|0)+1)});
  S.since=0; S.lastDrop=t; S.drops++;
  S.log.push(S.kn+':'+kd); if(S.log.length>400) S.log.shift();
  try{ label(x,y-30,D.n,D.hex,0,true); }catch(_l){}
  try{ styTone(PWR_SND.spawn); }catch(_s){}
  return S.items[S.items.length-1];
}
// a kill was credited: maybe a drop where he fell (e is the body, when there is one)
function pwrKill(k,el,boss,x,y,e){
  var S, t, n, ch, roll=1, wr=0, tot=0, i, kd=null, p;
  if(!G||G.sim||G.over||!G.player||!(G.arcade||G.career)) return 0;
  S=pwrS(); t=+G.t||0; p=G.player; n=S.kn++; S.since++;
  sideStream(((((G.seed>>>0)^Math.imul(n+1,0x85EBCA6B))>>>0)||1),PWR.tag,function(){ roll=rr(); wr=rr(); });
  ch=boss?1:PWR.drop*(el?PWR.eliteX:1);
  if(S.items.length>=PWR.max) return 0;
  if(!boss&&t-S.lastDrop<PWR.gap) return 0;
  if(!(boss||S.since>=PWR.pity||roll<ch)) return 0;
  for(i=0;i<PWR_KINDS.length;i++) tot+=PWR_KINDS[i].w;
  wr*=tot;
  for(i=0;i<PWR_KINDS.length;i++){ wr-=PWR_KINDS[i].w; if(wr<0||i===PWR_KINDS.length-1){ kd=PWR_KINDS[i].k; break; } }
  if(!isFinite(x)||!isFinite(y)){ x=p.x; y=p.y-40; }
  return pwrDrop(kd,x,y)?1:0;
}
function pwrTake(S,it,p){
  var D=pwrDef(it.k);
  if(!D) return false;
  S.act[it.k]=Math.max(+S.act[it.k]||0,D.sec);
  try{ say(D.n,'ext',{sub:D.sec+' S'}); }catch(_s){}
  try{ spark(it.x,it.y,D.hex,18,280); }catch(_sp){}
  try{ styTone(PWR_SND[it.k]); }catch(_t){}
  return true;
}
// every step of the player: the pickups (walk over to take), the clocks, and the bottomless clip
function pwrTick(p,dt){
  var S, i, it, k, before;
  if(!G||G.sim||G.over||!p||!(G.arcade||G.career)||!(dt>0)) return;
  S=pwrS();
  if(p.dying) S.act={};
  for(i=S.items.length-1;i>=0;i--){
    it=S.items[i]; it.t+=dt;
    if(it.t>=it.life){ S.items.splice(i,1); continue; }
    if(!p.downed&&!p.dying&&!p.specOut&&Math.hypot(it.x-p.x,it.y-p.y)<PWR.pick){ pwrTake(S,it,p); S.items.splice(i,1); }
  }
  for(k in S.act){
    if(!(S.act[k]>0)) continue;
    before=S.act[k]; S.act[k]-=dt;
    if(S.act[k]<=0){ S.act[k]=0; try{ styTone(PWR_SND.end); }catch(_e){} }
    else if(S.act[k]<=PWR.warn&&Math.ceil(S.act[k])!==Math.ceil(before)){ try{ styTone(PWR_SND.tick); }catch(_k){} }
  }
  if(S.act.clip>0&&p.wep&&p.wep.mag>0){ p.ammo=p.wep.mag; p.reloading=0; p.jam=0; }
}
// the glyph in the middle of a pickup coin (x, y the middle, s the size)
function pwrGlyph(c,k,x,y,s,D,z){
  var j;
  c.save(); c.strokeStyle='rgba('+D.rgb+',1)'; c.fillStyle='rgba('+D.rgb+',1)'; c.lineWidth=2.2*z; c.lineCap='round'; c.lineJoin='round';
  if(k==='clip'){ c.beginPath(); c.arc(x-s*0.5,y,s*0.5,0,6.2832); c.stroke(); c.beginPath(); c.arc(x+s*0.5,y,s*0.5,0,6.2832); c.stroke(); }
  else if(k==='dmg'){ c.font=hudFS(TYPE.label); c.textAlign='center'; c.fillText('2X',x,y+4*z); }
  else if(k==='rapid'){ for(j=0;j<3;j++){ c.beginPath(); c.moveTo(x-s*0.9+j*s*0.62,y-s*0.7); c.lineTo(x-s*0.35+j*s*0.62,y); c.lineTo(x-s*0.9+j*s*0.62,y+s*0.7); c.stroke(); } }
  // PWR-GLYPHS (the next party builds add their glyphs above this line)
  c.restore();
}
// the pickups on the floor (a beam, a pulse on the ground and a coin that bobs), the ring at the player's feet, and the timer chips above the belt
function pwrDraw(c,p){
  var S=G&&G.pwr, q, z, t, i, it, D, s, bob, left, a, R, ph, gr, k, n, ids=[], tw, tot, x0, y0, cy, miny, f, sc, ew;
  if(!S||G.sim||!(G.arcade||G.career)||!p) return;
  q=ZOOM(); z=Math.max(1,hudRes()); t=+G.t||0;
  c.save();
  for(i=0;i<S.items.length;i++){
    it=S.items[i]; D=pwrDef(it.k); if(!D) continue;
    s=w2s(it.x,0,it.y); if(s.x<-120||s.y<-180||s.x>W+120||s.y>H+120) continue;
    left=it.life-it.t; a=(left<PWR.blink&&(Math.floor(left*7)%2))?0.35:1;
    bob=Math.sin(t*3+it.id*1.3)*4*q; R=15*q; cy=s.y-bob-8*q;
    c.globalAlpha=a; c.globalCompositeOperation='lighter';
    ph=(t*0.9+it.id*0.37)%1;
    c.strokeStyle='rgba('+D.rgb+','+(0.5*(1-ph)).toFixed(3)+')'; c.lineWidth=2*z;
    c.beginPath(); c.ellipse(s.x,s.y+4*q,R*(1+ph*1.8),R*(1+ph*1.8)*0.45,0,0,6.2832); c.stroke();
    gr=c.createLinearGradient(0,cy-110*q,0,cy);
    gr.addColorStop(0,'rgba('+D.rgb+',0)'); gr.addColorStop(1,'rgba('+D.rgb+',.36)');
    c.fillStyle=gr; c.fillRect(s.x-6*q,cy-110*q,12*q,110*q);
    gr=c.createRadialGradient(s.x,cy,R*0.2,s.x,cy,R*2.4);
    gr.addColorStop(0,'rgba('+D.rgb+',.55)'); gr.addColorStop(1,'rgba('+D.rgb+',0)');
    c.fillStyle=gr; c.beginPath(); c.arc(s.x,cy,R*2.4,0,6.2832); c.fill();
    c.globalCompositeOperation='source-over';
    c.fillStyle='rgba(14,16,20,.92)'; c.beginPath(); c.arc(s.x,cy,R,0,6.2832); c.fill();
    c.strokeStyle='rgba('+D.rgb+',1)'; c.lineWidth=2.4*z; c.beginPath(); c.arc(s.x,cy,R,0,6.2832); c.stroke();
    pwrGlyph(c,it.k,s.x,cy,R*0.62,D,z);
  }
  c.globalAlpha=1;
  sc=w2s(p.x,0,p.y); n=0;
  for(i=0;i<PWR_KINDS.length;i++){
    D=PWR_KINDS[i]; if(!(S.act[D.k]>0)) continue;
    ids.push(D);
    a=(S.act[D.k]<=PWR.warn&&(Math.floor(S.act[D.k]*5)%2))?0.3:0.75;
    c.globalCompositeOperation='lighter';
    c.setLineDash([6*z,9*z]); c.lineDashOffset=-t*40*z*((n%2)?-1:1);
    c.strokeStyle='rgba('+D.rgb+','+a.toFixed(3)+')'; c.lineWidth=2.2*z;
    c.beginPath(); c.ellipse(sc.x,sc.y+3*q,(24+6*n)*q,(24+6*n)*q*0.5,0,0,6.2832); c.stroke();
    c.setLineDash([]); c.globalCompositeOperation='source-over';
    n++;
  }
  if(ids.length){
    c.font=hudFS(TYPE.micro); c.textAlign='left'; tot=-8*z;
    for(i=0;i<ids.length;i++){ ids[i].tw=c.measureText(ids[i].n).width+60*z; tot+=ids[i].tw+8*z; }
    miny=H*0.84;
    if(G.hotCells&&G.hotCells.length){ miny=1e9; for(i=0;i<G.hotCells.length;i++) miny=Math.min(miny,G.hotCells[i].y); miny-=40*z; }
    x0=Math.round(W/2-tot/2); y0=Math.round(miny-24*z);
    for(i=0;i<ids.length;i++){
      D=ids[i]; ew=D.tw; f=Math.max(0,Math.min(1,S.act[D.k]/D.sec));
      a=(S.act[D.k]<=PWR.warn&&(Math.floor(S.act[D.k]*5)%2))?0.45:1;
      c.globalAlpha=a*0.82; c.fillStyle='rgba(12,14,18,1)'; c.fillRect(x0,y0,Math.round(ew),Math.round(24*z));
      c.globalAlpha=a; c.fillStyle='rgba('+D.rgb+',1)'; c.fillRect(x0,y0,Math.round(3*z),Math.round(24*z));
      c.fillStyle='rgba('+D.rgb+',.9)'; c.fillRect(x0+Math.round(3*z),y0+Math.round(21*z),Math.round((ew-3*z)*f),Math.round(3*z));
      c.fillStyle='rgba(255,246,220,1)'; hudText(D.n,x0+Math.round(11*z),y0+Math.round(15*z));
      c.textAlign='right'; c.fillStyle='rgba('+D.rgb+',1)'; hudText(Math.ceil(S.act[D.k])+'S',x0+Math.round(ew-8*z),y0+Math.round(15*z)); c.textAlign='left';
      x0+=Math.round(ew+8*z);
    }
  }
  c.restore();
}
// PARTY-MODULE-END (the next party builds add their code above this line)
'@

SubRx @'
var VER='26.87';
'@ @'
var VER='26.88';
'@

$pat = "(?m)^  now:'v26\.87:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.88: Kills drop timed power-ups: a bottomless clip, double damage and rapid fire. Check 26.88 fails on v26.87',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
