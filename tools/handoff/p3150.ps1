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

# the corner column is 300 wide at 1080p, and world names stay out from under the HUD plates (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function trBW(){ var u=uiScale(); if(trDemo()&&u>1.2) u=1.2; return Math.round(196*TEXTLIFT*u*mmSizeK()); }   // the column's width: the run info panel's (LH(196)); the party screen's 1.5 text scale does not widen it, so its minimap is the career one (the picture he chose had 300)

'@ @'
function trBW(){ var u=uiScale(); if(trDemo()&&u>1.2) u=1.2; return 300/(HUDZ.cond||1)*(u/1.2)*mmSizeK(); }   // the column's width: 300 px at 1080p (v31.xx, cw-trcol2: the picture he chose in the menu survey, q16 A and q20 A; it was the run info panel's 321), and the same share of the screen at other sizes (the HUD scale, the text scale capped at 1.2, the Settings minimap size); the party screen's 1.5 text scale does not widen it, so its minimap is the career one

'@

SubRx @'
var CACHETAGS=[];   // v28.xx (cachetag): named cache labels queued by the world pass, drawn over the walls by _wtA

'@ @'
var CACHETAGS=[];   // v28.xx (cachetag): named cache labels queued by the world pass, drawn over the walls by _wtA
// v31.xx (cw-trcol2), the follow-up on HIS ORDER of 2026-10-18 (one column in the upper right corner): A WORLD NAME LABEL IS NOT DRAWN WHILE IT WOULD OVERLAP THE CORNER COLUMN OR THE SCORE AND CLOCK PLATE.
// The labels (the named caches, the nameplates, the party names, the strongbox and the forge) are drawn first and the HUD plates over them, so in the 8 px gaps between plates, and through the 12 percent the plates let by, the
// purple "the long dock cache" showed between the stash and backpack rows and "chill row cache" poked out on both sides of the score plate. wlUnder says whether a label's rectangle (world units) touches the column
// (EDGEBOX.trcol, the run info panel) or the score plate (SCOREBOX); WTX is this frame's world to screen map, written by render2D. No allocation: the boxes are persistent and the font size is read once per font string.
var WTX={z:1,ox:0,oy:0};   // screen px = (world - o) * z
var SCOREBOX={g:null,x:0,y:0,w:0,h:0};   // the score and clock plate at the top centre as last drawn, screen px (arcadeScoreHud); g is the raid it belongs to
var _wlF='', _wlP=12;
function wlHit(b,X,Y,X1,Y1){ return !!b&&b.w>0&&X1>b.x-3&&X<b.x+b.w+3&&Y1>b.y-3&&Y<b.y+b.h+3; }
function wlUnder(x,y,w,h){
  var z=WTX.z, X=(x-WTX.ox)*z, Y=(y-WTX.oy)*z, X1=X+w*z, Y1=Y+h*z, s=SCOREBOX;
  return wlHit(EDGEBOX.trcol,X,Y,X1,Y1)||wlHit(HUDBOX.cond,X,Y,X1,Y1)||(s.g===G&&wlHit(s,X,Y,X1,Y1));
}
function wlPx(){ var f=wc.font, m; if(f!==_wlF){ _wlF=f; m=/([\d.]+)px/.exec(f); _wlP=m?+m[1]:12; } return _wlP; }   // the size of the font wc is set to, in the units it draws in

'@

SubRx @'
var ox=VX+(+GFX.sx||0)/Z, oy=VY+(+GFX.sy||0)/Z;
'@ @'
var ox=VX+(+GFX.sx||0)/Z, oy=VY+(+GFX.sy||0)/Z; /* v31.xx (cw-trcol2): the world to screen map for wlUnder */ WTX.z=Z; WTX.ox=ox; WTX.oy=oy;
'@

SubRx @'
    for(var _cq=0;_cq<_ctq.length;_cq++){ var _cg=_ctq[_cq]; wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cg.y+1); wc.fillStyle='#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cg.y); }

