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

# THE HUMAN FIGURES ARE BIGGER AND SHAPED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){

'@ @'
// v32.64 (cw-figlook), HIS PICKS on the art survey (a01 D, a02 B, a04 C, a05 B, a09 B): THE HUMAN FIGURES. The whole figure is drawn FIG_SCALE (1.25)
// times as big about its feet at every human draw site (you, your mate, the pillager bots, the hires, the survivor), with a build height on top
// (lean 0.92 wide by 1.08 tall, broad 1.1 by 0.96, curved 1 by 1). Shadow, seat ring and gun scale with the body. Hit areas are untouched.
// FIG_SCALE is the one number to dial back. Previews (a small canvas swapped into wc) stay as they were. FIG_UP lifts the plates and bars
// over the bigger head.
var FIG_SCALE=1.25, FIG_UP=19, FIG_HEAD=1.2, FIG_PACK=1.3, FIG_VEST=1.12, FIG_PATCH=1.6;
function figBuildK(b){ return (b==='broad')?[1.1,0.96]:((b==='curved')?[1,1]:[0.92,1.08]); }
function figOn(){ return !!(typeof wc!=='undefined'&&wc&&((typeof cv!=='undefined'&&wc.canvas===cv)||RIM.on===1)); }
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  if(!figOn()) return drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
  var k=figBuildK(st&&st.hero?cosWorn('build'):((st&&st.build)||'lean'));
  wc.save(); wc.translate(x,y); wc.scale(FIG_SCALE*k[0],FIG_SCALE*k[1]); wc.translate(-x,-y);
  try{ return drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st); } finally { wc.restore(); }
}
function drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st){

'@

SubRx @'
  shadowE(x+1.5,y+1.5,10,4,.34);
  shadowE(x+6,y+2.5,6.5,2.5,.18);

'@ @'
  shadowE(x+1.5,y+2,12.5,5,.5);   // v32.64 (cw-figlook), a09 B: a bigger, darker shadow
  shadowE(x+7,y+3,8,3,.28);

'@

SubRx @'
  var hx2=x+leanX;
  var HERO=!!st.hero;

'@ @'
  var hx2=x+leanX;
  wc.save(); wc.translate(hx2,ty-22); wc.scale(FIG_HEAD,FIG_HEAD); wc.translate(-hx2,-(ty-22));   // v32.64 (cw-figlook), a01 D: the mascot head, hats and hair with it
  var HERO=!!st.hero;

'@

SubRx @'
  else wc.fillRect(hx2-1.5,ty-25.2,3,1);

'@ @'
  else wc.fillRect(hx2-1.5,ty-25.2,3,1);
  wc.restore();   // v32.64 (cw-figlook): end of the scaled head

'@

SubRx @'
  if(!(OUTF&&OUTF.nopack)){   // v23.xx (spr21): the Survivor has no pack

'@ @'
  if(!(OUTF&&OUTF.nopack)){   // v23.xx (spr21): the Survivor has no pack
  wc.save(); wc.translate(x-fl*9+leanX,ty-16.5); wc.scale(FIG_PACK,FIG_PACK); wc.translate(-(x-fl*9+leanX),-(ty-16.5));   // v32.64 (cw-figlook), a05 B: the pack 1.3

'@

SubRx @'
  }
  if(!_BLD){
  if(_PC){ wc.fillStyle=INK; rrF(x-6.6+leanX
'@ @'
  wc.restore();
  }
  if(!_BLD){
  if(_PC){ wc.fillStyle=INK; rrF(x-6.6+leanX
'@

SubRx @'
drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl);
'@ @'
{ wc.save(); wc.translate(x+leanX,ty-17); wc.scale(FIG_VEST,FIG_VEST); wc.translate(-(x+leanX),-(ty-17)); drawVest(_VID,_BLD,x+leanX,ty,cc,_SCH,fl); wc.restore(); }   // v32.64 (cw-figlook), a05 B: the vest 1.12
'@

SubRx @'
drawPads(_PDS,_BLD,x+leanX,ty,fl,_SCH);
'@ @'
{ wc.save(); wc.translate(x+leanX,ty-17); wc.scale(FIG_VEST,FIG_VEST); wc.translate(-(x+leanX),-(ty-17)); drawPads(_PDS,_BLD,x+leanX,ty,fl,_SCH); wc.restore(); }   // v32.64 (cw-figlook), a05 B: the pauldrons 1.12
'@

SubRx @'
drawPatch(wc,_pid,x-fl*3.6-1.8+leanX,ty-21.8,3.6);
'@ @'
drawPatch(wc,_pid,x-fl*3.6+leanX-FIG_PATCH*1.8,ty-20-FIG_PATCH*1.8,3.6*FIG_PATCH); /* v32.64 (cw-figlook), a05 B: the chest patch 1.6 about its centre */
'@

SubRx @'
function drawRoleMark(e){

'@ @'
function drawRoleMark(e){
  if(!figOn()) return drawRoleMark0(e);
  var k=figBuildK(e&&e.build);   // v32.64 (cw-figlook): the role mark rides the shoulders, so it is scaled with the body
  wc.save(); wc.translate(e.x,e.y); wc.scale(FIG_SCALE*k[0],FIG_SCALE*k[1]); wc.translate(-e.x,-e.y);
  try{ return drawRoleMark0(e); } finally { wc.restore(); }
}
function drawRoleMark0(e){

'@

SubRx @'
  return 40;   // humans grew a real head at v1.07

'@ @'
  if(e.kind==='raider'||e.kind==='stray') return 40+FIG_UP;   // v32.64 (cw-figlook): the bigger figure and head, so plates and marks ride higher
  return 40;   // humans grew a real head at v1.07

'@

SubRx @'
var _py=p.y-68-((_pbi&&p.prep)?13:0);
'@ @'
var _py=p.y-68-FIG_UP-((_pbi&&p.prep)?13:0);   // v32.64 (cw-figlook): over the bigger head
'@

SubRx @'
      wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62,tw+8,13);
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52);

'@ @'
      wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-FIG_UP,tw+8,13);   // v32.64 (cw-figlook): over the bigger head
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52-FIG_UP);

'@

SubRx @'
    wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62,tw+8,13);
    wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52);

'@ @'
    wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-FIG_UP,tw+8,13);   // v32.64 (cw-figlook): over the bigger head
    wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x,g.y-52-FIG_UP);

