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

# PILLAGER BOTS: RED COATS, GOLD BODY, NOTICE TELL, FALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function raiderCoat(e){
  var r=raiderRole(e), c=e.coat, a, b, i, o='#';
'@ @'
function raiderCoat(e){
  var r=raiderRole(e), c=e.coat, a, b, i, o='#';
  // v32.xx (cw-botlook), HIS PICKS a18 A ("always in red clothes and always have angry eyebrows") and a19 D (one crew colour): every hostile pillager bot wears
  // the same dark red coat whatever its role or state, and the role shows through its gear only. A hire (no role here) and a neutral keep their own colours,
  // red means enemy. The golden enemy wears a gold coat that goldBodyBegin turns solid gold.
  if(r&&e.hostile!==false) return e.golden?'#d9a830':'#7a2f2a';
'@

SubRx @'
      wc.strokeStyle=INK; wc.lineWidth=1.2; wc.beginPath(); wc.moveTo(_ex+_gs*2.9,ty-32.6); wc.lineTo(_ex-_gs*2.6,ty-29.9); wc.stroke();   // the brow bar
'@ @'
      wc.strokeStyle=INK; wc.lineWidth=(st.tell>0)?2.2:1.2; wc.beginPath(); wc.moveTo(_ex+_gs*2.9,ty-32.6); wc.lineTo(_ex-_gs*2.6,ty-29.9); wc.stroke();   // the brow bar; v32.xx (cw-botlook) a22: 1 px thicker while the tell runs
      if(st.tell>0){ wc.save(); wc.globalCompositeOperation='lighter'; wc.fillStyle='rgba(255,59,48,.55)'; wc.beginPath(); wc.arc(_ex,ty-28.6,2.4,0,6.2832); wc.fill(); wc.restore(); wc.fillStyle='#ff3b30'; wc.beginPath(); wc.arc(_ex,ty-28.6,1.5,0,6.2832); wc.fill(); }   // v32.xx (cw-botlook) a22: the red eye flare
'@

SubRx @'
      var _rm=null;
'@ @'
      var _rm=null, _tlf=0, _tlh=0, _gb=null;   // v32.xx (cw-botlook): the body tell and the golden body
'@

SubRx @'
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline
'@ @'
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline
      _gb=goldBodyBegin(e2);   // v32.xx (cw-botlook) a21 B: the golden enemy is drawn inside the gold filter with a shine sweeping across it
'@

SubRx @'
      else if(e2.kind==='raider'&&raiderGetUpBar(e2))
'@ @'
      else if(e2.kind==='raider'&&raiderGetUpBar(e2)&&(_tlf=raiderTellF(e2),_tlh=raiderTellBegin(_tlf),_svd+=_tlh,1))
'@

SubRx @'
{own:e2,team:(e2.merc||e2.friendly)?'ally':'foe',merc:e2.merc?1:0,
'@ @'
{own:e2,team:(e2.merc||e2.friendly)?'ally':'foe',merc:e2.merc?1:0,tell:_tlf,
'@

SubRx @'
build:e2.build}),drawRoleMark(e2);
'@ @'
build:e2.build}),drawRoleMark(e2),raiderTellEnd(_tlh),(_svd-=_tlh);
'@

SubRx @'
      rimClose(_rm);   // v26.xx (aip1)
'@ @'
      goldBodyEnd(_gb);   // v32.xx (cw-botlook) a21 B
      rimClose(_rm);   // v26.xx (aip1)
'@

SubRx @'
      try{ rimAbort(); }catch(_ra){}   // v26.xx (aip1): the world canvas first, whatever the body left
'@ @'
      try{ goldBodyAbort(); }catch(_gba){}   // v32.xx (cw-botlook): the world canvas back first
      try{ rimAbort(); }catch(_ra){}   // v26.xx (aip1): the world canvas first, whatever the body left
'@

