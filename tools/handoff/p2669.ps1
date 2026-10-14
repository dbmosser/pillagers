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

# THE RAID DIRECTOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  WS.waveT=(+WS.waveT||0)+((dt>0)?dt:0);
  if(WS.waveT<iv) return 0;
'@ @'
  var D=flowDir(dt), amb=0;   // v26.xx (flow1): the Director reads the stress first; a breather stands the wave clock still, a quiet stretch speeds it
  WS.waveT=(+WS.waveT||0)+((dt>0)?dt:0)*D.pace;
  if(D.pace<=0){ WS.waveT=Math.min(WS.waveT,iv-0.5); return 0; }   // v26.xx (flow1): in a breather the next pack waits, however long the clock has been ready
  if(WS.waveT<iv) return 0;
'@

SubRx @'
  q=men[Math.floor(Math.random()*men.length)];
  c=arcadeWaveSpot(men,q);
'@ @'
  q=men[Math.floor(Math.random()*men.length)];
  amb=flowAmbushOk(D,q)?1:0; c=amb?flowAmbushSpot(men,q):null;   // v26.xx (flow1): a long quiet ends in a pack from behind him
  if(!c){ amb=0; c=arcadeWaveSpot(men,q); }
'@

SubRx @'
  n=Math.min(pack,cap-live);
'@ @'
  n=Math.min(amb?pack+2:pack,cap-live);   // v26.xx (flow1): an ambush brings two more
'@

SubRx @'
    e.arcWave=1; e.alert=3; e.state='investigate';
'@ @'
    e.arcWave=1; e.alert=3; e.state='investigate'; if(amb) e.dirAmb=1;
'@

SubRx @'
  if(made){ WS.waveN=(WS.waveN|0)+1; say('WAVE '+WS.waveN,'warn'); try{ annCue('WAVE'); }catch(_vc){} }   // v24.04 (his #45): WAVE INCOMING
'@ @'
  if(made){ WS.waveN=(WS.waveN|0)+1; say('WAVE '+WS.waveN,'warn',amb?{sub:'AMBUSH BEHIND YOU'}:undefined); try{ annCue('WAVE'); }catch(_vc){} try{ flowDirFired(D,amb,made); }catch(_fdf){} }   // v24.04 (his #45): WAVE INCOMING; v26.xx (flow1): and an ambush says where from
'@

SubRx @'
  if(!spotFree(G.map,x,y,22)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)) return false;
'@ @'
  if(!spotFree(G.map,x,y,22)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)) return false;
  if(flowZoneNear(x,y,DIR.ring)) return false;   // v26.xx (flow1): the Director never lands a pack on an extraction ring
'@