'@

SubRx @'
function netUpTags(){
  var i, g, nm, tw, n=0;

'@ @'
// v32.64 (cw-figlook), a10 D: a 36x3 health bar under the mate name, green above half, amber to a quarter, red below, 1 px black outline.
function netUpBar(g,U){
  var w=36, f=(g.mh>0)?clamp((g.hp||0)/g.mh,0,1):0, bx=Math.round(g.x-w/2), by=Math.round(g.y-62-U+15);
  wc.fillStyle='#000000'; wc.fillRect(bx-1,by-1,w+2,5);
  wc.fillStyle='#14171a'; wc.fillRect(bx,by,w,3);
  wc.fillStyle=f>0.5?'#5fae6f':(f>0.25?'#d0a13c':'#c8452f'); wc.fillRect(bx,by,Math.round(w*f),3);
}
function netUpTags(){
  var i, g, nm, tw, n=0, U=FIG_UP+3;   // v32.64 (cw-figlook): U lifts the plate over the bigger head and makes room for the bar

'@

SubRx @'
wlUnder(g.x-tw/2-4,g.y-(g.dn?77:62),tw+8,g.dn?28:13)
'@ @'
wlUnder(g.x-tw/2-4,g.y-(g.dn?77:62)-U,tw+8,(g.dn?28:13)+8)
'@

SubRx @'
wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62,tw+8,13);
      // v22.70, the raid text rewrite (R27)
'@ @'
wc.fillStyle='rgba(6,9,13,.86)'; wc.fillRect(g.x-tw/2-4,g.y-62-U,tw+8,13); netUpBar(g,U);
      // v22.70, the raid text rewrite (R27)
'@

SubRx @'
wc.fillText(nm,g.x-tw/2,g.y-52);
      // v22.68
'@ @'
wc.fillText(nm,g.x-tw/2,g.y-52-U);
      // v22.68
'@

SubRx @'
wc.fillRect(g.x-dw/2-4,g.y-77,dw+8,13);
'@ @'
wc.fillRect(g.x-dw/2-4,g.y-77-U,dw+8,13);
'@

SubRx @'
wc.fillText(dl,g.x-dw/2,g.y-67);
'@ @'
wc.fillText(dl,g.x-dw/2,g.y-67-U);
'@

SubRx @'
var VER='32.63';
'@ @'
var VER='32.64';
'@

$pat = "(?m)^  now:'v32\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.64: Every pillager, you, your mate and the hires are drawn bigger with their own build height, plates and bars sit over the bigger head, and the mate has a health bar under the name. Check 32.64 fails on v32.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
