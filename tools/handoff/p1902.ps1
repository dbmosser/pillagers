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

# THE SECTOR MAP LABELS NEVER PRINT OVER EACH OTHER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawMapOverlay(){
'@ @'
// v19.02, SEEN ON THE MAP SCREENSHOT (2026-10-07): THE SECTOR MAP LABELS NEVER PRINT OVER EACH OTHER. Every marker wrote its own
// name where it stood, so on a busy map BLAST FREEZER - LOCKED, STRONGBOX and CACHE printed into one smear, ENCAMPMENT across
// PACKING FLOOR, SEAL 0% across CHILL ROW and EXTRACT C across THE LONG DOCK. The map is drawn as before, but its labels are
// gathered as it draws (mapLabelQueue) and placed at the end, most important first: the extractions and the waypoint, then locked
// rooms and the seal, then the peddler, survivors and hot ground, then caches and strongboxes, then anything else, and the faint
// zone names last. A label that would land on one already placed moves up or down (or aside) to the nearest free spot; a zone
// name or minor label with no free spot is left out rather than smeared. The header and the SURVEYED line never move. A label
// and the line under it (EXTRACT C and closes in 3 min) move together. Every label keeps its own font, colour and alignment.
function mapLabelRect(L,dx,dy){
  var m=L.m, w=L.w, fp=L.fp, x=L.x, y=L.y, l, t;
  l=(L.ta==='center')?x-w/2:((L.ta==='right'||L.ta==='end')?x-w:x);
  t=(L.tb==='middle')?y-fp/2:((L.tb==='top'||L.tb==='hanging')?y:y-fp*0.82);
  return {l:l*m.a+m.e+(dx||0), t:t*m.d+m.f+(dy||0), r:(l+w)*m.a+m.e+(dx||0), b:(t+fp*1.05)*m.d+m.f+(dy||0)};
}
function mapPlaceLabels(Q,hdrY,fn){
  var zn={}, i, j, G2=[], cur=null, placed=[], out=[], L, P0, k, tries, ok, dx, dy, r, rr, gh, gw;
  if(!Q.length) return 0;
  try{ ((G&&G.map&&G.map.zones)||[]).forEach(function(z){ if(z&&z.name) zn[z.name]=1; }); }catch(_z){}
  function pri(L){ var t=String(L.s);
    if((hdrY!==null&&L.y<=hdrY+2)||(/^SURVEYED|^what you walk/).test(t)) return 9;
    if(zn[t]||L.ga<0.6) return 0;
    if((/^EXTRACT |^WAYPOINT/).test(t)) return 6;
    if((/LOCKED|^SEAL/).test(t)) return 5;
    if((/^HOT GROUND|^PEDDLER|^SURVIVOR|^ENCAMPMENT/).test(t)) return 4;
    if((/^CACHE|^STRONGBOX/).test(t)) return 3;
    return 2; }
  for(i=0;i<Q.length;i++){
    L=Q[i]; L.p=pri(L);
    if(cur&&L.p!==9&&cur.p!==9&&L.ta===cur.last.ta&&Math.abs(L.x-cur.last.x)<1&&L.y>cur.last.y&&L.y-cur.last.y<2.4*Math.max(L.fp,cur.last.fp)){ cur.items.push(L); cur.last=L; cur.p=Math.max(cur.p,L.p); continue; }
    cur={items:[L],last:L,p:L.p,i:i}; G2.push(cur);
  }
  G2.forEach(function(g){ var u=null; g.items.forEach(function(L){ var q=mapLabelRect(L,0,0); u=u?{l:Math.min(u.l,q.l),t:Math.min(u.t,q.t),r:Math.max(u.r,q.r),b:Math.max(u.b,q.b)}:q; }); g.r=u; });
  function hits(a){ for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+2&&b.l<a.r+2&&a.t<b.b+1&&b.t<a.b+1) return true; } return false; }
  G2.slice().sort(function(a,b){ return (b.p-a.p)||(a.i-b.i); }).forEach(function(g){
    gh=g.r.b-g.r.t; gw=g.r.r-g.r.l; ok=false;
    if(g.p===9){ placed.push(g.r); g.dx=0; g.dy=0; out.push(g); return; }
    tries=[[0,0],[0,-(gh+3)],[0,gh+3],[0,-2*(gh+3)],[0,2*(gh+3)],[-(gw*0.6),0],[gw*0.6,0],[0,-3*(gh+3)],[0,3*(gh+3)]];
    for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(!hits(r)){ ok=true; g.dx=dx; g.dy=dy; placed.push(r); out.push(g); } }
    if(!ok&&g.p>=3){ g.dx=0; g.dy=0; placed.push(g.r); out.push(g); }
  });
  out.sort(function(a,b){ return a.i-b.i; });
  out.forEach(function(g){ g.items.forEach(function(L){
    ctx.save(); try{ ctx.setTransform(L.m); }catch(_t){}
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
    (fn||CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1));
    ctx.restore(); }); });
  return out.length;
}
function drawMapOverlay(){
  var had=Object.prototype.hasOwnProperty.call(ctx,'fillText'), prev=ctx.fillText, Q=[], hdrY=null, done=false;
  ctx.fillText=function(s,x,y){
    var t=String(s), fm=(/([\d.]+)px/).exec(String(ctx.font)), fp=fm?parseFloat(fm[1]):12;
    if(t==='SECTOR MAP') hdrY=y;
    Q.push({s:s,x:x,y:y,font:ctx.font,fs:ctx.fillStyle,ta:ctx.textAlign,tb:ctx.textBaseline,ga:ctx.globalAlpha,m:ctx.getTransform(),fp:fp,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,t).width});
  };
  try{ drawMapOverlayRaw(); }
  finally{
    if(had) ctx.fillText=prev; else delete ctx.fillText;
    try{ mapPlaceLabels(Q,hdrY,had?prev:null); done=true; }catch(_ml){}
    if(!done){ Q.forEach(function(L){ ctx.save(); try{ ctx.setTransform(L.m); }catch(_t){} ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga; (had?prev:CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x,L.y); ctx.restore(); }); }
  }
}
function drawMapOverlayRaw(){
'@

SubRx @'
var VER='19.01';
'@ @'
var VER='19.02';
'@

$pat = "(?m)^  now:'v19\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.02: Every label on the sector map is readable; none print over each other. Check 19.02 fails on v19.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
