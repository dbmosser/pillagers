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

# ONE: the hook. Runs one seeded sim raid to the raid clock with the player
# parked outside the world and kept alive, so the pillagers' own outcome can be
# read to the end instead of to the moment the robot dies or leaves.
SubRx @'
// Samples one sim raid so a stall can be told apart from a decision never made.
window.__simTraceSeed=function(seed){
'@ @'
// v11.23: the pillagers' own raid. The sim stops updating every entity the
// moment the player dies or extracts, so every pillager number ever read off
// it was cut at the robot's death, about two minutes in. This parks the player
// at -3000,-3000, out of every sight test, pins his health, and runs the raid
// to CFG.raidSec, then tallies the roster: out, alive, downed, dead, and when
// each man who got out did. Arms are set by the caller through __cfg.
window.__simRaiders=function(o){
  o=o||{}; pendSeed=(o.seed||9001)>>>0; G=null;
  G=buildRaid(true);
  var p=G.player, T=0, dt=0.15, horizon=(o.horizon||CFG.raidSec||540), steps=Math.round(horizon/dt), over=null, threw=null, tl=[], next=60;
  for(var s=0;s<steps;s++){
    p.x=-3000; p.y=-3000; p.hp=p.maxhp||100; p.downed=0; p.downT=0;
    try{ simStep(dt); }catch(e){ threw=String(e); break; }
    T+=dt; if(G.over){ over={how:G.over,at:Math.round(T)}; break; }
    if(T>=next){ next+=60; var ros0=G.roster||[], a0=0,o0=0,d0=0,x0=0; for(var q=0;q<ros0.length;q++){ var e0=ros0[q].ref; if(ros0[q].out) o0++; else if(e0.downed) d0++; else if(e0.hp<=0||e0.finished) x0++; else a0++; } tl.push([Math.round(T),ros0.length,o0,a0,d0,x0]); }
  }
  var ros=G.roster||[], present={}, i, e, out=0, alive=0, downed=0, dead=0, outAt=[];
  for(i=0;i<G.ents.length;i++) present[G.ents[i].name||('#'+i)]=1;
  for(i=0;i<ros.length;i++){ e=ros[i].ref; if(ros[i].out){ out++; outAt.push(Math.round(ros[i].outAt||0)); continue; }
    if(!present[e.name]) dead++; else if(e.downed) downed++; else if(e.hp<=0) dead++; else alive++; }
  return {seed:o.seed||9001, horizon:horizon, ranTo:Math.round(T), over:over, threw:threw, roster:ros.length, out:out, alive:alive, downed:downed, dead:dead, outAt:outAt, timeline:tl};
};
// Samples one sim raid so a stall can be told apart from a decision never made.
window.__simTraceSeed=function(seed){
'@

# TWO: the check, inserted before the v11.22 entry.
SubRx @'
  {v:'11.22',what:'no building on THE COLD MILE holds ANY pocket of floor nothing can reach, down to a 12 by 12 niche behind a table, on five seeds; the old furniture rules bring the niches back; and the repair pass demolishes nothing on seven seeds of both maps',
'@ @'
  {v:'11.23',what:'the pillagers own raid can be read to the clock: the parked, unkillable player never ends the raid, the roster tally is complete, and machines at war with pillagers is what decides whether a pillager gets out',
   run:function(){
     if(!(window.__simRaiders&&window.__cfg)) return 'SKIP: this fixture cannot run a parked sim raid';
     var bad=[];
     // THE INSTRUMENT. COLD STORAGE at seed 9001 with the shipping rules runs to
     // the raid clock with the player parked, and every man on the roster is
     // accounted for exactly once.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var on=__simRaiders({seed:9001});
     if(on.threw) bad.push('the parked raid threw: '+on.threw);
     if(on.over||on.ranTo<on.horizon-1) bad.push('the parked raid ended at '+on.ranTo+' of '+on.horizon+' seconds ('+JSON.stringify(on.over)+'), so the player still ends the raid from outside the world');
     if(on.out+on.alive+on.downed+on.dead!==on.roster) bad.push('the tally '+on.out+'+'+on.alive+'+'+on.downed+'+'+on.dead+' does not equal the roster of '+on.roster);
     // CONTROL ONE: the raid was populated, or every count above is zero for the
     // wrong reason. Seven spawn and the floor rule keeps adding men.
     if(on.roster<7) bad.push('control: only '+on.roster+' pillagers on the roster, the raid did not populate');
     // CONTROL TWO: with machines and pillagers at peace (machVsRaider 0, his
     // Q31 switched off) pillagers get out of this raid, and more of them than
     // with the war on. This is the direction of his own choice, measured, not
     // a balance number: it fails if the switch stops doing anything.
     __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __cfg({machVsRaider:0});
     if(__cfg().machVsRaider!==0) return 'SKIP: machVsRaider cannot be set to 0 here';
     var off=__simRaiders({seed:9001});
     if(off.threw) bad.push('the peace arm threw: '+off.threw);
     if(off.out<1) bad.push('control: with machVsRaider 0 no pillager got out of COLD STORAGE at seed 9001, so extraction itself is broken for pillagers');
     if(!(off.out>on.out)) bad.push('control: with the war off '+off.out+' pillagers got out against '+on.out+' with it on, so the switch no longer decides anything');
     // CONTROL THREE: both arms saw the same opening roster, the switch rolls no dice.
     if(on.timeline.length&&off.timeline.length&&on.timeline[0][1]!==off.timeline[0][1]) bad.push('control: the two arms opened with '+on.timeline[0][1]+' and '+off.timeline[0][1]+' pillagers, so the seeded stream moved');
     return bad.length?bad.join('; '):null; }},
  {v:'11.22',what:'no building on THE COLD MILE holds ANY pocket of floor nothing can reach, down to a 12 by 12 niche behind a table, on five seeds; the old furniture rules bring the niches back; and the repair pass demolishes nothing on seven seeds of both maps',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
