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

# THE PEDDLER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  outpoet:    {coat:'#14161b',trs:'#2a3a5a',boots:['#14161b','#1f2227','#f2f0ea','#e6e3da'],skin:null,hands:null,cut:'shaved',hat:'bandana',beard:'goatee',mark:'poet'}
};
'@ @'
  outpoet:    {coat:'#14161b',trs:'#2a3a5a',boots:['#14161b','#1f2227','#f2f0ea','#e6e3da'],skin:null,hands:null,cut:'shaved',hat:'bandana',beard:'goatee',mark:'poet'},
  // v23.xx (spr20): the Peddler's own clothes, never sold (not in COSMETICS). cloth: lit like the plate carrier bodies; norig: no rig.
  outpeddler: {coat:'#7a5a3a',trs:'#3a3026',boots:['#2a2018','#3a2c20'],skin:null,hands:'#6a4a2e',cut:'crop',hair:'dark',hat:'none',beard:'stubble',mark:'peddler',cloth:1,norig:1}
};
'@

SubRx @'
function drawRigPC(b,cx,ty,cc,jc,jh){
'@ @'
function drawRigPC(b,cx,ty,cc,jc,jh,norig){   // v23.xx (spr20): norig, the cloth lit with no rig on it (a suit with cloth:1)
'@

SubRx @'
  if(b==='curved'){
    var by=ty-18.0+(jc||0);
'@ @'
  if(norig){ /* v23.xx (spr20): cloth only */ }
  else if(b==='curved'){
    var by=ty-18.0+(jc||0);
'@

SubRx @'
  var _PC=!OUTF&&!(st.hero&&cosWorn('fit')==='jersey');
'@ @'
  var _PC=(!OUTF&&!(st.hero&&cosWorn('fit')==='jersey'))||!!(OUTF&&OUTF.cloth);   // v23.xx (spr20): a suit with cloth:1 is lit the same way
'@

SubRx @'
  if(_PC) drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h);
'@ @'
  if(_PC) drawRigPC(_BLD||'lean',x+leanX,ty,cc,_JG.c,_JG.h,!!(OUTF&&OUTF.norig));
'@

SubRx @'
    } else if(_om==='poet'){
'@ @'
    } else if(_om==='peddler'){
      // v23.xx (spr20): THE PEDDLER. A long leather duster from the waist to the boots, open at the front, lapels and a satchel strap
      // on the chest, and a wide brimmed hat, a shape nobody else in the game has.
      var _dLo=darkHex(cc,.45), _dHi=litHex(cc,.20,true);
      wc.fillStyle=INK; wc.beginPath(); wc.moveTo(_ox-7.4,ty-13.4); wc.lineTo(_ox+7.4,ty-13.4); wc.lineTo(_ox+9.4,ty-2.4); wc.lineTo(_ox-9.4,ty-2.4); wc.closePath(); wc.fill();
      wc.fillStyle=cc; wc.beginPath(); wc.moveTo(_ox-6.4,ty-12.6); wc.lineTo(_ox+6.4,ty-12.6); wc.lineTo(_ox+8.3,ty-3.4); wc.lineTo(_ox-8.3,ty-3.4); wc.closePath(); wc.fill();
      wc.fillStyle=_dHi; wc.beginPath(); wc.moveTo(_ox-6.4,ty-12.6); wc.lineTo(_ox-5.0,ty-12.6); wc.lineTo(_ox-6.6,ty-3.4); wc.lineTo(_ox-8.3,ty-3.4); wc.closePath(); wc.fill();
      wc.fillStyle=_dLo; wc.beginPath(); wc.moveTo(_ox+4.6,ty-12.6); wc.lineTo(_ox+6.4,ty-12.6); wc.lineTo(_ox+8.3,ty-3.4); wc.lineTo(_ox+6.0,ty-3.4); wc.closePath(); wc.fill();
      wc.fillStyle=INK; wc.beginPath(); wc.moveTo(_ox-0.5,ty-12.6); wc.lineTo(_ox+0.5,ty-12.6); wc.lineTo(_ox+1.2,ty-3.4); wc.lineTo(_ox-1.2,ty-3.4); wc.closePath(); wc.fill();
      wc.fillStyle=_dHi; wc.beginPath(); wc.moveTo(_ox-4.0,ty-21.6); wc.lineTo(_ox-1.6,ty-21.6); wc.lineTo(_ox-0.6,ty-14.2); wc.closePath(); wc.fill();
      wc.fillStyle=_dLo; wc.beginPath(); wc.moveTo(_ox+1.6,ty-21.6); wc.lineTo(_ox+4.0,ty-21.6); wc.lineTo(_ox+0.6,ty-14.2); wc.closePath(); wc.fill();
      wc.strokeStyle='#2e2016'; wc.lineWidth=1.3; wc.beginPath(); wc.moveTo(_ox-4.6,ty-21.4); wc.lineTo(_ox+4.8,ty-13.6); wc.stroke();
      wc.fillStyle='#2a1e14'; wc.fillRect(_ox-6.4,ty-13.6,12.8,1.2); wc.fillStyle='#a8996a'; wc.fillRect(_ox-0.7,ty-13.6,1.4,1.2);
      wc.fillStyle=INK;       rrF(hx2-12.6,ty-38.8,25.2,3.8,1.9);
      rrF(hx2-7.6,ty-43.6,15.2,7.4,3);
      wc.fillStyle='#4a3524'; rrF(hx2-12.0,ty-38.2,24.0,2.6,1.3);
      wc.fillStyle='#5e4430'; rrF(hx2-7.0,ty-43.0,14.0,6.4,2.6);
      wc.fillStyle='#2a1e14'; wc.fillRect(hx2-7.0,ty-39.2,14.0,1.3);
      wc.fillStyle='#7c5c40'; wc.fillRect(hx2-6.0,ty-42.6,6.4,1.0); wc.fillRect(hx2-11.2,ty-38.2,8,0.8);
    } else if(_om==='poet'){
'@

SubRx @'
  drawOp(e.x,e.y-15,e.face,(e.step||0)*3,e.coat,0.3,0,'none',0,
    {moving:!!(e.fleeT||e._back),sprint:!!e.fleeT,ads:false,hurt:e.hitT});
'@ @'
  // v23.xx (spr20), HIS ORDER (2026-10-12) "make them all look better": THE PEDDLER. He was a pillager in an amber coat with the rig
  // stripes across it (a bumblebee) behind three coloured squares. Now he is a travelling trader: a tall pack frame on his back with
  // a bedroll on top and a pot, a coil of rope and a bottle hanging off it, a leather duster and a wide brimmed hat (his own outfit,
  // outpeddler, never sold), a cloth over his table and his stock as a roll, a box and a can. The lantern and its warm pool stay, the
  // glow now a disc painted once and reused instead of a new gradient every frame. Cosmetic only: no random numbers.
  (function(){
    var fx=e.x, fy=e.y-15;
    wc.fillStyle=INK; wc.fillRect(fx-8.6,fy-49.6,3.4,31); wc.fillRect(fx+5.2,fy-49.6,3.4,31); wc.fillRect(fx-8.6,fy-50.2,17.2,3.4);
    wc.fillStyle='#6a4e32'; wc.fillRect(fx-8.0,fy-49.0,2.2,30); wc.fillRect(fx+5.8,fy-49.0,2.2,30); wc.fillRect(fx-8.0,fy-49.6,16,2.2);
    wc.fillStyle='#8a6a46'; wc.fillRect(fx-8.0,fy-49.6,16,0.8); wc.fillRect(fx-8.0,fy-49.0,0.8,30);
    wc.fillStyle=INK; rrF(fx-9.4,fy-55.4,18.8,6.0,3);
    wc.fillStyle='#55654a'; rrF(fx-8.8,fy-54.8,17.6,4.8,2.4);
    wc.fillStyle='#71836a'; wc.fillRect(fx-7.6,fy-54.6,15,1);
    wc.fillStyle='#3a2a1c'; wc.fillRect(fx-4.4,fy-55.0,1.3,5.4); wc.fillRect(fx+3.0,fy-55.0,1.3,5.4);
    wc.fillStyle=INK; wc.beginPath(); wc.arc(fx-11.8,fy-37.6,4.1,0,6.2832); wc.fill();
    wc.fillStyle='#3e454c'; wc.beginPath(); wc.arc(fx-11.8,fy-37.6,3.3,0,6.2832); wc.fill();
    wc.fillStyle='#7c868f'; wc.fillRect(fx-14.0,fy-40.0,3.2,1.0);
    wc.strokeStyle=INK; wc.lineWidth=1; wc.beginPath(); wc.moveTo(fx-11.8,fy-41.6); wc.lineTo(fx-8.6,fy-44); wc.stroke();
    wc.strokeStyle=INK; wc.lineWidth=2.8; wc.beginPath(); wc.arc(fx+11.6,fy-41.0,2.8,0,6.2832); wc.stroke();
    wc.strokeStyle='#b08a52'; wc.lineWidth=1.4; wc.beginPath(); wc.arc(fx+11.6,fy-41.0,2.8,0,6.2832); wc.stroke();
    wc.fillStyle=INK; rrF(fx+9.6,fy-35.4,4.2,8.4,1.4);
    wc.fillStyle='#3e6a52'; rrF(fx+10.2,fy-34.8,3.0,7.2,1);
    wc.fillStyle='#8ec0a4'; wc.fillRect(fx+10.6,fy-34.0,0.8,4.2);
  })();
  drawOp(e.x,e.y-15,e.face,(e.step||0)*3,e.coat,0.3,0,'none',0,
    {moving:!!(e.fleeT||e._back),sprint:!!e.fleeT,ads:false,hurt:e.hitT,outfit:'outpeddler'});   // v23.xx (spr20): in his own clothes
'@

SubRx @'
  wc.fillStyle='#3a2c1e'; wc.fillRect(hx-23,hy+5,4,9); wc.fillRect(hx+19,hy+5,4,9);
  for(var q=0;q<3;q++){
    var S=e.stock&&e.stock[q]; if(!S) continue;
    wc.fillStyle=S.sold?'#3a3630':((ITEMS[S.k]&&ITEMS[S.k].c)||'#c9b458');
    wc.fillRect(hx-19+q*13,hy-15,9,8);
    wc.fillStyle='rgba(18,14,12,.5)'; wc.fillRect(hx-19+q*13,hy-8,9,1);
  }
'@ @'
  wc.fillStyle='#3a2c1e'; wc.fillRect(hx-23,hy+5,4,9); wc.fillRect(hx+19,hy+5,4,9);
  // v23.xx (spr20): a lit edge on the table, a cloth hanging off its front, and the stock as a roll, a box and a can
  wc.fillStyle='#9a7a52'; wc.fillRect(hx-25,hy-7,50,1);
  wc.fillStyle='#24363a'; wc.fillRect(hx-20,hy-2,40,8.6);
  wc.fillStyle='#3e5a58'; wc.fillRect(hx-20,hy-2,40,7.8);
  wc.fillStyle='#5c7c78'; wc.fillRect(hx-20,hy-2,40,1);
  for(var _cf=0;_cf<7;_cf++) wc.fillRect(hx-18.6+_cf*6,hy+5.8,2.2,1.6);
  for(var q=0;q<3;q++){
    var S=e.stock&&e.stock[q]; if(!S) continue;
    var _sc=S.sold?'#3a3630':((ITEMS[S.k]&&ITEMS[S.k].c)||'#c9b458'), _bx=hx-19+q*13, _by=hy-7;
    wc.fillStyle='rgba(18,14,12,.5)'; wc.fillRect(_bx-0.5,_by-1,10,1);
    if(q===0){ wc.fillStyle=INK; rrF(_bx-0.6,_by-7.2,10.2,7.2,3.4); wc.fillStyle=_sc; rrF(_bx,_by-6.6,9,6,2.8);
      wc.fillStyle='rgba(255,255,255,.28)'; wc.fillRect(_bx+1.4,_by-6.2,6.2,1); wc.fillStyle='rgba(0,0,0,.28)'; wc.fillRect(_bx+3.2,_by-6.6,1.2,6); }
    else if(q===1){ wc.fillStyle=INK; wc.fillRect(_bx-0.6,_by-9,10.2,9); wc.fillStyle=_sc; wc.fillRect(_bx,_by-8.4,9,8.4);
      wc.fillStyle='rgba(255,255,255,.28)'; wc.fillRect(_bx,_by-8.4,9,1); wc.fillStyle='rgba(0,0,0,.30)'; wc.fillRect(_bx,_by-6.4,9,0.8); wc.fillRect(_bx+3.9,_by-5.6,1.2,4); }
    else { wc.fillStyle=INK; rrF(_bx+0.2,_by-10,8.6,10,1.6); wc.fillStyle=_sc; wc.fillRect(_bx+0.8,_by-9.4,7.4,9.4);
      wc.fillStyle='rgba(255,255,255,.30)'; wc.beginPath(); wc.ellipse(_bx+4.5,_by-9.2,3.6,1.1,0,0,6.2832); wc.fill();
      wc.fillStyle='rgba(0,0,0,.30)'; wc.fillRect(_bx+0.8,_by-4.6,7.4,1); wc.fillRect(_bx+6.6,_by-9.4,1.6,9.4); }
  }
'@

SubRx @'
  wc.save(); wc.globalCompositeOperation='lighter';
  var gr=wc.createRadialGradient(hx+28,hy-30,2,hx+28,hy-30,66);
  gr.addColorStop(0,'rgba(255,196,90,'+(0.40*lp).toFixed(3)+')');
  gr.addColorStop(1,'rgba(255,196,90,0)');
  wc.fillStyle=gr; wc.beginPath(); wc.arc(hx+28,hy-30,66,0,6.2832); wc.fill();
  wc.restore();
'@ @'
  wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=lp;   // v23.xx (spr20): the warm pool, a baked disc (pedGlow)
  wc.drawImage(pedGlow(),hx+28-66,hy-30-66,132,132);
  wc.restore();
'@

SubRx @'
function drawPeddlerS(e){
'@ @'
// v23.xx (spr20): the Peddler's lantern pool, painted once on its own canvas (the same gradient as before at full strength) and
// drawn with the flicker as its alpha, instead of a new radial gradient every frame.
var PEDGLOW=null;
function pedGlow(){
  if(PEDGLOW) return PEDGLOW;
  var c=document.createElement('canvas'); c.width=132; c.height=132; var x=c.getContext('2d');
  if(x){ var gr=x.createRadialGradient(66,66,2,66,66,66); gr.addColorStop(0,'rgba(255,196,90,0.40)'); gr.addColorStop(1,'rgba(255,196,90,0)');
    x.fillStyle=gr; x.beginPath(); x.arc(66,66,66,0,6.2832); x.fill(); }
  return PEDGLOW=c;
}
function drawPeddlerS(e){
'@

SubRx @'
var VER='24.31';
'@ @'
var VER='24.32';
'@

$pat = "(?m)^  now:'v24\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.32: The Peddler is a travelling trader now: a pack frame hung with goods, a duster, a wide hat and a dressed stall. Check 24.32 fails on v24.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
