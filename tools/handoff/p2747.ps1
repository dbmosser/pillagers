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

# THE GOLDEN CLUE HUNT IS CUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  clueTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  clueDraw(c);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@ @'
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@

SubRx @'
  clueMarks(out);
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@ @'
  goldMarks(out);   // v27.47 (nocluehunt): the golden enemy, on the maps when it is near
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@

SubRx @'
// v26.xx (flow13), HIS YES (2026-10-14) to suggestion 3, THE GOLDEN-ENEMY CLUE HUNT: "three clues shrink a circle toward the every-raid golden enemy". Four seconds into a raid
// that has a golden enemy (flow12), three CLUE PROPS are laid on open reachable ground (the side stream CLUE.tag of the seed: at least 450 from the drop, 650 from each other, 300 from
// any extraction ring, off the strongholds): a DROPPED SCANNER, a GOLD DUST TRAIL and a CHIRPING BEACON. From the start the maps show a SEARCH CIRCLE 1,400 across that has the golden
// enemy inside it, and the callout says so. Each clue is TAKEN by walking within 55 of it (the callout CLUE n/3 names it, sparks), and each one shrinks the circle to 900, then 520,
// then 220, the golden enemy always inside, never in the middle (the circle keeps a fixed offset from it per stage, from the side stream, so it follows the golden enemy as it
// walks). With all three taken the mark pins to the edge of the minimap as an arrow. The props chirp on the HUD (a ring that spreads every two seconds) and show on the minimap
// and the sector map only within 600 of you. When the golden enemy dies the hunt is over: the circle and the props are gone. DEMO and CAREER are the same.
var CLUE={tag:66,R:[1400,900,520,220],pick:55,minD:450,sep:650,shown:600};
var CLUE_KINDS=['scanner','dust','beacon'];
var CLUE_TXT={scanner:'DROPPED SCANNER',dust:'GOLD DUST TRAIL',beacon:'CHIRPING BEACON'};
function clueS(){ var S=flowS(); if(!S.clue) S.clue={props:null,n:0,done:0,off:null,lx:0,ly:0}; return S.clue; }
function clueLayout(){
  var p=G.player, props=[];
  sideStream((G.seed>>>0)||1,CLUE.tag,function(){
    var k, tries, x, y, ok, j;
    for(k=0;k<3;k++){
      for(tries=0;tries<200;tries++){
        x=250+rr()*(WORLD_W-500); y=250+rr()*(WORLD_H-500);
        if(Math.hypot(x-p.x,y-p.y)<CLUE.minD) continue;
        ok=1; for(j=0;j<props.length;j++) if(Math.hypot(x-props[j].x,y-props[j].y)<CLUE.sep) ok=0;
        if(!ok||!spotFree(G.map,x,y,30)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)||flowZoneNear(x,y,300)||shAt(x,y,80)) continue;
        props.push({kind:CLUE_KINDS[k],x:x,y:y,got:0}); break;
      }
    }
  });
  return props;
}
function clueCircle(C){
  if(C.mir) return C.mir;   // v27.18 (coop5): the circle as the host has it, for a linked window
  var S=G.flow.gold, e=S&&S.ref, st=Math.min(3,Math.round(C.n/Math.max(1,C.props.length)*3)), R=CLUE.R[st], gx, gy, o=C.off[st];
  if(e&&e.hp>0){ gx=e.x; gy=e.y; C.lx=gx; C.ly=gy; } else { gx=C.lx; gy=C.ly; }
  return {x:gx+Math.cos(o.a)*o.d*R,y:gy+Math.sin(o.a)*o.d*R,r:R,st:st};
}
function clueTick(dt){
  var S=G.flow.gold, C=clueS(), p=G.player, i, pr;
  if(flowPeer()){ cluePeerTick(dt); return; }   // v27.18 (coop5): a linked player 2 window lays out no hunt, it keeps the host one (clueNetTake)
  if(C.done) return;
  if(!C.props){
    if(!S||!S.ref||(G.t||0)<4) return;
    C.props=clueLayout(); C.off=[]; C.lx=S.ref.x; C.ly=S.ref.y;
    sideStream((G.seed>>>0)||1,CLUE.tag+1,function(){ var k; for(k=0;k<4;k++) C.off.push({a:rr()*6.2832,d:0.1+rr()*0.4}); });
    try{ say('GOLDEN ENEMY','info',{sub:'SEARCH CIRCLE ON THE MAP'}); }catch(_cs){}
    return;
  }
  if(S&&S.dead){ C.done=1; return; }
  if(!p||p.downed||p.dying) return;
  for(i=0;i<C.props.length;i++){
    pr=C.props[i];
    if(pr.got||Math.hypot(p.x-pr.x,p.y-pr.y)>=CLUE.pick) continue;
    pr.got=1; C.n++;
    try{ spark(pr.x,pr.y,'#ffe08a',14,200); say('CLUE '+C.n+'/'+C.props.length,'obj',{sub:CLUE_TXT[pr.kind]}); }catch(_cp){}
  }
}
function clueMarks(out){
  var C=G.flow&&G.flow.clue, p=G.player, i, pr, c;
  if(!C||!C.props||C.done) return;
  c=clueCircle(C);
  out.push({x:c.x,y:c.y,r:c.r,col:'#ffc72e',shape:'dia',kind:'gold',txt:'GOLDEN ENEMY  '+(C.props.length-C.n)+' CLUES',pin:(c.st>=3)?1:0,a:1});
  for(i=0;i<C.props.length;i++){
    pr=C.props[i];
    if(!pr.got&&Math.hypot(p.x-pr.x,p.y-pr.y)<CLUE.shown) out.push({x:pr.x,y:pr.y,r:0,col:'#ffe08a',shape:'sq',kind:'clue',txt:'CLUE',pin:0,a:1});
  }
}
function clueDraw(c){
  var C=G.flow&&G.flow.clue, i, k, pr, s, z, t=G.t||0, ph, u;
  if(!C||!C.props||C.done) return;
  z=Math.max(1,hudRes());
  c.save();
  for(i=0;i<C.props.length;i++){
    pr=C.props[i]; if(pr.got) continue;
    s=w2s(pr.x,0,pr.y);
    if(s.x<-100||s.y<-100||s.x>W+100||s.y>H+100) continue;
    ph=(t*0.5+i*0.33)%1; u=z;
    c.strokeStyle='rgba(255,224,138,'+(0.8*(1-ph)).toFixed(3)+')'; c.lineWidth=2*u;
    c.beginPath(); c.arc(s.x,s.y,(10+60*ph)*u,0,6.2832); c.stroke();
    c.fillStyle='rgba(255,224,138,.9)';
    if(pr.kind==='scanner'){
      c.fillStyle='rgba(60,70,80,.95)'; c.fillRect(s.x-6*u,s.y-4*u,12*u,8*u);
      c.fillStyle='rgba(120,230,255,'+(0.5+0.5*Math.sin(t*6)).toFixed(3)+')'; c.fillRect(s.x-3*u,s.y-2*u,6*u,4*u);
    } else if(pr.kind==='dust'){
      for(k=0;k<6;k++){ c.beginPath(); c.arc(s.x+(k-2.5)*9*u,s.y+Math.sin(t*3+k)*3*u,2.2*u,0,6.2832); c.fill(); }
    } else {
      c.fillStyle='rgba(60,70,80,.95)'; c.fillRect(s.x-2.5*u,s.y-14*u,5*u,16*u);
      c.fillStyle='rgba(255,224,138,'+(0.5+0.5*Math.sin(t*9)).toFixed(3)+')'; c.beginPath(); c.arc(s.x,s.y-15*u,3.5*u,0,6.2832); c.fill();
    }
  }
  c.restore();
}

