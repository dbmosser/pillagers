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

# A CURVED BODY MOVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function buildPath(cx,ty,P,grow){
'@ @'
// v20.02, HIS ORDER (2026-10-08): "add jiggle physics if possible". A small damped spring for the chest and the hips of a Curved
// body: when the torso changes speed (each footfall, a start, a stop, a landing) they keep going for a moment and settle back.
// Kept on the figure's own object, as the hair sway is. Cosmetic only: it never runs in the sim steppers and draws no random
// numbers. A second draw in the same frame (the see-through ghost) reuses that frame's pose rather than stepping again.
var JIG0={c:0,h:0}, HUBOWN={wep:null};
function bodyJiggle(o,ty,now){
  if(!o||typeof o!=='object') return JIG0;
  var J=o._jg, dt, v, a;
  if(!J) J=o._jg={c:0,h:0,vc:0,vh:0,py:ty,pv:0,t:0};
  if(now===undefined) now=(typeof performance!=='undefined'&&performance.now)?performance.now():0;
  dt=(now-J.t)/1000;
  if(!J.t||dt>0.25||!isFinite(ty)){ J.t=now; J.py=ty; J.pv=0; J.c=J.h=J.vc=J.vh=0; return J; }
  if(dt<0.004) return J;
  J.t=now; v=(ty-J.py)/dt; a=v-J.pv; J.py=ty; J.pv=v;
  if(a>400) a=400; else if(a<-400) a=-400;
  J.vc-=a*0.40; J.vh-=a*0.26;
  J.vc+=(-320*J.c-9*J.vc)*dt; J.c+=J.vc*dt;
  J.vh+=(-240*J.h-9*J.vh)*dt; J.h+=J.vh*dt;
  if(J.c>1.5){ J.c=1.5; J.vc=0; } else if(J.c<-1.5){ J.c=-1.5; J.vc=0; }
  if(J.h>0.9){ J.h=0.9; J.vh=0; } else if(J.h<-0.9){ J.h=-0.9; J.vh=0; }
  return J;
}
var BUILD_CPT=BUILD_CURVED.map(function(p){ return p.slice(); });   // the Curved outline with the hips where the spring has them
function buildPath(cx,ty,P,grow){
'@

SubRx @'
  var P=(b==='broad')?BUILD_BROAD:BUILD_CURVED, by, sh, bl;
'@ @'
  var P=(b==='broad')?BUILD_BROAD:BUILD_CURVED, by, sh, bl;
  if(b==='curved'&&jh){ BUILD_CPT[4][1]=BUILD_CURVED[4][1]+jh*.6; BUILD_CPT[5][1]=BUILD_CURVED[5][1]+jh*.4; P=BUILD_CPT; }   // v20.02: the hips ride the spring
'@

SubRx @'
  var _BID=st.hero?cosWorn('build'):(st.build||'lean'), _BLD=(_BID==='broad'||_BID==='curved')?_BID:null;
'@ @'
  var _BID=st.hero?cosWorn('build'):(st.build||'lean'), _BLD=(_BID==='broad'||_BID==='curved')?_BID:null, _JG=(_BLD==='curved')?bodyJiggle(st.own,ty):JIG0;
'@

SubRx @'
drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,_TRS,0,0,x,swing*.5,swing2*.5);
'@ @'
drawBuildTorso(_BLD,x+leanX,ty,cc,cHi,cLo,_TRS,_JG.c,_JG.h,x,swing*.5,swing2*.5);
'@

SubRx @'
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,
         own:{wep:null}});
'@ @'
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,
         own:HUBOWN});   // v20.02: one own object on the floor, so the jiggle spring has a home
'@

SubRx @'
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});
'@ @'
        {hero:1,moving:p.moving,sprint:false,ads:false,hurt:0,rl:0,own:HUBOWN});
'@

SubRx @'
var VER='20.01';
'@ @'
var VER='20.02';
'@

$pat = "(?m)^  now:'v20\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.02: A Curved body has jiggle when it moves. Check 20.02 fails on v20.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
