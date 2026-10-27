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

# FOG OF WAR FIXES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
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

'@ @'
function fowLive(x,y,r){
  if(CFG.fogWar!==1||!G||!G.player||G.sim) return true;
  var p=G.player, dx, dy, d, k, i, e, R=VF(), A=Math.max(70,AMBR()), r0=(r>0)?+r:0;
  // cw-fowfix (review 10-27): Superhot holds G.t still while he turns, so the shapes are also rebuilt when he moves or turns, and
  // render2D drops them once a frame at the air pass (a mate moves while G.t stands still)
  if(G._fwlT!==G.t||G._fwlX!==p.x||G._fwlY!==p.y||G._fwlF!==p.face||!G._fwlE){
    G._fwlT=G.t; G._fwlX=p.x; G._fwlY=p.y; G._fwlF=p.face; G._fwlE=[];
    var eyes=[{x:p.x,y:p.y,f:p.face}], segs=G.vseg||G.map.segs;
    if(CFG.sharedSight!==0&&NET.on){ try{ var M=netMates(); for(i=0;i<M.length;i++) eyes.push({x:M[i].x,y:M[i].y,f:M[i].f}); }catch(_m){} }
    for(i=0;i<eyes.length;i++){ e=eyes[i]; if(!isFinite(e.x)||!isFinite(e.y)||!isFinite(e.f)) continue; var poly=buildVisPoly(e.x,e.y,e.f,segs); if(poly&&poly.length>=3) G._fwlE.push({x:e.x,y:e.y,poly:poly}); }
  }
  dx=x-p.x; dy=y-p.y; if(Math.sqrt(dx*dx+dy*dy)-r0<A) return true;
  for(i=0;i<G._fwlE.length;i++){ e=G._fwlE[i]; dx=x-e.x; dy=y-e.y; d=Math.sqrt(dx*dx+dy*dy);
    if(d-r0<A||d<=r0+6) return true;
    // cw-fowfix: tested r0+6 units toward the eye: a wall hit lies on the edge of the shape, and a smoke cloud (r0, its radius) is a wall
    // to sight itself, so from outside only its near edge is ever in the shape
    if(d-r0<=R){ k=(r0+6)/d; if(fowInPoly(x-dx*k,y-dy*k,e.poly)) return true; } }
  return false;
}
'@

SubRx @'
if(!fowLive(sm.x,sm.y)) continue;   // v28.xx (cw-cx-fowlive-rest): lingering smoke is live action too
'@ @'
if(!fowLive(sm.x,sm.y,sm.r)) continue;   // v28.xx (cw-cx-fowlive-rest): lingering smoke is live action too; cw-fowfix: by its near edge (smoke blocks sight, so its middle is never in sight from outside)
'@

SubRx @'
  var _BLS=(G.fxBullets&&G.fxBullets.length)?G.bullets.concat(G.fxBullets):G.bullets;   // v16.21
'@ @'
  G._fwlE=null;   // cw-fowfix: fowLive rebuilds its sight shapes once a frame
  var _BLS=(G.fxBullets&&G.fxBullets.length)?G.bullets.concat(G.fxBullets):G.bullets;   // v16.21
'@

SubRx @'
function fowInPoly(x,y,poly){ var c=false,i,j,a,b; for(i=0,j=poly.length-1;i<poly.length;j=i++){ a=poly[i]; b=poly[j]; if(((a.y>y)!==(b.y>y))&&(x<(b.x-a.x)*(y-a.y)/(b.y-a.y)+a.x)) c=!c; } return c; }
'@ @'
function fowInPoly(x,y,poly){ var w=0,i,j,a,b,c; for(i=0,j=poly.length-1;i<poly.length;j=i++){ a=poly[j]; b=poly[i]; c=(b.x-a.x)*(y-a.y)-(x-a.x)*(b.y-a.y); if(a.y<=y){ if(b.y>y&&c>0) w++; } else if(b.y<=y&&c<0) w--; } return w!==0; }   // cw-fowfix: the nonzero rule, as the fog sheet fills the same shape (buildVisPoly folds over itself facing west)
'@

SubRx @'
  if(!(G._fowT>G.t-0.1)){
    G._fowT=G.t;
'@ @'
  if(!(G._fowT>G.t-0.1)||(G._fowT===G.t&&(G._fowF!==p.face||G._fowX!==p.x||G._fowY!==p.y))){   // cw-fowfix: Superhot holds G.t still while he turns
    G._fowT=G.t; G._fowF=p.face; G._fowX=p.x; G._fowY=p.y;
'@

SubRx @'
b=BOOMS[i];t=(G.t||0)-b.t0;if(b.g!==G||t>4.6||t<-2){BOOMS.splice(i,1);continue;}if(t<0||b.x<vx0||b.x>vx1||b.y<vy0||b.y>vy1)continue;
'@ @'
b=BOOMS[i];t=(G.t||0)-b.t0;if(b.g!==G||t>4.6||t<-2){BOOMS.splice(i,1);continue;}if(t<0||b.x<vx0||b.x>vx1||b.y<vy0||b.y>vy1)continue;if(!fowLive(b.x,b.y))continue; // cw-fowfix: the pixel look blast is gated as gfxBoomDraw is
'@

SubRx @'
var VER='35.16';
'@ @'
var VER='35.17';
'@

$pat = "(?m)^  now:'v35\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.17: with fog of war on: ground in plain view counts as seen whichever way you face (facing west it did not, so it was never marked explored); turning in Superhot opens the live view at once and marks the ground you look at; wall hits in sight always show their puff and sparks; smoke clouds in plain view show; pixel look blasts out of sight stay hidden Check 35.17 fails on v35.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
