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

# THE BUILD CHANGES YOUR BODY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
// v20.01, HIS ORDER (2026-10-08): "build should change your charcter -- curved should be clearly female with larger breasts/buttocks".
// BUILD (FASHION) had never been read by the painter, so Lean, Broad and Curved all drew the same figure. Lean is the figure as it
// always was and still draws through the old lines. Broad draws a V of a torso, wide at the shoulders. Curved draws an hourglass:
// a fuller chest lit from above with a shadow under it, a narrow waist with a belt, and hips that flare past the legs, the trousers
// running up into them; and in the face a dark upper lid with a flick and a rose mouth, so she reads at raid size. One outline
// per build, from half-widths down the left side mirrored for the right, inked once.
var BUILD_BROAD=[[3.6,-23.8],[8.9,-23.0],[9.1,-19.4],[7.4,-14.6],[6.9,-10.6],[2.2,-10.2]];
var BUILD_CURVED=[[3.0,-23.4],[6.0,-22.8],[7.8,-18.6],[4.1,-14.9],[8.7,-11.8],[7.3,-9.8],[0.8,-10.8]];
var BUILD_Q=[]; (function(){ for(var i=0;i<16;i++) BUILD_Q.push([0,0]); })();
function buildPath(cx,ty,P,grow){
  var n=P.length*2, i, j, a, b2, Q=BUILD_Q;
  for(i=0;i<P.length;i++){ Q[i][0]=cx-P[i][0]-grow; Q[i][1]=ty+P[i][1]+(i===0?-grow:(i===P.length-1?grow:0)); }
  for(i=P.length-1,j=P.length;i>=0;i--,j++){ Q[j][0]=cx+P[i][0]+grow; Q[j][1]=ty+P[i][1]+(i===0?-grow:(i===P.length-1?grow:0)); }
  wc.beginPath(); a=Q[n-1]; b2=Q[0]; wc.moveTo((a[0]+b2[0])/2,(a[1]+b2[1])/2);
  for(i=0;i<n;i++){ a=Q[i]; b2=Q[(i+1)%n]; wc.quadraticCurveTo(a[0],a[1],(a[0]+b2[0])/2,(a[1]+b2[1])/2); }
  wc.closePath();
}
function drawBuildTorso(b,cx,ty,cc,cHi,cLo,trs,jc,jh,lx,lA,lB){
  var P=(b==='broad')?BUILD_BROAD:BUILD_CURVED, by, sh, bl;
  buildPath(cx,ty,P,1); wc.fillStyle=INK; wc.fill();
  buildPath(cx,ty,P,0); wc.save(); wc.clip();
  wc.fillStyle=cc; wc.fillRect(cx-11,ty-25,22,17);
  wc.fillStyle=cHi; wc.fillRect(cx-11,ty-24,22,(b==='broad')?3.4:2.6);
  if(b==='broad'){
    wc.fillStyle=cLo; wc.fillRect(cx-11,ty-13.2,22,3.4);
  } else {
    wc.fillStyle=trs; wc.fillRect(cx-11,ty-14.4,22,7);                       // trousers from the waist down
    by=ty-18.0+(jc||0); sh=darkHex(cc,.40); bl=litHex(cc,.28,true);
    wc.fillStyle=sh;                                                         // the shadow under the chest
    wc.beginPath(); wc.ellipse(cx-2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.ellipse(cx+2.8,by+1.0,2.95,2.4,0,0,6.2832); wc.fill();
    wc.fillStyle=bl;                                                         // and the chest, lit from above
    wc.beginPath(); wc.ellipse(cx-2.8,by,2.8,2.25,0,0,6.2832); wc.ellipse(cx+2.8,by,2.8,2.25,0,0,6.2832); wc.fill();
    wc.fillStyle=cHi; wc.fillRect(cx-4.3,by-1.6,1.5,.9); wc.fillRect(cx+1.4,by-1.6,1.5,.9);
    wc.fillStyle=cLo; wc.fillRect(cx-11,ty-15.2,22,1.0);                    // a belt at the waist
  }
  wc.restore();
  if(b==='curved'){ wc.fillStyle=trs; wc.fillRect(lx-6.3+lB,ty-10.9,4.6,2.2); wc.fillRect(lx+1.7+lA,ty-10.9,4.6,2.2); }   // the legs run up into the hips
}
function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@

SubRx @'
  var OUTF=outfitOf(st);   // v10.54: an outfit overrules the racks below
'@ @'
  var OUTF=outfitOf(st);   // v10.54: an outfit overrules the racks below
  var _BID=st.hero?cosWorn('build'):(st.build||'lean'), _BLD=(_BID==='broad'||_BID==='curved')?_BID:null;   // v20.01: the body's build
'@

SubRx @'
  wc.fillStyle=INK; rrF(x-7.5+leanX,ty-23,15,13,4);
  wc.fillStyle=cc; rrF(x-6.5+leanX,ty-22,13,11,3);
  wc.fillStyle=cHi; wc.fillRect(x-5.7+leanX,ty-22,11.4,3);
  wc.fillStyle=cLo; wc.fillRect(x-5.7+leanX,ty-13.4,11.4,2.4);
'@ @'
  if(!_BLD){
  wc.fillStyle=INK; rrF(x-7.5+leanX,ty-23,15,13,4);
  wc.fillStyle=cc; rrF(x-6.5+leanX,ty-22,13,11,3);
  wc.fillStyle=cHi; wc.fillRect(x-5.7+leanX,ty-22,11.4,3);
  wc.fillStyle=cLo; wc.fillRect(x-5.7+leanX,ty-13.4,11.4,2.4);
  } else drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,_TRS,0,0,x,swing*.5,swing2*.5);   // v20.01: Broad and Curved draw their own body
