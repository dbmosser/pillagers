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

# ONE: the hook takes a seat. park:'far' (default) is v11.23, out of every sight
# test; park:'centre' pins the player to the middle of the map, alive, still,
# with whatever he was deployed with, so the things that only happen within
# sight of him (rival crew feuds, gated to 600 units because line of sight is
# only answerable near him) can be watched. Raider hits are counted on the way.
SubRx @'
window.__simRaiders=function(o){
  o=o||{}; pendSeed=(o.seed||9001)>>>0; G=null;
  G=buildRaid(true);
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  for(var s=0;s<steps;s++){
    p.x=-3000; p.y=-3000; p.hp=p.maxhp||100; p.downed=0; p.downT=0;
    try{ simStep(dt); }catch(e){ threw=String(e); break; }
    T+=dt; if(G.over){ over={how:G.over,at:Math.round(T)}; break; }
'@ @'
window.__simRaiders=function(o){
  o=o||{}; pendSeed=(o.seed||9001)>>>0; G=null;
  G=buildRaid(true);
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={};
  if(o.park==='centre'){ px=(G.map.cols*G.map.cw)/2; py=(G.map.rows*G.map.ch)/2; }
  for(var s=0;s<steps;s++){
    p.x=px; p.y=py; p.hp=p.maxhp||100; p.downed=0; p.downT=0; p.vx=0; p.vy=0;
    try{ simStep(dt); }catch(e){ threw=String(e); break; }
    T+=dt; if(G.over){ over={how:G.over,at:Math.round(T)}; break; }
    var rosH=G.roster||[]; for(var h=0;h<rosH.length;h++){ var eh=rosH[h].ref, kh=eh.name; if(rosH[h].out) continue; if(lastHp[kh]!==undefined&&eh.hp<lastHp[kh]) hits++; lastHp[kh]=eh.hp; if(eh.downed&&!seenDown[kh]){ seenDown[kh]=1; downs++; } }
'@
SubRx @'
  return {seed:o.seed||9001, horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, outAt:outAt, timeline:tl};
};
'@ @'
  return {seed:o.seed||9001, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, outAt:outAt, timeline:tl};
};
'@

# TWO: the check, before the v11.23 entry.
SubRx @'
  {v:'11.23',what:'the pillagers own raid can be read to the clock: the parked, unkillable player never ends the raid, the roster tally is complete, and machines at war with pillagers is what decides whether a pillager gets out',
'@ @'
  {v:'11.24',what:'rival crews feud where the player can see them: parked in the middle of COLD STORAGE at peace with the machines, pillagers hit, down and kill each other, and the raiderFeud dial is what decides it',
   run:function(){
     if(!(window.__simRaiders&&window.__cfg)) return 'SKIP: this fixture cannot run a parked sim raid';
     var bad=[];
     // Seed 9001 is a hot seed (crewsHot is seed mod 10 below 6, and 9001 gives
     // 1), COLD STORAGE, the machines at peace so every hit on a pillager is a
     // pillager's, the player deployed as usual and pinned still to the map centre.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __cfg({machVsRaider:0});
     var on=__simRaiders({seed:9001, park:'centre'});
     if(on.threw) bad.push('the centre-parked raid threw: '+on.threw);
     if(on.over||on.ranTo<on.horizon-1) bad.push('the centre-parked raid ended at '+on.ranTo+' of '+on.horizon+' seconds ('+JSON.stringify(on.over)+'), so a pinned player at the centre still ends the raid');
     // THE FINDING. Feuds fire in sight of the player: hits between pillagers,
     // and at least one man downed or dead by the end. Measured on v11.23: 22
     // hits, 3 downed, 3 dead.
     if(on.hits<5) bad.push('only '+on.hits+' hits on pillagers in 540 seconds with the player in the middle of the map, so rival crews are not feuding where they should');
     if(on.downs+on.dead<1) bad.push('no pillager was downed or killed by another in 540 seconds at the centre (hits '+on.hits+')');
     // CONTROL ONE: the raid was populated.
     if(on.roster<7) bad.push('control: only '+on.roster+' pillagers on the roster');
     // CONTROL TWO: raiderFeud 0 turns it off. Same seat, same seed, same peace:
     // the hits must fall to a small fraction, or the hits above were never
     // feud hits (the fists player at the centre, say) and the finding is empty.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __cfg({machVsRaider:0, raiderFeud:0});
     if(__cfg().raiderFeud!==0) return 'SKIP: raiderFeud cannot be set to 0 here';
     var off=__simRaiders({seed:9001, park:'centre'});
     if(off.threw) bad.push('the feud-off raid threw: '+off.threw);
     if(!(off.hits*3<on.hits)) bad.push('control: with raiderFeud 0 pillagers still took '+off.hits+' hits against '+on.hits+' with feuds on, so the dial does not decide and the hits are not feud hits');
     // CONTROL THREE: the far seat of v11.23 sees none of it, which is the blind
     // spot v11.23 misread; if the far seat ever sees feud hits, the 600 unit
     // gate has moved and v11.23's numbers need re-reading.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __cfg({machVsRaider:0});
     var far=__simRaiders({seed:9001, park:'far'});
     if(far.hits>0) bad.push('the far seat saw '+far.hits+' hits on pillagers at peace, so feuds now fire out of sight of the player and the 600 unit gate has moved');
     return bad.length?bad.join('; '):null; }},
  {v:'11.23',what:'the pillagers own raid can be read to the clock: the parked, unkillable player never ends the raid, the roster tally is complete, and machines at war with pillagers is what decides whether a pillager gets out',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
