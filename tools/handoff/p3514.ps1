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

# FOG OF WAR GAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
d[q]=4; d[q+1]=5; d[q+2]=8; d[q+3]=F[i]?0:255;
'@ @'
d[q]=44; d[q+1]=47; d[q+2]=52; d[q+3]=F[i]?0:255;   /* cw-fow, his words 10-27: unexplored ground "should just be grayed out" */
'@

SubRx @'
function fowInPoly(x,y,poly){ var c=false,i,j,a,b;
'@ @'
// cw-fow, his words 10-27: "once I've seen it and walk away, it shows what's there but its darkened and I can't see live action there unless
// I look at it". With fog of war on, tracers, sparks, smoke puffs and blasts draw only where he (or his mate, with shared sight) can see right
// now, by the same shapes the fog sheet cuts open (the sight cone out to VF, and the plain circle of AMBR); the ground itself stays drawn
// under the fog. Off, everything draws as before.
function fowLive(x,y){
  if(CFG.fogWar!==1||!G||!G.player||G.sim) return true;
  var p=G.player, dx, dy, i, e, R=VF(), A2=Math.max(70,AMBR());
  A2*=A2;
  if(G._fwlT!==G.t||!G._fwlE){
    G._fwlT=G.t; G._fwlE=[];
    var eyes=[{x:p.x,y:p.y,f:p.face}], segs=G.vseg||G.map.segs;
    if(CFG.sharedSight!==0&&NET.on){ try{ var M=netMates(); for(i=0;i<M.length;i++) eyes.push({x:M[i].x,y:M[i].y,f:M[i].f}); }catch(_m){} }
    for(i=0;i<eyes.length;i++){ e=eyes[i]; if(!isFinite(e.x)||!isFinite(e.y)||!isFinite(e.f)) continue; var poly=buildVisPoly(e.x,e.y,e.f,segs); if(poly&&poly.length>=3) G._fwlE.push({x:e.x,y:e.y,poly:poly}); }
  }
  dx=x-p.x; dy=y-p.y; if(dx*dx+dy*dy<A2) return true;
  for(i=0;i<G._fwlE.length;i++){ e=G._fwlE[i]; dx=x-e.x; dy=y-e.y; if(dx*dx+dy*dy<A2) return true; if(dx*dx+dy*dy<=R*R&&fowInPoly(x,y,e.poly)) return true; }
  return false;
}
function fowInPoly(x,y,poly){ var c=false,i,j,a,b;
'@

SubRx @'
var b=_BLS[i],bm=Math.sqrt(b.vx*b.vx+b.vy*b.vy)||1;
'@ @'
var b=_BLS[i],bm=Math.sqrt(b.vx*b.vx+b.vy*b.vy)||1; if(!fowLive(b.x,b.y)) continue;   // cw-fow: no tracer out of sight with fog of war on
'@

SubRx @'
    var sp=G.sparks[i];
    wc.globalAlpha=clamp(1-sp.t/sp.life,0,1);
'@ @'
    var sp=G.sparks[i];
    if(!fowLive(sp.x,sp.y)) continue;   // cw-fow
    wc.globalAlpha=clamp(1-sp.t/sp.life,0,1);
'@

SubRx @'
    var q=G.puffs[i],a2=1-q.t/q.life;
'@ @'
    var q=G.puffs[i],a2=1-q.t/q.life; if(!fowLive(q.x,q.y)) continue;   // cw-fow
'@

SubRx @'
    if(t<0||b.x<vx0||b.x>vx1||b.y<vy0||b.y>vy1) continue;
'@ @'
    if(t<0||b.x<vx0||b.x>vx1||b.y<vy0||b.y>vy1) continue;
    if(!fowLive(b.x,b.y)) continue;   // cw-fow: a blast out of sight is heard, not seen, with fog of war on
'@

SubRx @'
var VER='35.13';
'@ @'
var VER='35.14';
'@

$pat = "(?m)^  now:'v35\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.14: with fog of war on, unexplored ground is grey instead of black, and tracers, sparks, smoke and blasts outside your sight are not drawn; seen ground stays dimmed under the fog Check 35.14 fails on v35.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
