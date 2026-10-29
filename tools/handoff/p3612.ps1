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

# WORLD NAME TAGS KEEP THEIR OWN SPACE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wlPx(){ var f=wc.font, m; if(f!==_wlF){ _wlF=f; m=/([\d.]+)px/.exec(f); _wlP=m?+m[1]:12; } return _wlP; }   // the size of the font wc is set to, in the units it draws in

'@ @'
// v28.xx (cw-cx-tagstack): audit 9, adjacent machine names overprinted each other. Reserve the drawn text, crew block and health pip; later names stack above earlier names. Only draw coordinates move.
var WLTEXT={g:null,boxes:[]};
function wlTagPlace(x,y,w,h){
  var z=WTX.z, gap=4*Math.max(1,hudRes()), b={x:(x-WTX.ox)*z,y:(y-WTX.oy)*z,w:w*z,h:h*z}, i,q,hit;
  if(!(z>0)||b.x+b.w<0||b.x>W) return null;
  do{
    hit=false;
    for(i=0;i<WLTEXT.boxes.length;i++){
      q=WLTEXT.boxes[i];
      if(b.x<q.x+q.w+gap&&b.x+b.w>q.x-gap&&b.y<q.y+q.h+gap&&b.y+b.h>q.y-gap){b.y=q.y-gap-b.h;hit=true;break;}
    }
  }while(hit&&b.y>=gap);
  if(b.y<gap||b.y>H) return null;
  WLTEXT.boxes.push(b);
  return WTX.oy+b.y/z;
}
function wlPx(){ var f=wc.font, m; if(f!==_wlF){ _wlF=f; m=/([\d.]+)px/.exec(f); _wlP=m?+m[1]:12; } return _wlP; }   // the size of the font wc is set to, in the units it draws in

'@

SubRx @'
  var _wtA=function(){

'@ @'
  var _wtA=function(){
  WLTEXT.g=G; WLTEXT.boxes.length=0; // v28.xx (cw-cx-tagstack): this frame only, shared with the later extraction chip pass.

'@

SubRx @'
    for(var _cq=0;_cq<_ctq.length;_cq++){ var _cg=_ctq[_cq]; wc.font=FS(_cg.f||TYPE.head); var _cw=wc.measureText(_cg.t).width; if(!_cg.always&&wlUnder(_cg.x-_cw/2,_cg.y-_cpx,_cw,_cpx*1.3)) continue; wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cg.y+1); wc.fillStyle=_cg.c||'#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cg.y); }

'@ @'
    // v28.xx (cw-cx-tagstack): cache names reserve their actual font bounds before the extraction distance chip is placed.
    for(var _cq=0;_cq<_ctq.length;_cq++){
      var _cg=_ctq[_cq]; wc.font=FS(_cg.f||TYPE.head);
      var _cm=wc.measureText(_cg.t), _cw=_cm.width, _ca=_cm.actualBoundingBoxAscent||wlPx(), _cd=_cm.actualBoundingBoxDescent||wlPx()*0.25;
      if(!_cg.always&&wlUnder(_cg.x-_cw/2,_cg.y-_ca-2,_cw,_ca+_cd+4)) continue;
      var _ctop=wlTagPlace(_cg.x-_cw/2-2,_cg.y-_ca-2,_cw+4,_ca+_cd+4);
      if(_ctop===null) continue;
      var _cy=_ctop+_ca+2;
      wc.fillStyle=INK; wc.fillText(_cg.t,_cg.x+1,_cy+1); wc.fillStyle=_cg.c||'#e6b4ff'; wc.fillText(_cg.t,_cg.x,_cy);
    }

'@

SubRx @'
    if(wlUnder(ne.x-tw/2-11,ne.y-lift-ph2+3,tw+22,ph2+5)) continue;   // v31.xx (cw-trcol2): a nameplate (with its crew block and health pip) is not drawn over the corner column or the score plate

'@ @'
    // v28.xx (cw-cx-tagstack): include the crew block and wounded health pip in the occupied box. If there is no room above the screen, omit only this crowded name.
    var _ntop=wlTagPlace(ne.x-tw/2-11,ne.y-lift-ph2+3,tw+22,ph2+5);
    if(_ntop===null||wlUnder(ne.x-tw/2-11,_ntop,tw+22,ph2+5)) continue;
    lift=ne.y-_ntop-ph2+3;

'@

SubRx @'
    if(G.cornerBox) L.push(G.cornerBox);

'@ @'
    if(G.cornerBox) L.push(G.cornerBox);
    // v28.xx (cw-cx-tagstack): the CEO cache-name P0: give the chip its own space beside this frame's world labels, including the arrow and margin.
    if(WLTEXT.g===G) for(i=0;i<WLTEXT.boxes.length;i++) L.push(WLTEXT.boxes[i]);

'@

SubRx @'
var VER='36.11';
'@ @'
var VER='36.12';
'@

$pat = "(?m)^  now:'v36\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.12: Nearby world names stack when their boxes would overlap. The extraction distance chip clears cache names. Check 36.12 fails on v36.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