SubRx @'
// v23.53, HIS YES (2026-10-11) to the five recommendations, arcade29 (found by the 3-hour arcade soak of 2026-10-11): THE WORLD STAYS
'@ @'
// ======================================================================= THE RAID FLOW (v26.xx flow1 and on)
// v26.xx (flow1), HIS YES (2026-10-14) to suggestion 1 of the 100, THE RAID DIRECTOR: "pressure rises and falls". The wave tick above
// ran on a clock (every 10 to 22 s, whatever was happening), a ramp and not a rhythm. The Director reads how the raid is going and
// schedules the waves by it. STRESS (0 to 1.5) is the health he has just lost (a 40 point hit is 0.88), plus a little for every machine
// or pillager hunting him within 700, and it drains by 0.045 a second. ABOVE 0.75 the raid goes to a BREATHER: the wave clock stands
// still for 14 to 24 s and until the stress is under 0.45, so a man who is hurting gets room to heal. In the BUILD phase the clock
// runs faster the longer he has been quiet (up to 1.6 times at 30 quiet seconds), so a calm stretch swells. After 18 quiet seconds, two
// waves in and two minutes into the raid, with no ambush for 90 s, the next wave is an AMBUSH: two bodies more than a pack, landing
// 770 to 1,060 away on the side he is facing away from (just outside the camera), called WAVE n with AMBUSH BEHIND YOU. No ambush
// while he stands within 640 of an extraction ring, and no pack ever lands within 420 of one (the ring has its own siege, and the
// director already holds while a ring is called). DEMO and CAREER run the same tick; the director keeps its state on G.flow (new
// every raid) and draws nothing from the seeded stream.
var DIR={hi:0.75,lo:0.45,decay:0.045,quiet:18,gap:90,after:120,breather:14,ring:420,ringAmb:640};
function flowOn(){ return !!(G&&(G.arcade||G.career)&&!G.sim&&!G.over&&G.map&&G.player&&Array.isArray(G.ents)); }
function flowS(){ if(!G.flow) G.flow={}; return G.flow; }
function flowZoneNear(x,y,r){
  var i, z;
  for(i=0;G&&G.zones&&i<G.zones.length;i++){ z=G.zones[i]; if(z&&z.open!==false&&isFinite(z.x)&&Math.hypot(x-z.x,y-z.y)<r+(z.r||0)) return true; }
  return false;
}
function flowFoe(e){ return !!e&&e.hp>0&&!e.neutral&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.merc&&!e.friendlyPC&&!(e.kind==='raider'&&!e.hostile); }
function flowDir(dt){
  var S=flowS(), p=G.player, D=S.dir, i, e, fight=0, lost, hp=(+p.hp>0)?+p.hp:0;
  dt=(dt>0)?dt:0;
  if(!D) D=S.dir={st:0,hp:hp,quiet:0,ph:'build',phT:0,waves:0,amb:0,lastAmb:-999,pace:1};
  lost=Math.max(0,(+D.hp||0)-hp); D.hp=hp;
  D.st=(+D.st||0)+lost/Math.max(40,+p.maxhp||100)*2.2;
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i];
    if(!flowFoe(e)) continue;
    if((e.state==='chase'||e.state==='alarm'||e.state==='hunt')&&dist(e,p)<700) fight++;
  }
  if(fight) D.st+=Math.min(3,fight)*0.05*dt;
  D.st=Math.max(0,Math.min(1.5,D.st-DIR.decay*dt));
  if(fight||(G.t||0)-(+p.hurtAt||-999)<4) D.quiet=0; else D.quiet=(+D.quiet||0)+dt;
  if(D.ph!=='breather'){ if(D.st>=DIR.hi){ D.ph='breather'; D.phT=DIR.breather+10*Math.min(1,(D.st-DIR.hi)/0.75); } }
  else { D.phT=Math.max(0,(+D.phT||0)-dt); if(D.phT<=0&&D.st<DIR.lo) D.ph='build'; }
  D.pace=(D.ph==='breather')?0:1+0.6*Math.min(1,(+D.quiet||0)/30);
  return D;
}
function flowAmbushOk(D,q){
  var t=G.t||0;
  if(!D||!q||D.ph!=='build'||(+D.quiet||0)<DIR.quiet||(D.waves|0)<2||t<DIR.after||t-(+D.lastAmb||-999)<DIR.gap) return false;
  return !flowZoneNear(q.x,q.y,DIR.ringAmb);
}
function flowAmbushSpot(men,q){
  var k, a, r, x, y, f=(q===G.player)?(+G.player.face||0):(isFinite(q.f)?q.f:0);
  for(k=0;k<ARCADE_WAVE.tries;k++){
    a=f+Math.PI+(Math.random()-0.5)*1.1; r=ARCADE_WAVE.minR+Math.random()*(ARCADE_WAVE.maxR-ARCADE_WAVE.minR);
    x=q.x+Math.cos(a)*r; y=q.y+Math.sin(a)*r;
    if(arcadeWaveOk(men,q,x,y,ARCADE_WAVE.minR-1,ARCADE_WAVE.maxR+1)) return {x:x,y:y};
  }
  return null;
}
function flowDirFired(D,amb,made){
  if(!D||!(made>0)) return;
  D.waves=(D.waves|0)+1; D.quiet=0;
  if(amb){ D.amb=(D.amb|0)+1; D.lastAmb=G.t||0; }
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
// v23.53, HIS YES (2026-10-11) to the five recommendations, arcade29 (found by the 3-hour arcade soak of 2026-10-11): THE WORLD STAYS
'@

SubRx @'
var VER='26.68';
'@ @'
var VER='26.69';
'@

$pat = "(?m)^  now:'v26\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.69: The waves now rise and fall with how the raid is going: a breather after a hard hit, an ambush from behind after a long quiet. Check 26.69 fails on v26.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
