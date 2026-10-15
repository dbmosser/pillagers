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

# THE GOLDEN ENEMY, EVERY RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  goldTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@ @'
  goldDraw(c);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow12), HIS ANSWERS (2026-10-12, 11 a: "a rare GOLDEN enemy with big loot"; 2026-10-13, 27: "the golden enemy appears every raid"). THE GOLDEN ENEMY, every raid.
// Once the raid is 3 s old one machine or hostile pillager is gilded: picked on the side stream GOLD.tag of the seed from those at least 700 from the drop (a Crawler, Sentry,
// Bulwark, Howler, Listener or a hostile pillager; never the Overseer, a hire or a bystander), so the same seed gilds the same one and the seeded stream does not move. It has
// GOLD.hp (3) times the health and is a tenth bigger. It is drawn gold on the HUD (a glow, an ellipse on the ground, three sparks and GOLDEN over it) wherever it is on screen.
// WHEN IT DIES, by anyone's hand or none, it leaves a GOLDEN HOARD where it fell: three jackpot rolls and two cache rolls on a side stream, marked on the maps until opened, with
// GOLDEN ENEMY DOWN in the alert. If nothing qualifies at 3 s it looks again every second. DEMO and CAREER are the same.
var GOLD={tag:65,hp:3,big:1.1,minD:700,kinds:{crawler:1,sentry:1,raider:1,bulwark:1,howler:1,listener:1}};
function goldS(){ var S=flowS(); if(!S.gold) S.gold={ref:null,hp0:0,dead:0,tried:0}; return S.gold; }
function goldOk(e,p){
  return !!e&&e.hp>0&&!!GOLD.kinds[e.kind]&&!e.boss&&!e.merc&&!e.friendlyPC&&!e.neutral&&!e.summoned&&!e.golden&&!(e.kind==='raider'&&!e.hostile)&&Math.hypot(e.x-p.x,e.y-p.y)>=GOLD.minD;
}
// the index in G.ents the seed gilds (-1 when nothing qualifies); no body is changed
function goldPickIx(){
  var p=G.player, L=[], i, ix=-1;
  for(i=0;i<G.ents.length;i++) if(goldOk(G.ents[i],p)||G.ents[i]&&G.ents[i].golden&&G.ents[i]===goldS().ref) L.push(i);
  if(!L.length) return -1;
  sideStream((G.seed>>>0)||1,GOLD.tag,function(){ ix=L[Math.floor(rr()*L.length)]; });
  return ix;
}
function goldMake(e){
  e.golden=1; e.maxhp=Math.round((e.maxhp||e.hp)*GOLD.hp); e.hp=e.maxhp; e.r=Math.round(e.r*GOLD.big);
  return e;
}
function goldDrop(x,y){
  var L=[], c=null, G0=goldS(), n=(G0.n=(G0.n|0)+1), seed=(((G.seed>>>0)^Math.imul(n,7919))>>>0)||1;
  sideStream(seed,GOLD.tag+1,function(){ var k; for(k=0;k<3;k++) L.push(rollLoot(LOOT.jackpot)); for(k=0;k<2;k++) L.push(rollLoot(LOOT.cache)); });
  sideStream(seed,GOLD.tag+2,function(){ c=setLoot(mkContainer(x+16,y+8,'jackpot'),L); });
  c.time=2.6; c.tag='GOLDEN HOARD'; c.wreck=1; G.containers.push(c); evS().wrecks.push(c);
  try{ spark(x,y,'#ffc72e',30,320); flash(x,y,260,'#ffc72e',.5); }catch(_gd){}
  try{ say('GOLDEN ENEMY DOWN','obj',{sub:'SEARCH THE HOARD'}); }catch(_gs){}
  return c;
}
function goldTick(dt){
  var S=goldS(), p=G.player, ix, e;
  if(!S.ref&&!S.dead){
    if((G.t||0)<3) return;
    S.tried=(S.tried||0)+dt; if(S.tried<1&&S.tries) return;
    S.tries=(S.tries|0)+1; S.tried=0;
    ix=goldPickIx();
    if(ix>=0){ e=G.ents[ix]; S.hp0=e.maxhp||e.hp; goldMake(e); S.ref=e; }
    return;
  }
  e=S.ref;
  if(e&&!S.dead&&(!(e.hp>0)||G.ents.indexOf(e)<0)){ S.dead=1; S.dx=e.x; S.dy=e.y; goldDrop(e.x,e.y); }
}
function goldDraw(c){
  var S=G.flow&&G.flow.gold, e, s, q, z, t=G.t||0, pu, gr, R, k, a, cy;
  if(!S||!S.ref||S.dead) return;
  e=S.ref; if(!(e.hp>0)) return;
  q=ZOOM(); z=Math.max(1,hudRes()); s=w2s(e.x,0,e.y); R=e.r*q;
  if(s.x<-R*4||s.y<-R*4||s.x>W+R*4||s.y>H+R*4) return;
  pu=0.55+0.45*Math.sin(t*3.4+e.x*0.02);
  c.save(); c.globalCompositeOperation='lighter';
  gr=c.createRadialGradient(s.x,s.y,0,s.x,s.y,R*2.6);
  gr.addColorStop(0,'rgba(255,199,46,'+(0.30*pu).toFixed(3)+')'); gr.addColorStop(1,'rgba(255,170,30,0)');
  c.fillStyle=gr; c.beginPath(); c.arc(s.x,s.y,R*2.6,0,6.2832); c.fill();
  c.strokeStyle='rgba(255,210,80,'+(0.45+0.35*pu).toFixed(3)+')'; c.lineWidth=2.5*z;
  c.beginPath(); c.ellipse(s.x,s.y+2*z,R*1.35,Math.max(3*z,R*0.55),0,0,6.2832); c.stroke();
  cy=s.y-R*1.1; c.fillStyle='rgba(255,240,180,.9)';
  for(k=0;k<3;k++){ a=t*2.2+k*2.094; c.fillRect(s.x+Math.cos(a)*R*1.3-1.2*z,cy+Math.sin(a)*R*0.9-1.2*z,2.4*z,2.4*z); }
  c.restore();
  c.save(); c.textAlign='center'; c.font=hudFS(TYPE.micro); c.fillStyle='#ffd24a'; hudText('GOLDEN',s.x,s.y-R*1.9-LH(6)*z); c.restore();
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.91';
'@ @'
var VER='26.92';
'@

$pat = "(?m)^  now:'v26\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.92: Every raid gilds one tough golden enemy that glows and drops a golden hoard when it dies. Check 26.92 fails on v26.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
