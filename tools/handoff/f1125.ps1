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

# ONE: the scorecard counts rounds by who fired them. Every bullet object is
# tagged once, so a round that lives ten steps is counted once.
SubRx @'
    var rosH=G.roster||[]; for(var h=0;h<rosH.length;h++){ var eh=rosH[h].ref, kh=eh.name; if(rosH[h].out) continue; if(lastHp[kh]!==undefined&&eh.hp<lastHp[kh]) hits++; lastHp[kh]=eh.hp; if(eh.downed&&!seenDown[kh]){ seenDown[kh]=1; downs++; } }
'@ @'
    var rosH=G.roster||[]; for(var h=0;h<rosH.length;h++){ var eh=rosH[h].ref, kh=eh.name; if(rosH[h].out) continue; if(lastHp[kh]!==undefined&&eh.hp<lastHp[kh]) hits++; lastHp[kh]=eh.hp; if(eh.downed&&!seenDown[kh]){ seenDown[kh]=1; downs++; } }
    var BL=G.bullets||[]; for(var bq=0;bq<BL.length;bq++){ var bb=BL[bq]; if(bb.__sr) continue; bb.__sr=1; var ok=bb.owner&&bb.owner.kind; if(bb.owner===G.player) playerShots++; else if(ok==='raider') raiderShots++; else machShots++; }
'@
SubRx @'
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={};
'@ @'
  var px=-3000, py=-3000, hits=0, downs=0, lastHp={}, seenDown={}, raiderShots=0, machShots=0, playerShots=0;
'@
SubRx @'
  return {seed:o.seed||9001, mapIx:(o.mapIx===undefined?0:o.mapIx), buildings:(G.map.buildings||[]).length, live:live, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, outAt:outAt, timeline:tl};
'@ @'
  return {seed:o.seed||9001, mapIx:(o.mapIx===undefined?0:o.mapIx), buildings:(G.map.buildings||[]).length, live:live, park:(o.park==='centre'?'centre':'far'), horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, hits:hits, downs:downs, raiderShots:raiderShots, machShots:machShots, playerShots:playerShots, outAt:outAt, timeline:tl};
'@

# TWO: the check, before the v11.24 entry.
SubRx @'
  {v:'11.24',what:'rival crews feud where the player can see them: parked in the middle of COLD STORAGE at peace with the machines, pillagers hit, down and kill each other, and the raiderFeud dial is what decides it',
'@ @'
  {v:'11.25',what:'a pillager out of the player sight fires back only when engageNear is lifted: at 600 as shipped he fires zero rounds in a whole raid while the machines fire dozens, at 0 he fires, and the dial rolls no dice',
   run:function(){
     if(!(window.__simRaiders&&window.__cfg)) return 'SKIP: this fixture cannot run a parked sim raid';
     var bad=[];
     // THE WORLD AS SHIPPED: far seat, machines at war, COLD STORAGE seed 9001.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var g6=__simRaiders({seed:9001, mapIx:0, park:'far'});
     if(g6.threw) bad.push('the far raid threw: '+g6.threw);
     if(g6.buildings!==20) return 'SKIP: the far raid built '+g6.buildings+' buildings, not the 20 of COLD STORAGE';
     if(g6.live.mach!==1) return 'SKIP: machVsRaider is not 1 here, so the war this check is about is off';
     // CONTROL ONE: the machines are firing, or the silence below is nothing.
     if(g6.machShots<20) bad.push('control: the machines fired only '+g6.machShots+' rounds in a whole far raid, so there is no war to answer');
     // THE FINDING, as shipped: not one round from a pillager all raid. This is
     // the rule the dial keeps until he rules; the check pins that it is real.
     if(g6.raiderShots!==0) bad.push('with engageNear 600 the pillagers fired '+g6.raiderShots+' rounds out of the player sight, so the gate is not where the finding says it is');
     // THE DIAL: lifted, they answer.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __cfg({engageNear:0});
     var g0=__simRaiders({seed:9001, mapIx:0, park:'far'});
     if(g0.threw) bad.push('the lifted raid threw: '+g0.threw);
     if(g0.live&&g0.live.mach!==1) bad.push('control: the lifted arm lost the war dial');
     if(!(g0.raiderShots>0)) bad.push('with engageNear 0 the pillagers still fired '+g0.raiderShots+' rounds out of sight, so the dial does not reach the three sites');
     // CONTROL TWO: the dial rolls no dice. Both arms open with the same roster.
     if(g6.timeline.length&&g0.timeline.length&&g6.timeline[0][1]!==g0.timeline[0][1]) bad.push('control: the arms opened with '+g6.timeline[0][1]+' and '+g0.timeline[0][1]+' pillagers, so the seeded stream moved');
     return bad.length?bad.join('; '):null; }},
  {v:'11.24',what:'rival crews feud where the player can see them: parked in the middle of COLD STORAGE at peace with the machines, pillagers hit, down and kill each other, and the raiderFeud dial is what decides it',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
