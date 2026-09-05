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

# THE HOOK NEVER SAID WHICH MAP. buildRaid reads the map from the profile, so
# __simRaiders ran on whichever map the profile last held; check 11.23 and the
# first cut of 11.24 both assumed COLD STORAGE and never pinned it. The hook
# takes mapIx now and every caller says which map it means.
SubRx @'
  o=o||{}; pendSeed=(o.seed||9001)>>>0; G=null;
  G=buildRaid(true);
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={};
'@ @'
  o=o||{}; pendSeed=(o.seed||9001)>>>0; G=null;
  if(o.mapIx!==undefined&&window.__P&&__P()) __P().mapIx=o.mapIx;
  G=buildRaid(true);
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={};
'@
SubRx @'
  return {seed:o.seed||9001, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, outAt:outAt, timeline:tl};
'@ @'
  return {seed:o.seed||9001, mapIx:(window.__P&&__P())?__P().mapIx:null, buildings:(G.map.buildings||[]).length, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, outAt:outAt, timeline:tl};
'@
# check 11.24, three calls
SubRx @'
     var on=__simRaiders({seed:9001, park:'centre'});
'@ @'
     var on=__simRaiders({seed:9001, mapIx:0, park:'centre'});
     if(on.buildings!==20) return 'SKIP: the centre raid built '+on.buildings+' buildings, not the 20 of COLD STORAGE';
'@
SubRx @'
     var off=__simRaiders({seed:9001, park:'centre'});
'@ @'
     var off=__simRaiders({seed:9001, mapIx:0, park:'centre'});
'@
SubRx @'
     var far=__simRaiders({seed:9001, park:'far'});
'@ @'
     var far=__simRaiders({seed:9001, mapIx:0, park:'far'});
'@
# check 11.23, two calls
SubRx @'
     var on=__simRaiders({seed:9001});
     if(on.threw) bad.push('the parked raid threw: '+on.threw);
'@ @'
     var on=__simRaiders({seed:9001, mapIx:0});
     if(on.threw) bad.push('the parked raid threw: '+on.threw);
     if(on.buildings!==20) return 'SKIP: the parked raid built '+on.buildings+' buildings, not the 20 of COLD STORAGE';
'@
SubRx @'
     var off=__simRaiders({seed:9001});
     if(off.threw) bad.push('the peace arm threw: '+off.threw);
'@ @'
     var off=__simRaiders({seed:9001, mapIx:0});
     if(off.threw) bad.push('the peace arm threw: '+off.threw);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
