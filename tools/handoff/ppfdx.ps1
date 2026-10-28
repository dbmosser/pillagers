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

# F1 KEY LIST ON THE LEFT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function legDock(s){
'@ @'
// v35.xx (cw-f1left), HIS ORDER (2026-10-27): "hitting f1 to get the controls should be over on the left, not the middle of the screen", and on the
// picture he picked a: "just the f1 key list moves to the left side". THE OPENED LIST STANDS AT THE LEFT EDGE. Its left edge is the feed's and its
// bottom the feed zone's bottom (just over the medal spot and the vitals), so it stands in the feed's place, and the feed lines step right of it
// while it is open (feedStep). Where a tall bot list would reach it (a short screen), its bottom drops into the medal spot as far as it must, never
// over the vitals. The full list (F1 twice) stands on the same corner. Null without a feed zone, and then the old place (bottom left, over the
// vitals) stands. The folded f1 chip stays on the belt row; legDock and legChipSpot below are kept for it and for the older checks.
var LEGSIDE=null, LEGFULL=null;   // LEGSIDE: the opened list (compact or full) as drawn this frame, in screen pixels; LEGFULL: the full list panel in its own space, from drawLegend
function legLeftDock(){
  var rs=Math.max(1,hudRes()), g=Math.round(LH(8)*rs), b, h, rb;
  if(!G||!FEEDBOX.on||!(FEEDBOX.w>0)) return null;
  b=FEEDBOX.y+FEEDBOX.h; h=(G.legendOn===1&&_legBase&&_legBase.h>0)?_legBase.h:0;
  rb=(!G.arcade&&HUDBOX.raiders&&HUDBOX.raiders.w>0)?HUDBOX.raiders:null;
  if(rb&&h>0&&b-h<rb.y+rb.h+g&&MEDALBOX.on&&MEDALBOX.h>0) b=Math.min(MEDALBOX.y+MEDALBOX.h,Math.round(rb.y+rb.h+g+h));
  return {x:FEEDBOX.x,z:LEGZ0,b:b};
}
// how far the feed lines step right so they stand beside the opened list (s, last frame) and never under it
function feedStep(s,R,rs){ return (s&&R&&s.x<R.x+R.w&&s.y<R.y+R.h&&s.y+s.h>R.y)?Math.max(0,Math.round(s.x+s.w+LH(10)*rs-R.x)):0; }
// the full list is tall: where it reaches the bot list, the board steps aside while it is open
function legOverBoard(){ var s=LEGSIDE, r=HUDBOX.raiders; return !!(s&&G&&G.legendOn===2&&r&&r.w>0&&s.x<r.x+r.w&&r.x<s.x+s.w&&s.y<r.y+r.h&&r.y<s.y+s.h); }
function legDock(s){
'@

SubRx @'
var _lcs=(G.legendOn===1)?legChipSpot():null, _lgD=_lcs?legDock(_lcs):null;
'@ @'
LEGSIDE=null; var _lcs=null, _lgD=(G.legendOn===1)?legLeftDock():null;   // v35.xx (cw-f1left), his order (2026-10-27) "should be over on the left, not the middle of the screen": the compact list stands at the left edge in the feed place (legLeftDock), no longer on the belt chip
'@

SubRx @'
ctx.translate(W/2,H); ctx.scale(_fz,_fz); ctx.translate(-W/2,-H);
'@ @'
var _f1L=legLeftDock();   // v35.xx (cw-f1left): the full list stands at the left edge too, its bottom where the compact list's is, scaled about that corner and capped so its top stays on the screen
      if(_f1L){ _fz=Math.min(_fz,Math.max(0.5,(_f1L.b-Math.round(LH(12)*_lgR))/(_fBox+LH(10)))); ctx.translate(_f1L.x,_f1L.b); ctx.scale(_fz,_fz); ctx.translate(-6,-H); }
      else { ctx.translate(W/2,H); ctx.scale(_fz,_fz); ctx.translate(-W/2,-H); }
'@

SubRx @'
drawLegend(G.legendOn===2&&!HOL.c?_fz:1);
'@ @'
if(_f1L) LEGFULL=null; drawLegend(G.legendOn===2&&!HOL.c?_fz:1,!!_f1L); if(_f1L&&LEGFULL) LEGSIDE={x:_f1L.x+(LEGFULL.x-6)*_fz,y:_f1L.b+(LEGFULL.y-H)*_fz,w:LEGFULL.w*_fz,h:LEGFULL.h*_fz};
'@

SubRx @'
HUDBOX.legend=_lz;
'@ @'
HUDBOX.legend=_lz; if(G.legendOn===1&&!HOL.c) LEGSIDE={x:_lz.x,y:_lz.y,w:_lz.w,h:_lz.h};   // v35.xx (cw-f1left): the opened compact list as drawn, so the feed lines step right of it
'@

SubRx @'
function drawLegend(fz){
'@ @'
function drawLegend(fz,left){
'@

SubRx @'
x=Math.max(14,Math.round((W-LEGW)/2));
'@ @'
x=left?14:Math.max(14,Math.round((W-LEGW)/2)); if(left){ top=H-4-boxH; LEGFULL={x:x-8,y:top-6,w:LEGW,h:boxH+10}; }   // v35.xx (cw-f1left): on the left the panel bottom is H in this space, and drawHUD puts that corner on the feed zone bottom
'@

SubRx @'
hudPanel(x-8,top-6,LEGW,boxH+10,0.84,1);
'@ @'
if(left){ ctx.fillStyle='#111315'; ctx.fillRect(x-8,top-6,LEGW,boxH+10); } hudPanel(x-8,top-6,LEGW,boxH+10,0.84,1);
'@

SubRx @'
function feedDraw(){
'@ @'
function feedDraw(){ var _lgS=LEGSIDE, _fst=0; LEGSIDE=null;   // v35.xx (cw-f1left): the opened controls list as drawn last frame (it draws after the feed); read once, so a frame without the list leaves the feed in its place
'@

SubRx @'
x=R.x+Math.round((e-1)*LH(18)*rs); yt=y-R.rh;
'@ @'
x=R.x+(_fst=feedStep(_lgS,R,rs))+(_fst?0:Math.round((e-1)*LH(18)*rs)); yt=y-R.rh;   // beside the open list a new line fades in where it stands (sliding in from the left it ran under the list)
'@

SubRx @'
else if(!G.mapOpen&&!G.bagOpen){
'@ @'
else if(!G.mapOpen&&!G.bagOpen&&!legOverBoard()){   // v35.xx (cw-f1left): not while the full controls list stands over it
'@

SubRx @'
var _bx=[HUDBOX.raiders,HUDBOX.legend,HUDBOX.body,
'@ @'
var _bx=[legOverBoard()?null:HUDBOX.raiders,HUDBOX.legend,(G&&G.legendOn===2)?LEGSIDE:null,HUDBOX.body,
'@

SubRx @'
var _lx=W/2-_lbw/2, _ly=H/2-_lbh/2;
'@ @'
var _lx=Math.round(LH(24)), _ly=H/2-_lbh/2, _lcx=_lx+_lbw/2;   // v35.xx (cw-f1left), his order (2026-10-27): the F1 key list on the floor stands at the left too
'@

SubRx @'
ctx.fillText('CONTROLS',W/2,_ly+LH(24));
'@ @'
ctx.fillText('CONTROLS',_lcx,_ly+LH(24));
'@

SubRx @'
ctx.fillText(_lg[_lk],W/2-LH(12),_yy);
'@ @'
ctx.fillText(_lg[_lk],_lcx-LH(12),_yy);
'@

SubRx @'
ctx.fillText(_lg[_lk+1],W/2+LH(12),_yy);
'@ @'
ctx.fillText(_lg[_lk+1],_lcx+LH(12),_yy);
'@

SubRx @'
var VER='35.29';
'@ @'
var VER='35.30';
'@

$pat = "(?m)^  now:'v35\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.30: the f1 key list opens on the left Check 35.30 fails on v35.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