'@

SubRx @'
  wc.fillRect(x-6.5+leanX,ty-18,13,2.4);
'@ @'
  if(_BLD==='broad') wc.fillRect(x-8.2+leanX,ty-18,16.4,2.4); else if(!_BLD) wc.fillRect(x-6.5+leanX,ty-18,13,2.4);   // v20.01: wider on Broad; Curved wears a belt instead
'@

SubRx @'
    wc.fillRect(x-6.5+leanX,ty-22,13,11);
    wc.globalCompositeOperation='source-over';
'@ @'
    if(_BLD){ buildPath(x+leanX,ty,(_BLD==='broad')?BUILD_BROAD:BUILD_CURVED,0); wc.fill(); } else wc.fillRect(x-6.5+leanX,ty-22,13,11);   // v20.01: the flash fits the build's body
    wc.globalCompositeOperation='source-over';
'@

SubRx @'
  wc.fillRect(hx2+2.7+pupX,ty-30.2+pupY,0.8,0.8);
'@ @'
  wc.fillRect(hx2+2.7+pupX,ty-30.2+pupY,0.8,0.8);
  if(_BLD==='curved'){ wc.strokeStyle=INK; wc.lineWidth=0.9; wc.beginPath(); wc.ellipse(hx2-3.4,ty-29.5,2.6,3.1,0,3.45,5.95); wc.stroke(); wc.beginPath(); wc.ellipse(hx2+3.4,ty-29.5,2.6,3.1,0,3.47,5.97); wc.stroke(); wc.fillStyle=INK; wc.fillRect(hx2-6.3,ty-31.5,1.5,0.9); wc.fillRect(hx2+4.8,ty-31.5,1.5,0.9); }   // v20.01: Curved, lashes
'@

SubRx @'
  wc.fillStyle='#8a5c46';
  if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);
'@ @'
  wc.fillStyle=(_BLD==='curved')?'#c25a6c':'#8a5c46';   // v20.01: Curved, a rose mouth
  if(st.hurt>0) wc.fillRect(hx2-2,ty-25.6,4,1.6);
'@

SubRx @'
var VER='20.00';
'@ @'
var VER='20.01';
'@

$pat = "(?m)^  now:'v20\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.01: Lean, Broad and Curved now change your body; Curved is clearly a woman. Check 20.01 fails on v20.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