'@ @'
    var _cpx=wlPx();
    for(var _cq=0;_cq<_ctq.length;_cq++){ var _cg=_ctq[_cq], _cw=wc.measureText(_cg.t).width; if(wlUnder(_cg.x-_cw/2,_cg.y-_cpx,_cw,_cpx*1.3)) continue; wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cg.y+1); wc.fillStyle='#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cg.y); }   // v31.xx (cw-trcol2): not over the corner column or the score plate

'@

SubRx @'
var ph2=Math.ceil(parseFloat((wc.font.match(/([\d.]+)px/)||[0,12])[1])*1.35);
'@ @'
var ph2=Math.ceil(parseFloat((wc.font.match(/([\d.]+)px/)||[0,12])[1])*1.35);
    if(wlUnder(ne.x-tw/2-11,ne.y-lift-ph2+3,tw+22,ph2+5)) continue;   // v31.xx (cw-trcol2): a nameplate (with its crew block and health pip) is not drawn over the corner column or the score plate
'@

SubRx @'
      g=NET.up[i]; if(!netUpShown(g)) continue;
      nm=netSeatName(g.seat)||'PILLAGER';
      tw=wc.measureText(nm).width;

'@ @'
      g=NET.up[i]; if(!netUpShown(g)) continue;
      nm=netSeatName(g.seat)||'PILLAGER';
      tw=wc.measureText(nm).width;
      if(wlUnder(g.x-tw/2-4,g.y-(g.dn?77:62),tw+8,g.dn?28:13)){ n++; continue; }   // v31.xx (cw-trcol2): nor a party name (and its DOWN plate) over the corner column or the score plate

'@

SubRx @'
      wc.textAlign='center'; wc.font=FS(TYPE.label);
      wc.fillStyle=INK; wc.fillText('MERIDIAN STRONGBOX',ct.x+1,ct.y-lift-d2-25);
      wc.fillStyle='#ffc04a'; wc.fillText('MERIDIAN STRONGBOX',ct.x,ct.y-lift-d2-26);

'@ @'
      wc.textAlign='center'; wc.font=FS(TYPE.label);
      var _stw=wc.measureText('MERIDIAN STRONGBOX').width, _spx=wlPx();
      if(!wlUnder(ct.x-_stw/2,ct.y-lift-d2-26-_spx,_stw,_spx*1.3)){   // v31.xx (cw-trcol2): not over the corner column or the score plate
      wc.fillStyle=INK; wc.fillText('MERIDIAN STRONGBOX',ct.x+1,ct.y-lift-d2-25);
      wc.fillStyle='#ffc04a'; wc.fillText('MERIDIAN STRONGBOX',ct.x,ct.y-lift-d2-26);
      }

'@

SubRx @'
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    wc.fillStyle=INK; wc.fillText(F.name||'THE FORGE',fx+1,fy-83);
    wc.fillStyle=FORGE_GOLD; wc.fillText(F.name||'THE FORGE',fx,fy-84);

'@ @'
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    var _ftw=wc.measureText(F.name||'THE FORGE').width, _fpx=wlPx();
    if(!wlUnder(fx-_ftw/2,fy-84-_fpx,_ftw,_fpx*1.3)){   // v31.xx (cw-trcol2): not over the corner column or the score plate
    wc.fillStyle=INK; wc.fillText(F.name||'THE FORGE',fx+1,fy-83);
    wc.fillStyle=FORGE_GOLD; wc.fillText(F.name||'THE FORGE',fx,fy-84);
    }

'@

SubRx @'
hudPlate(cx-_pw0,-Math.round(8*z),_pw0*2,_ph0+Math.round(8*z),null,HUDC.plate);
'@ @'
hudPlate(cx-_pw0,-Math.round(8*z),_pw0*2,_ph0+Math.round(8*z),null,HUDC.plate); SCOREBOX.g=G; SCOREBOX.x=cx-_pw0; SCOREBOX.y=0; SCOREBOX.w=_pw0*2; SCOREBOX.h=_ph0;   /* v31.xx (cw-trcol2): where the plate is, for the world labels that keep clear of it */
'@

SubRx @'
var VER='31.49';
'@ @'
var VER='31.50';
'@

$pat = "(?m)^  now:'v31\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.50: The corner column is 300 wide, and the names of caches and people no longer show through the gaps in the HUD. Check 31.50 fails on v31.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
