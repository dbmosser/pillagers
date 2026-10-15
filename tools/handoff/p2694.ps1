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

# GOLDEN ENEMY CLUE HUNT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  clueTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@ @'
  clueDraw(c);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@

SubRx @'
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@ @'
  clueMarks(out);
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
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
  var S=G.flow.gold, e=S&&S.ref, st=Math.min(3,Math.round(C.n/Math.max(1,C.props.length)*3)), R=CLUE.R[st], gx, gy, o=C.off[st];
  if(e&&e.hp>0){ gx=e.x; gy=e.y; C.lx=gx; C.ly=gy; } else { gx=C.lx; gy=C.ly; }
  return {x:gx+Math.cos(o.a)*o.d*R,y:gy+Math.sin(o.a)*o.d*R,r:R,st:st};
}
function clueTick(dt){
  var S=G.flow.gold, C=clueS(), p=G.player, i, pr;
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
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.93';
'@ @'
var VER='26.94';
'@

$pat = "(?m)^  now:'v26\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.94: Three clue props shrink a search circle on the map toward the raid golden enemy. Check 26.94 fails on v26.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