SubRx @'
function goldDraw(c){
  var S=G.flow&&G.flow.gold, e, s, q, z, t=G.t||0, pu, gr, R, k, a, cy;
'@ @'
// v32.xx (cw-botlook), HIS PICK a21 B: the golden enemy has a SOLID GOLD BODY with a shine sweeping across it. goldBodyBegin swaps the world canvas for a
// scratch one around the body draw; goldBodyEnd draws a slanted white strip 5 px wide at 30 percent across the silhouette for 0.4 s of every 2 s, then
// puts the scratch back inside wc.filter='sepia(1) saturate(3) hue-rotate(-12deg) brightness(1.1)'. One body per raid, so the cost is one small canvas.
// Drawing only: no random draw, nothing the sim reads.
var GOLDB={c:null,x:null,h:null};
function goldBodyBegin(e){
  var T, hw, up, dn, sx, sy, w, h, h1;
  if(!e||!e.golden||typeof wc==='undefined'||!wc||!wc.getTransform||!('filter' in wc)||(typeof G!=='undefined'&&G&&G.sim)||GOLDB.h) return null;
  try{
    T=wc.getTransform();
    if(!(T.a>0)||!(T.d>0)||T.b||T.c||!isFinite(e.x)||!isFinite(e.y)) return null;
    hw=(e.r*1.9+24)*T.a; up=(spriteTop(e)+40)*T.d; dn=(e.r*0.9+14)*T.d;
    sx=Math.floor(T.a*e.x+T.e-hw); sy=Math.floor(T.d*e.y+T.f-up); w=Math.ceil(hw*2)+4; h=Math.ceil(up+dn)+4;
    if(w<8||h<8||w>1400||h>1400) return null;
    if(!GOLDB.c){ GOLDB.c=document.createElement('canvas'); GOLDB.x=GOLDB.c.getContext('2d'); }
    if(!GOLDB.x) return null;
    if(GOLDB.c.width<w) GOLDB.c.width=w;
    if(GOLDB.c.height<h) GOLDB.c.height=h;
    GOLDB.x.setTransform(1,0,0,1,0,0); GOLDB.x.globalAlpha=1; GOLDB.x.globalCompositeOperation='source-over'; GOLDB.x.clearRect(0,0,w,h);
    GOLDB.x.setTransform(T.a,0,0,T.d,T.e-sx,T.f-sy);
    h1={w0:wc,sh0:shadowE,sx:sx,sy:sy,w:w,h:h,e:e,u:T.a,cx:T.a*e.x+T.e-sx};
    shadowE=function(x,y,rx,ry,a){ var w1=wc; wc=h1.w0; try{ h1.sh0(x,y,rx,ry,a); } finally{ wc=w1; } };   // the ground shadow stays on the world canvas, off the gold
    GOLDB.h=h1; wc=GOLDB.x;
    return h1;
  }catch(_gb){ goldBodyAbort(); return null; }
}
function goldBodyAbort(){
  var h=GOLDB.h;
  if(h){ wc=h.w0; shadowE=h.sh0; GOLDB.h=null; }
}
function goldBodyEnd(h){
  var x=GOLDB.x, f, c0, rg, tl;
  if(!h) return;
  wc=h.w0; shadowE=h.sh0; GOLDB.h=null;
  try{
    f=(((typeof G!=='undefined'&&G)?(G.t||0):0)%2)/0.4;
    if(f<1){
      rg=h.e.r*1.6*h.u; c0=h.cx+(f*2-1)*rg; tl=h.h*0.06;
      x.setTransform(1,0,0,1,0,0); x.globalCompositeOperation='source-atop'; x.fillStyle='rgba(255,255,255,.3)';
      x.beginPath(); x.moveTo(c0+tl,0); x.lineTo(c0+tl+5*h.u,0); x.lineTo(c0-tl+5*h.u,h.h); x.lineTo(c0-tl,h.h); x.closePath(); x.fill();
      x.globalCompositeOperation='source-over';
    }
    wc.save(); wc.setTransform(1,0,0,1,0,0); wc.filter='sepia(1) saturate(3) hue-rotate(-12deg) brightness(1.1)';
    wc.drawImage(GOLDB.c,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.restore();
  }catch(_ge){ try{ wc.restore(); }catch(_g2){} }
}
// v32.xx (cw-botlook), HIS PICK a22 ("A and B -- exclamation mark plus body tell"): the red mark over the head stays, and the body tells too. For 0.45 s after a
// pillager bot reads chase or alarm it hops 3*sin(pi*f) px, its eyes flare red with a 1.6x halo and its brows go 1 px thicker. The moment is stored on the
// bot (_tl) by the draw, so every window sees it; a bot first drawn already hunting does not hop.
function raiderTellF(e){
  var on, t, f;
  if(!e||typeof G==='undefined'||!G||G.sim||e.merc||e.friendly||e.friendlyPC||e.hostile===false) return 0;
  on=(e.state==='chase'||e.state==='alarm')?1:0; t=G.t||0;
  if(e._tlP===undefined){ e._tlP=on; return 0; }
  if(on&&!e._tlP) e._tl=t;
  e._tlP=on;
  if(typeof e._tl!=='number') return 0;
  f=(t-e._tl)/0.45;
  return (f>=0&&f<1)?Math.max(0.001,f):0;
}
function raiderTellBegin(f){ if(!(f>0)) return 0; wc.save(); wc.translate(0,-3*Math.sin(Math.PI*f)); return 1; }
function raiderTellEnd(h){ if(h) wc.restore(); }
// v32.xx (cw-botlook), HIS PICK a23 B: a pillager bot that dies is drawn as itself, tipping 85 degrees away from the player over 0.2 s, then fading over 0.5 s.
// Nothing remains after 0.7 s; the puff and sparks the death already makes stay. The snapshot is taken once at the death; hires and neutrals keep the old flat shape.
function raiderFallSnap(a,e){
  var o={}, q, p;
  if(!a||!e||e.kind!=='raider'||e.merc||e.friendly||e.friendlyPC||e.hostile===false) return 0;
  for(q in e) o[q]=e[q];
  p=(typeof G!=='undefined'&&G)?G.player:null;
  a.sg=(p&&e.x<p.x)?-1:1; a.op=o;
  return 1;
}
function raiderFallDraw(a,t){
  var o=a.op, x=a.x, y=a.y, k=Math.min(1,t/0.2), u=(t<0.2)?1:1-(t-0.2)/0.5, kb, r2, st;
  if(!(u>0)) return 0;
  kb=figOn()?figBuildK(o.build):null;
  st={own:o,team:'foe',merc:0,moving:false,sprint:false,ads:false,hurt:0,bulk:o.bulk||0,hair:o.hair,cut:o.cut,hat:o.hat,skin:o.skin,beard:o.beard,eyes:o.eyes,faceMark:o.faceMark,boots:o.boots,
      gloves:o.gloves,pack:o.pack,patch:o.patch,tattoo:o.tattoo,build:o.build};
  wc.save(); wc.globalAlpha=wc.globalAlpha*u;
  shadowE(x+1.5,y+2,12.5,5,0.5);
  wc.translate(x,y); wc.rotate(a.sg*1.4835*(1-(1-k)*(1-k))); wc.translate(-x,-y);
  OPX.ng=1;
  try{
    wc.save();
    if(kb){ wc.translate(x,y); wc.scale(FIG_SCALE*kb[0],FIG_SCALE*kb[1]); wc.translate(-x,-y); }
    try{ drawOpB(x,y,o.face||0,0,raiderCoat(o),clamp((o.bag?o.bag.length:0)/7,0,1),0,'none',0,st); } finally{ wc.restore(); }
    r2={}; for(k in o) r2[k]=o[k];
    r2.hp=1; r2.downed=false; r2.state='idle'; r2.roll=0; r2.moving=false;
    drawRoleMark(r2);
  } finally{ OPX.ng=0; wc.restore(); }
  return 1;
}
function goldDraw(c){
  var S=G.flow&&G.flow.gold, e, s, q, z, t=G.t||0, pu, gr, R, k, a, cy;
'@

SubRx @'
  gr=c.createRadialGradient(s.x,s.y,0,s.x,s.y,R*2.6);
  gr.addColorStop(0,'rgba(255,199,46,'+(0.30*pu).toFixed(3)+')'); gr.addColorStop(1,'rgba(255,170,30,0)');
  c.fillStyle=gr; c.beginPath(); c.arc(s.x,s.y,R*2.6,0,6.2832); c.fill();

'@ @'
  // v32.xx (cw-botlook), HIS PICK a21 B: the glow is dropped (the body itself is gold now); the ring, the sparkles and the label stay
'@

SubRx @'
  try{ gfxOnDeath(G.deathAnims[G.deathAnims.length-1]); }catch(_god){}
'@ @'
  try{ raiderFallSnap(G.deathAnims[G.deathAnims.length-1],e); }catch(_rfs){}   // v32.xx (cw-botlook) a23 B
  try{ gfxOnDeath(G.deathAnims[G.deathAnims.length-1]); }catch(_god){}
'@

SubRx @'
    k=1-f;
    wc.save(); wc.globalAlpha=0.85*k; wc.translate(a.x,a.y); wc.rotate(a.face+f*1.4); wc.scale(1-0.35*f,0.55+0.45*k);
'@ @'
    if(a.op){ try{ raiderFallDraw(a,f*0.8); }catch(_rfd){ try{ wc.restore(); }catch(_r1){} } continue; }   // v32.xx (cw-botlook) a23 B: a pillager bot falls as itself
    k=1-f;
    wc.save(); wc.globalAlpha=0.85*k; wc.translate(a.x,a.y); wc.rotate(a.face+f*1.4); wc.scale(1-0.35*f,0.55+0.45*k);
'@

SubRx @'
var VER='32.66';
'@ @'
var VER='32.67';
'@

$pat = "(?m)^  now:'v32\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.67: Enemy pillager bots all wear dark red, the golden one is solid gold with a shine, bots hop and flare red eyes when they spot you, and they fall over flat when they die. Check 32.67 fails on v32.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
