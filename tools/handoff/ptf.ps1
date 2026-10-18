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

# the corner of the raid HUD is one column, every item the same size (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #topright .trsub{ position:absolute; right:0; top:40px; line-height:16px; font-size:15px; font-weight:700; letter-spacing:.1em; color:var(--ash); }

'@ @'
  #topright .trsub{ position:absolute; right:0; top:40px; line-height:16px; font-size:15px; font-weight:700; letter-spacing:.1em; color:var(--ash); }
  body.trcol #topright{ clip-path:inset(50%); }   /* v30.xx (cw-trcol), HIS ORDER (2026-10-18): in a raid the credits, xp, stash and bag are rows of the HUD column drawn on the canvas, so the page text is clipped away there (it keeps its box, for whatever reads it) */

'@

SubRx @'
var _trLast='';

'@ @'
var _trLast='';
// v30.xx (cw-trcol), HIS ORDER (2026-10-18): "everything in the right hand upper corner should be in a vertical 1 by 1 list and they should all be the same size".
// In a raid the corner is ONE COLUMN from the top right corner down: credits, xp, stash and bag (career), notes logged (when there are notes), then the
// minimap, then the run info panel. One width for all of them (the run info panel's), one right edge, one gap between neighbours, one row height and one
// type size for the rows, and the minimap is a square as wide as the rows. The Settings minimap size (S, N, L) and the run info panel's size grip move the
// whole column together, so nothing in it is ever a different size from its neighbour. The wallet used to be page text in a bigger font with no plate; in
// a raid that text is clipped away (body.trcol) and the rows are drawn here on the HUD canvas, so they scale with the screen (hudRes) like the rest. The
// Undercroft and the menus keep the page text. His Q58 (one row in career) is replaced by this newer order.
var TRV={c:'0',x:'0',sv:'0',bv:'0',nn:-1,ns:''};   // the wallet figures as text, written by syncTopRight only when one changes
var TRG={z:1,bw:0,rh:0,gp:4,x:0,y0:16,n:0,yE:0,t:-1e9,hid:0};   // the column as last laid out: zoom-space numbers, except z and yE (screen px)
function trBW(){ return Math.round(LH(196)*mmSizeK()); }
function trGeo(){
  var g=TRG, T=G&&G.tel, n=0;
  g.z=(HUDZ.cond||1)*hudRes()*hudUserZ('cond');
  if(!trDemo()) n=4;
  if(T&&T.notes&&T.notes.length) n++;
  g.n=n; g.bw=trBW(); g.rh=16+LH(13); g.x=W-16-g.bw;
  g.yE=Math.ceil((g.y0+(n?n*g.rh+(n-1)*g.gp+g.gp:0))*g.z);   // where the next item (the minimap) starts, in screen px: under the last row and one gap
  return g;
}
// the column as one box for the things that keep clear of the corner (the extraction badge, the map header): from the first row to the minimap's bottom
function trBox(){
  var g=trGeo(), b=MMAP.box, E=EDGEBOX.trcol, y1;
  if(!g.n&&!b){ EDGEBOX.trcol=null; return; }
  if(!E) E=EDGEBOX.trcol={x:0,y:0,w:0,h:0};
  y1=b?(b.y+b.h):(g.yE-Math.round(g.gp*g.z));
  E.x=W-(16+g.bw)*g.z; E.y=g.y0*g.z; E.w=g.bw*g.z; E.h=Math.max(0,y1-E.y);
}
// the plate of the HUD panels (hudPanel: chamfer, one flat 88% fill, the 1px light edge of v31.03), drawn by hand so a row costs no closure and no gradient
function trPlate(x,y,w,h){
  var c=Math.max(0,Math.min(10,w/3,h/3)), d=Math.max(0,c-.5);
  ctx.beginPath(); ctx.moveTo(x+c,y); ctx.lineTo(x+w,y); ctx.lineTo(x+w,y+h); ctx.lineTo(x,y+h); ctx.lineTo(x,y+c); ctx.closePath();
  ctx.fillStyle='rgba(17,19,21,.88)'; ctx.fill();
  ctx.beginPath(); ctx.moveTo(x+.5+d,y+.5); ctx.lineTo(x+w-.5,y+.5); ctx.lineTo(x+w-.5,y+h-.5); ctx.lineTo(x+.5,y+h-.5); ctx.lineTo(x+.5,y+.5+d); ctx.closePath();
  ctx.strokeStyle='rgba(112,122,130,.95)'; ctx.lineWidth=1; ctx.stroke();
}
function trRow(i,lab,val){
  var g=TRG, y=g.y0+i*(g.rh+g.gp), by=y+8+LH(8);   // the same baseline as the run info title: pad 8 and LH(8) under the plate's top
  trPlate(g.x,y,g.bw,g.rh);
  ctx.textAlign='left'; ctx.fillStyle=UIC.tx_2; ctx.fillText(lab,g.x+8,by);
  ctx.textAlign='right'; ctx.fillStyle=UIC.tx_1; ctx.fillText(val,g.x+g.bw-8,by);
}
// drawn last in drawHUD, so the rows stay over the sector map and the backpack the way the page text did
function trColDraw(){
  var g=trGeo(), T=G&&G.tel, i=0, nn=(T&&T.notes)?T.notes.length:0;
  if(!(g.n>0)||!G||!G.player) return 0;
  TRG.t=(typeof performance!=='undefined')?performance.now():Date.now();
  if(nn&&TRV.nn!==nn){ TRV.nn=nn; TRV.ns=String(nn); }
  ctx.save(); hudZoomIn('cond',W,0);
  ctx.globalAlpha=1; ctx.font=FS(TYPE.label); ctx.textBaseline='alphabetic';
  if(!trDemo()){ trRow(i++,'credits',TRV.c); trRow(i++,'xp',TRV.x); trRow(i++,'stash',TRV.sv); trRow(i++,'backpack',TRV.bv); }
  if(nn) trRow(i++,'notes logged',TRV.ns);
  ctx.textAlign='left';
  ctx.restore();
  return i;
}
// the page text is hidden while the rows were drawn in the last 200 ms; a frame cap that skips frames cannot make it flicker
function trHide(now){
  var on=(now-TRG.t<200)?1:0;
  if(on===TRG.hid) return;
  TRG.hid=on;
  try{ document.body.classList.toggle('trcol',!!on); }catch(_e){}
}

