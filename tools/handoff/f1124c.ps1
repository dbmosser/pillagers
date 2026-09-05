$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE HOOK BUILDS THE RAID THE WAY THE PROBES DID. With the map pinned the
# numbers still disagreed with the survey (76 hits against 60 with feuds off,
# where the survey read 22 against 2), so the raw buildRaid(true) path is not
# the __deploy path the surveys and every other check trust. The hook now
# deploys through __deploy and steps through __rawStep, and reports the live
# CFG it ran under so a dial that did not reach the game is visible.
SubRx @'
  o=o||{}; pendSeed=(o.seed||9001)>>>0; G=null;
  if(o.mapIx!==undefined&&window.__P&&__P()) __P().mapIx=o.mapIx;
  G=buildRaid(true);
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={};
  if(o.park==='centre'){ px=(G.map.cols*G.map.cw)/2; py=(G.map.rows*G.map.ch)/2; }
  for(var s=0;s<steps;s++){
    p.x=px; p.y=py; p.hp=p.maxhp||100; p.downed=0; p.downT=0; p.vx=0; p.vy=0;
    try{ simStep(dt); }catch(e){ threw=String(e); break; }
'@ @'
  o=o||{};
  __deploy({kit:[],safe:null,mapIx:(o.mapIx===undefined?0:o.mapIx),seed:(o.seed||9001),sim:true});
  var live={mach:CFG.machVsRaider, feud:CFG.raiderFeud, greed:CFG.simGreed, sim:!!G.sim};
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={};
  if(o.park==='centre'){ px=(G.map.cols*G.map.cw)/2; py=(G.map.rows*G.map.ch)/2; }
  for(var s=0;s<steps;s++){
    p.x=px; p.y=py; p.hp=p.maxhp||100; p.downed=0; p.downT=0; p.vx=0; p.vy=0;
    try{ __rawStep(dt); }catch(e){ threw=String(e); break; }
'@
SubRx @'
  return {seed:o.seed||9001, mapIx:(window.__P&&__P())?__P().mapIx:null, buildings:(G.map.buildings||[]).length, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, outAt:outAt, timeline:tl};
'@ @'
  return {seed:o.seed||9001, mapIx:(o.mapIx===undefined?0:o.mapIx), buildings:(G.map.buildings||[]).length, live:live, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, outAt:outAt, timeline:tl};
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
