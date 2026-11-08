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

# THREE LANDMARK PATROLS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function careerPostBuild(g){
'@ @'
// v28.xx (cw-cx-patrolroutes): his g-46, "Yes, a few patrols". Setup never spends the raid stream.
function patrolRoutes(g){
  if(!g||g.sim||!g.map||g.patrolMade) return;
  g.patrolMade=1;
  sideStream(g.seed,81,function(){
    var m=g.map, bodies=g.ents.filter(function(e){
      return (e.kind==='sentry'||e.kind==='crawler')&&!e.camp&&!e.elite&&!e.boss&&!e.sleep&&e.state!=='dormant'&&!buildingAtPt(m,e.x,e.y);
    });
    bodies.sort(function(a,b){ return (a.kind==='crawler'?1:0)-(b.kind==='crawler'?1:0); });
    var made=0;
    for(var i=0;i<bodies.length&&made<3;i++){
      var e=bodies[i], route=[], length=0;
      var lm=(m.landmarks||[]).map(function(l){ return {x:l.x+l.w/2,y:l.y+l.h/2}; });
      lm.sort(function(a,b){ return dist(e,a)-dist(e,b); }); lm=lm.slice(0,4);
      for(var j=0;j<4;j++){
        var chosen=null;
        for(var n=0;n<1204&&!chosen;n++){
          var p=n<lm.length?lm[n]:freeSpot(m,24), b=buildingAtPt(m,p.x,p.y);
          if(b) p=outOfBuilding(b,p.x,p.y,e.r+12);
          if(buildingAtPt(m,p.x,p.y)||!navReachable(m,p.x,p.y)) continue;
          if(!route.length){ if(dist(e,p)>650) continue; }
          else {
            var leg=dist(route[route.length-1],p), close=dist(p,route[0]);
            if(leg<400||leg>1200) continue;
            // v28.xx (cw-cx-patrolroutes): leave time for pauses and the approach at sentry walking speed.
            if(length+leg+Math.max(400,close)+(3-j)*400>2600) continue;
            if(j===3&&(close<400||close>1200)) continue;
            var repeat=false;
            for(var q=0;q<route.length;q++) if(dist(route[q],p)<120) repeat=true;
            if(repeat) continue;
          }
          chosen={x:p.x,y:p.y};
        }
        if(!chosen) break;
        if(route.length) length+=dist(route[route.length-1],chosen);
        route.push(chosen);
      }
      if(route.length!==4) continue;
      // v28.xx (cw-cx-patrolroutes): reject disconnected stops and detours too long for a learnable circuit.
      var walk=0, from=e, valid=true;
      for(var h=0;h<5;h++){
        var to=route[h%4], path=navPath(m.navD||m.nav,from.x,from.y,to.x,to.y,e.r);
        if(!path){ valid=false; break; }
        var prev=from;
        for(var t=0;t<path.length;t++){ walk+=dist(prev,path[t]); prev=path[t]; }
        walk+=dist(prev,to); from=to;
      }
      if(!valid||walk>3350) continue;
      e.route=route; e.ri=0; e.routeHold=0; e.routeResume=0;
      e.path=null; e.pathT=0; made++;
    }
  });
}
// v28.xx (cw-cx-patrolroutes): only the existing host idle branch calls this; combat stays in charge.
function patrolWalk(e,dt){
  var r=e.route, i;
  if(e.routeResume){
    var best=Infinity;
    for(i=0;i<r.length;i++){ var d=dist(e,r[i]); if(d<best){ best=d; e.ri=i; } }
    e.routeResume=0; e.routeHold=0; e.path=null; e.pathT=0;
  }
  var p=r[e.ri], next=r[(e.ri+1)%4];
  e.tx=p.x; e.ty=p.y;
  if(e.routeHold>0){
    e.moving=false; e.routeHold=Math.max(0,e.routeHold-dt);
    if(!e.routeHold){ e.ri=(e.ri+1)%4; e.path=null; e.pathT=0; }
    return Math.atan2(next.y-e.y,next.x-e.x);
  }
  if(dist(e,p)<30){ e.routeHold=2; e.moving=false; return Math.atan2(next.y-e.y,next.x-e.x); }
  navSeek(e,p.x,p.y,e.spd*.45,dt);
  return Math.atan2(p.y-e.y,p.x-e.x);
}
function careerPostBuild(g){
'@

SubRx @'
  try{ arcadeVaults(g); }catch(_cv){}   // v24.xx (careervault): the two DEMO vaults (side stream)
'@ @'
  try{ arcadeVaults(g); }catch(_cv){}   // v24.xx (careervault): the two DEMO vaults (side stream)
  patrolRoutes(g); // v28.xx (cw-cx-patrolroutes): after vault walls, in the career post build only.
'@

SubRx @'
  try{ arcadeVaults(g); }catch(_av){}   // v23.9x (feat4b): two strongrooms sealed into vaults (side stream)
'@ @'
  try{ arcadeVaults(g); }catch(_av){}   // v23.9x (feat4b): two strongrooms sealed into vaults (side stream)
  patrolRoutes(g); // v28.xx (cw-cx-patrolroutes): the demo uses the same routes.
'@

SubRx @'
    var _se=G.ents[_sq];
'@ @'
    var _se=G.ents[_sq];
    // v28.xx (cw-cx-patrolroutes): remember interruptions even when another AI branch returns early.
    if(_se.route&&_se.state!=='patrol') _se.routeResume=1;
'@

SubRx @'
      if(e.kind==='snitch'&&e.state==='patrol'&&buildingAtPt(G.map,e.x,e.y)) navSeek(e,e.tx,e.ty,e.spd*.45,dt);
      else moveToward(e,e.tx,e.ty,e.spd*.45,dt);
      want=Math.atan2(e.ty-e.y,e.tx-e.x);
      if(dist(e,{x:e.tx,y:e.ty})<30) e[_wf]=0;
'@ @'
      // v28.xx (cw-cx-patrolroutes): the timer above still spends freeSpot and rnd, then the fixed route owns movement.
      if(e.route) want=patrolWalk(e,dt);
      else {
        if(e.kind==='snitch'&&e.state==='patrol'&&buildingAtPt(G.map,e.x,e.y)) navSeek(e,e.tx,e.ty,e.spd*.45,dt);
        else moveToward(e,e.tx,e.ty,e.spd*.45,dt);
        want=Math.atan2(e.ty-e.y,e.tx-e.x);
        if(dist(e,{x:e.tx,y:e.ty})<30) e[_wf]=0;
      }
'@

SubRx @'
var VER='37.57';
'@ @'
var VER='37.58';
'@

$pat = "(?m)^  now:'v37\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.58: Three ordinary outdoor machines walk four fixed stops, wait two seconds, and resume at the nearest stop after combat. Check 37.58 fails on v37.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