'@

SubRx @'
  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small> <span class="trsub">STASH '+sv.toLocaleString()+' BAG '+bv.toLocaleString()+'</span>';   // v28.xx (cw-stashbag): spaces, so the text reads right when copied

'@ @'
  TRV.c=c; TRV.x=x; TRV.sv=sv.toLocaleString(); TRV.bv=bv.toLocaleString();   // v30.xx (cw-trcol): the same figures as text, for the rows the raid HUD draws
  el.innerHTML=c+' <small>CREDITS</small> '+x+' <small>XP</small> <span class="trsub">STASH '+sv.toLocaleString()+' BAG '+bv.toLocaleString()+'</span>';   // v28.xx (cw-stashbag): spaces, so the text reads right when copied

'@

SubRx @'
function mmRect(){
  var R=hudRes(), s=Math.round(216*R*mmSizeK()), T=G&&G.tel, top;   // v26.xx (settings7): MINIMAP SIZE
  top=Math.ceil(topRightBottom()+8+((T&&T.notes&&T.notes.length)?LH(20):0));
  top=Math.max(Math.round(16*R),top);
  return {x:Math.round(W-16*R-s),y:top,w:s,h:s};
}

'@ @'
function mmRect(){
  // v30.xx (cw-trcol), HIS ORDER (2026-10-18): the minimap is a square as wide as the rows above it and the run info panel under it (the Settings size S, N, L
  // widens the whole column), one gap under the last row, and never taller than half the screen (a run info panel zoomed to the limit). It was 216 wide above a 268 wide panel.
  var g=trGeo(), s=Math.min(Math.round(g.bw*g.z),Math.round(H*0.5));   // v26.xx (settings7): MINIMAP SIZE
  return {x:Math.round(W-16*g.z-s),y:g.yE,w:s,h:s};
}

'@

SubRx @'
  r=mmRect(); R=hudRes(); sc=r.w/mmSpan(); cut=Math.round(10*R);   // v26.xx (settings7): MINIMAP ZOOM

'@ @'
  r=mmRect(); R=hudRes(); sc=r.w/mmSpan(); cut=Math.round(10*TRG.z);   // v26.xx (settings7): MINIMAP ZOOM; v30.xx (cw-trcol): the corner is cut like the panels beside it

'@

SubRx @'
ctx.strokeStyle='rgba(245,183,59,.62)'; ctx.lineWidth=Math.max(1,R); ctx.stroke(); MMAP.ops++;
'@ @'
ctx.strokeStyle='rgba(112,122,130,.95)'; ctx.lineWidth=Math.max(1,TRG.z); ctx.stroke(); MMAP.ops++;   // v30.xx (cw-trcol): the same 1px light edge as every plate in the column (v31.03), no amber
'@

SubRx @'
  try{ drawMinimap(); }catch(_mm){ MMAP.box=null; }   // v24.xx (minimap1): his "add minimap", top right, before CONDITIONS so it can start below it

'@ @'
  try{ drawMinimap(); }catch(_mm){ MMAP.box=null; }   // v24.xx (minimap1): his "add minimap", top right, before CONDITIONS so it can start below it
  try{ trBox(); }catch(_tb){}   // v30.xx (cw-trcol): the column's box for everything that keeps clear of the corner

