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

# ARCADE: DEATH RESPAWNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function endRaid(how){
  if(G.over) return;
'@ @'
function endRaid(how){
  if(G.over) return;
  // v23.22, HIS ORDER (2026-10-11), arcade3: an arcade raid is never settled here. A death drops him back in (arcadeRespawn) and an
  // abandon stops the arcade raid (arcadeRaidStop): no run counted, no card, no score word, no out word, nothing banked.
  if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead'); if(how==='abandon') return arcadeRaidStop('quit'); }
'@

SubRx @'
      if(G.paused&&netPauseLive()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on
'@ @'
      if(G.arcade&&ARCADE.holdT>0){ ARCADE.holdT=Math.max(0,ARCADE.holdT-dt); netPausedStep(dt); }   // v23.22 (arcade3): the drop-in hold after an arcade respawn, he stands still while the world runs on
      else if(G.paused&&netPauseLive()) netPausedStep(dt);   // v16.04: paused in a shared co-op raid, he stands still while the world runs on
'@

SubRx @'
  if(G&&!G.over&&runElapsed()>60){   // v22.02 (K12): his own time, as the button label says (free this early)
'@ @'
  if(G&&!G.over&&!G.arcade&&runElapsed()>60){   // v22.02 (K12): his own time, as the button label says (free this early)   // v23.22 (arcade3): no fee in an arcade raid
'@

SubRx @'
    cb.textContent=(_el>60)?
'@ @'
    // v23.22 (arcade3): an arcade raid costs no XP, so its confirm quotes none
    cb.textContent=(G&&G.arcade)?'YES, ABANDON THIS RUN':(_el>60)?
'@

SubRx @'
  if(o.seed!==undefined) pendSeed=(o.seed>>>0);
  startRaid();
  return !!(G&&G.arcade);
'@ @'
  if(o.seed!==undefined) pendSeed=(o.seed>>>0);
  ARCADE.deaths=0; ARCADE.holdT=0;   // v23.22 (arcade3)
  startRaid();
  return !!(G&&G.arcade);
'@

SubRx @'
function arcadeRaidStop(why){
  if(!G||!G.arcade) return false;
  G.drag=null;
'@ @'
function arcadeRaidStop(why){
  if(!G||!G.arcade) return false;
  G.drag=null;
  ARCADE.holdT=0;   // v23.22 (arcade3)
'@

SubRx @'
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back.
'@ @'
// v23.22, HIS ORDER (2026-10-11), build 3 of 20 (arcade3): DEATH RESPAWNS. In an arcade raid going down, bleeding out, give-up and the
// 1.5 second death beat are unchanged, but the beat ends here instead of in the settling half of endRaid: the same raid goes on, a
// fresh random kit (arcadeKitApply), full health, and he is put down within 60 to 140 of a teammate who is up, or else on the map
// spawn farthest from every live hostile (Math.random for the tie-break and the offsets, never the seeded stream). Then a 3 second
// drop-in hold (ARCADE.holdT): the loop steps him through netPausedStep, so he stands still while the world runs on.
function arcadeRespawn(why){
  if(!G||!G.arcade||!G.player) return false;
  var p=G.player, m=G.map, i, j, s, e, d, best=null, bs=-1, sc, a, r, x, y, ok=false, mates=[], u;
  G.deathBeat=null; p.dying=false; p.downed=false; p.downT=0; p.pendKiller=null; p.prep=null; p.prepA=null;
  p.cooking=0; p.cookT=0; p.cookKind=null;
  if(typeof NET==='object'&&NET&&NET.on&&Array.isArray(NET.up)){
    for(i=0;i<NET.up.length;i++){ u=NET.up[i]; if(u&&u.seat!==NET.seat&&!u.dn&&isFinite(u.x)&&isFinite(u.y)) mates.push(u); }
  }
  if(mates.length){
    u=mates[Math.floor(Math.random()*mates.length)];
    for(j=0;j<24&&!ok;j++){
      a=Math.random()*Math.PI*2; r=60+Math.random()*80; x=u.x+Math.cos(a)*r; y=u.y+Math.sin(a)*r;
      if(x>30&&y>30&&x<WORLD_W-30&&y<WORLD_H-30&&spotFree(m,x,y,22)){ p.x=x; p.y=y; ok=true; }
    }
  }
  if(!ok&&m&&Array.isArray(m.spawns)){
    for(i=0;i<m.spawns.length;i++){
      s=m.spawns[i]; if(!s||!spotFree(m,s.x,s.y,22)) continue;
      sc=1e9;
      for(j=0;j<G.ents.length;j++){ e=G.ents[j]; if(!e||!(e.hp>0)||e.merc||e.kind==='peddler'||e.kind==='stray') continue; d=dist(s,e); if(d<sc) sc=d; }
      sc+=Math.random();
      if(sc>bs){ bs=sc; best=s; }
    }
    if(best){ p.x=best.x; p.y=best.y; ok=true; }
  }
  arcadeKitApply(p,G,why||'dead');
  p.vx=0; p.vy=0; G.anchX=undefined; G.shake=0;
  ARCADE.deaths=(ARCADE.deaths|0)+1;
  ARCADE.holdT=3;
  return true;
}
// Leaving the arcade: the arcade raid stops, then the sandbox out puts his profile and his dials back.
'@

SubRx @'
var VER='23.21';
'@ @'
var VER='23.22';
'@

$pat = "(?m)^  now:'v23\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.22: In the arcade demo a death drops you back into the same raid with a fresh loadout after a 3 second hold. Check 23.22 fails on v23.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