'@ @'
// v27.47 (nocluehunt), HIS ANSWER (2026-10-14): "GOLDEN CLUE HUNT: CUT it, removing its clues, marks, words and checks. The golden enemy itself stays, every raid." The hunt (three clue props, the search circle that
// shrank to the golden enemy, the CLUE n/3 callouts and every mark of them) is gone, and with it the words and the checks that named it. THE GOLDEN ENEMY STAYS, EVERY RAID: one machine or hostile pillager is
// gilded once the raid is 3 s old exactly as before (flow12), and says so once (GOLDEN ENEMY, KILL IT FOR THE HOARD). There is no puzzle to find it: it shows as a gold mark on the minimap and the sector map while it is
// within GOLD_NEAR (900) of you, and its shine draws wherever it is on screen. It drops its hoard as before.
var GOLD_NEAR=900;
function goldMarks(out){
  var S=G.flow&&G.flow.gold, e, p=G.player;
  if(!S||!S.ref||S.dead||!p) return;
  e=S.ref;
  if(!(e.hp>0)||Math.hypot(e.x-p.x,e.y-p.y)>GOLD_NEAR) return;
  out.push({x:e.x,y:e.y,r:0,col:'#ffc72e',shape:'dia',kind:'gold',txt:'GOLDEN ENEMY',pin:0,a:1});
}

'@