'@

SubRx @'
var pad=8, lh=LH(13), bw=Math.round(LH(196)), inner=bw-pad*2;
'@ @'
var pad=8, lh=LH(13), bw=trBW(), inner=bw-pad*2;
'@

SubRx @'
    by=Math.max(by,Math.ceil((topRightBottom()+8+((T.notes&&T.notes.length)?LH(20):0))/_cz));   // v12.05: and under the notes-logged line when there is one
    if(MMAP.box) by=Math.max(by,Math.ceil((mmBottom()+Math.round(10*hudRes()))/_cz));   // v24.xx (minimap1): and under the minimap

'@ @'
    var _tg=trGeo();   // v30.xx (cw-trcol), HIS ORDER (2026-10-18): the column above this panel is laid out by trGeo in this same space: the wallet rows, then the minimap, one gap each
    if(_tg.n) by=Math.max(by,Math.ceil(_tg.yE/_cz));   // v12.05: under the last row (notes logged when there is one); it was the page readout's box and 18 below it
    if(MMAP.box) by=Math.max(by,Math.ceil((mmBottom()+Math.round(_tg.gp*_tg.z))/_cz));   // v24.xx (minimap1): and under the minimap, one gap (v30.xx, cw-trcol: the column's gap)

'@

SubRx @'
  if(T.notes.length){ ctx.save(); ctx.textAlign='right'; ctx.fillStyle='#6b7783';
    // v12.05: BELOW THE CORNER READOUT, not through it. y 26 sat inside the
    // rectangle the v11.78 credits and XP readout now fills, so the line and
    // the readout printed over each other from the first note he left. The
    // CONDITIONS panel, which starts under the readout, starts under this too.
    var _nly=Math.max(26,Math.ceil(topRightBottom())+LH(14));
    ctx.fillText(T.notes.length+' note'+(T.notes.length>1?'s':'')+' logged',W-16,_nly); ctx.restore(); }

'@ @'
  // v30.xx (cw-trcol), HIS ORDER (2026-10-18): the notes logged line is a row of the corner column now (trColDraw), one plate like the credits above it, not loose grey text at the right edge.

'@

SubRx @'
  if(G.mapOpen){ drawMapOverlay(); try{ _lanes(); }catch(_ln){} }   // v22.xx (R38): the message band over the map

'@ @'
  if(G.mapOpen){ drawMapOverlay(); try{ _lanes(); }catch(_ln){} }   // v22.xx (R38): the message band over the map
  try{ trColDraw(); }catch(_tc){}   // v30.xx (cw-trcol): the wallet and notes rows of the corner column, over everything else the way the page text was

'@

SubRx @'
  try{ syncTopRight(); }catch(_tr2){}   // v11.52: a string compare per frame, a DOM write only on change

'@ @'
  try{ syncTopRight(); }catch(_tr2){}   // v11.52: a string compare per frame, a DOM write only on change
  try{ trHide(ts); }catch(_th){}   // v30.xx (cw-trcol): the page text in the corner is clipped away while the raid HUD draws its rows

'@

SubRx @'
_trR=_trE?_trE.getBoundingClientRect():null
'@ @'
_trR=(_trE&&!TRG.hid)?_trE.getBoundingClientRect():null
'@

SubRx @'
      if(_trB>_hdY-_wfp&&_trL<_wxR+_wfp*1.6) _wxR=Math.min(_wxR,_trL-Math.max(14,_wfp*1.6));
    }

'@ @'
      if(_trB>_hdY-_wfp&&_trL<_wxR+_wfp*1.6) _wxR=Math.min(_wxR,_trL-Math.max(14,_wfp*1.6));
    }
    // v30.xx (cw-trcol): and clear of the HUD column in the corner (the wallet rows and the minimap's place), which is drawn on the canvas in a raid and has no page box to read
    if(TRG.n&&EDGEBOX.trcol&&EDGEBOX.trcol.w>0&&_wm.a){
      var _tfp=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11, _tcL=(EDGEBOX.trcol.x*_wk-_wm.e)/_wm.a, _tcB=((EDGEBOX.trcol.y+EDGEBOX.trcol.h)*_wk-_wm.f)/(_wm.d||1);
      if(_tcB>_hdY-_tfp&&_tcL<_wxR+_tfp*1.6) _wxR=Math.min(_wxR,_tcL-Math.max(14,_tfp*1.6));
    }

'@

SubRx @'
var VER='31.03';
'@ @'
var VER='31.04';
'@

$pat = "(?m)^  now:'v31\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.04: The upper right corner of the raid is one column of equal plates: credits, xp, stash, bag, notes logged, the minimap and the run info. Check 31.04 fails on v31.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
