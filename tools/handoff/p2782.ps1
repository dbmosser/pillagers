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

# THE EVENTS, GATE AND BARRELS HAVE SOUNDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  return ev;
}
function evTick(dt){
'@ @'
  // v27.82 (snd2), HIS ORDER (2026-10-15, "add the sounds"): THE FIVE RAID EVENTS HAVE SOUNDS. say() plays nothing, so an event was announced on the
  // screen and in silence. Each of the five now plays its own sting with the callout (ORBITAL DEBRIS a long falling roar over a low drone, MACHINE CONVOY
  // a metal clank and a rising engine, BOUNTY PILLAGER low drums, COOLANT RUPTURE a hiss and a cold fifth, OVERSEER RAMPAGE a stomp and a low horn),
  // centred on the sting bus so it reaches you wherever the ring is. No words, no voices. Cosmetic only: no seeded draw, no game state.
  try{ if(SPK_EVWARN[id]) blip(SPK_EVWARN[id]); }catch(_ew){}
  return ev;
}
function evTick(dt){
'@

SubRx @'
      if(ph==='warn'){ try{ say(def.name,'warn',{sub:def.sub?(def.sub+'  '+Math.round(+r[9])+'S'):(Math.round(+r[9])+'S')}); }catch(_en){} }
'@ @'
      if(ph==='warn'){ try{ say(def.name,'warn',{sub:def.sub?(def.sub+'  '+Math.round(+r[9])+'S'):(Math.round(+r[9])+'S')}); }catch(_en){} try{ if(SPK_EVWARN[id]) blip(SPK_EVWARN[id]); }catch(_ew2){} }   // v27.82 (snd2): and its sting
'@

SubRx @'
    for(i=0;i<pts.length;i++) if(!pts[i].done&&ev.lt>=pts[i].at){ pts[i].done=1; debrisImpact(ev,pts[i]); }
'@ @'
    for(i=0;i<pts.length;i++){
      if(!pts[i].fell&&!pts[i].done&&ev.lt>=pts[i].at-2.2){ pts[i].fell=1; try{ sfx('debrisFall',pts[i].x,pts[i].y); }catch(_df){} }   // v27.82 (snd2): the roar of it coming down, once per piece
      if(!pts[i].done&&ev.lt>=pts[i].at){ pts[i].done=1; debrisImpact(ev,pts[i]); }
    }
'@

SubRx @'
function debrisImpact(ev,pt){
  var p=G.player, R=72, j, e, de, d;
  sfx('boom',pt.x,pt.y);
'@ @'
function debrisImpact(ev,pt){
  var p=G.player, R=72, j, e, de, d;
  sfx('debrisLand',pt.x,pt.y);   // v27.82 (snd2): the debris blast has its own sound (recorded crunch, sub drop, metal crash), the same ring and range as boom
'@

SubRx @'
function debrisImpactPeer(pt){
  var p=G.player, R=72, d;
  sfx('boom',pt.x,pt.y);
'@ @'
function debrisImpactPeer(pt){
  var p=G.player, R=72, d;
  sfx('debrisLand',pt.x,pt.y);   // v27.82 (snd2): and in the linked window
'@

SubRx @'
    try{ say('CONVOY MOVING','warn',{sub:'KILL THE CARRIER'}); }catch(_cs){}
'@ @'
    try{ say('CONVOY MOVING','warn',{sub:'KILL THE CARRIER'}); }catch(_cs){}
    try{ sfx('convoyRoll',ev.x,ev.y); }catch(_cr){}   // v27.82 (snd2): the train forms and sets off, tread clanks over a low engine
'@

SubRx @'
    try{ say('COOLANT RUPTURE','crit',{sub:'RICHER CRATES  '+n}); }catch(_cs){}
'@ @'
    try{ say('COOLANT RUPTURE','crit',{sub:'RICHER CRATES  '+n}); }catch(_cs){}
    try{ sfx('coolantBurst',ev.x,ev.y); }catch(_cb){}   // v27.82 (snd2): the pipe bursts, a metal crack and a long cold hiss
'@

SubRx @'
    try{ say('OVERSEER RAMPAGE','crit',{sub:'IT HAS LEFT THE LAIR'}); }catch(_rs){}
'@ @'
    try{ say('OVERSEER RAMPAGE','crit',{sub:'IT HAS LEFT THE LAIR'}); }catch(_rs){}
    try{ sfx('rampageRoar',b.x,b.y); }catch(_rrs){}   // v27.82 (snd2): it leaves the lair, a roar over heavy stomps, from where it stands
'@

SubRx @'
flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; }
'@ @'
flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER'); ev.d.won=1; try{ blip('bountyPaid'); }catch(_bp){} }
'@

SubRx @'
function shBreachFx(s){
  var gp=shGatePt(s), p=G.player;
  try{ sfx('boom',gp.x,gp.y); }catch(_a){}
'@ @'
function shBreachFx(s){
  var gp=shGatePt(s), p=G.player;
  try{ sfx('gateBreach',gp.x,gp.y); }catch(_a){}   // v27.82 (snd2): the gate blown in: a slowed low blast, a giant metal crash, the gate groaning, debris raining (same ring and range as boom)
'@

SubRx @'
    if(d<R) brlLight(B,by,0.12+0.22*d/R);
'@ @'
    if(d<R&&brlLight(B,by,0.12+0.22*d/R)) B.chain=1;   // v27.82 (snd2): lit by another barrel blast, so its own blast sounds as part of a chain
'@

SubRx @'
  sfx('boom',x,y);
  if(!G.sim){
    spark(x,y,'#ff8a3a',40,380);
'@ @'
  sfx(B.chain?'barrelChain':'barrelBlast',x,y);   // v27.82 (snd2): a barrel has its own blast (a drum crack and a low thump), a barrel in a chain a shorter harder one
  if(!G.sim){
    spark(x,y,'#ff8a3a',40,380);
'@

SubRx @'
var VER='27.81';
'@ @'
var VER='27.82';
'@

$pat = "(?m)^  now:'v27\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.82: The raid events, the gate breach and the explosive barrels have their own dark sounds, and a barrel chain sounds like a chain. Check 27.82 fails on v27.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