SubRx @'
function clueNetOut(){
  var C=G.flow&&G.flow.clue, a=[], i, c;
  if(!C||!C.props) return 0;
  if(C.done) return [1];
  c=clueCircle(C);
  for(i=0;i<C.props.length&&i<3;i++) a.push([CLUE_KINDS.indexOf(C.props[i].kind),Math.round(C.props[i].x),Math.round(C.props[i].y),C.props[i].got?1:0]);
  return [0,C.n|0,Math.round(c.x),Math.round(c.y),Math.round(c.r),c.st|0,a];
}
function clueNetTake(a){
  var C=clueS(), i, r, pr, first;
  if(!a||typeof a.length!=='number') return 0;
  if(a[0]){ C.done=1; return 1; }
  if(a.length<7||!a[6]||typeof a[6].length!=='number'||!isFinite(+a[2])||!isFinite(+a[3])||!isFinite(+a[4])) return 0;
  first=!C.props;
  if(first){ C.props=[]; C.off=[]; C.lx=0; C.ly=0; }
  for(i=0;i<a[6].length&&i<3;i++){
    r=a[6][i]; if(!r||r.length<4||!isFinite(+r[1])||!isFinite(+r[2])) continue;
    pr=C.props[i];
    if(!pr){ pr={kind:CLUE_KINDS[r[0]|0]||'scanner',x:0,y:0,got:0}; C.props[i]=pr; }
    pr.x=+r[1]; pr.y=+r[2]; if(r[3]) pr.got=1;
  }
  C.n=a[1]|0;
  C.mir={x:+a[2],y:+a[3],r:+a[4],st:a[5]|0};
  if(first){ try{ say('GOLDEN ENEMY','info',{sub:'SEARCH CIRCLE ON THE MAP'}); }catch(_cs){} }
  return 1;
}
// a clue taken, by anyone: marked, counted, said. Returns whether it was new.
function clueTaken(ix,byOther){
  var C=G.flow&&G.flow.clue, pr;
  if(!C||!C.props||C.done||!C.props[ix]||C.props[ix].got) return false;
  pr=C.props[ix]; pr.got=1; C.n=(C.n|0)+1;
  try{ spark(pr.x,pr.y,'#ffe08a',14,200); say('CLUE '+C.n+'/'+C.props.length,'obj',{sub:CLUE_TXT[pr.kind]+(byOther?'  YOUR PARTNER':'')}); }catch(_cp){}
  return true;
}
function cluePeerTick(dt){
  var C=clueS(), p=G.player, i, pr;
  if(!C.props||C.done||!p||p.downed||p.dying) return;
  for(i=0;i<C.props.length;i++){
    pr=C.props[i];
    if(!pr||pr.got||Math.hypot(p.x-pr.x,p.y-pr.y)>=CLUE.pick) continue;
    if(clueTaken(i,0)) flowNetPost({k:'clue',i:i});
  }
}

'@ @'
// v27.47 (nocluehunt): the clue words and the clue mirror are gone with the hunt; the golden enemy mirror above stays

'@

SubRx @'
  o.g=goldNetOut(); o.c=clueNetOut();   // v27.18 (coop5): and the golden enemy and the clue hunt
'@ @'
  o.g=goldNetOut();   // v27.18 (coop5): and the golden enemy
'@

SubRx @'
  if(fl.c) clueNetTake(fl.c);   // v27.18 (coop5): the clue hunt
  if(fl.r) goalsNetTake(fl.r);   // v27.27 (coop8): the run goals
'@ @'
  if(fl.r) goalsNetTake(fl.r);   // v27.27 (coop8): the run goals
'@

SubRx @'
  if(m.k==='clue'){
    if(NET.role!=='host'||!netEntsHost()||!flowOn()) return 'ignored';
    return clueTaken(m.i|0,1)?'clue':'gone';
  }
  if(m.k==='air'){
'@ @'
  if(m.k==='air'){
'@

SubRx @'
    if(ix>=0){ e=G.ents[ix]; S.hp0=e.maxhp||e.hp; goldMake(e); S.ref=e; }
'@ @'
    if(ix>=0){ e=G.ents[ix]; S.hp0=e.maxhp||e.hp; goldMake(e); S.ref=e; }   // v27.47 (nocluehunt): said once, there is no hunt
    if(ix>=0){ try{ say('GOLDEN ENEMY','info',{sub:'KILL IT FOR THE HOARD'}); }catch(_gsy){} }
'@

SubRx @'
  if(e&&!S.dead){ if(!e.golden){ e.golden=1; e.r=Math.round(e.r*GOLD.big); } S.ref=e; }
'@ @'
  if(e&&!S.dead){ if(!e.golden){ e.golden=1; e.r=Math.round(e.r*GOLD.big); } if(!S.ref){ try{ say('GOLDEN ENEMY','info',{sub:'KILL IT FOR THE HOARD'}); }catch(_gsy){} } S.ref=e; }   // v27.47 (nocluehunt): said once on this window too
'@

SubRx @'
var VER='27.46';
'@ @'
var VER='27.47';
'@

$pat = "(?m)^  now:'v27\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.47: The golden enemy hunt with clues is gone; the golden enemy is still in every raid. Check 27.47 fails on v27.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
