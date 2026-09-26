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

# THE HOST OWNS THE RAID CLOCK, THE WEATHER, THE LIGHTNING AND THE EXTRACTION RINGS. Multiplayer, plan phase 2 and 3 (world snapshots; the beacon is shared by the party).

SubRx @'
      wxTick(dt); strikeTick(dt);
'@ @'
      if(!netEntsPeer()) wxTick(dt); strikeTick(dt);   // v16.06: on a linked window the weather comes from the host (netWorldTake)
'@

SubRx @'
  if(G.strikeAt<=0){
'@ @'
  if(G.strikeAt<=0&&!netEntsPeer()){   // v16.06: a linked window makes no bolts of its own; the host bolts come in its world word
'@

SubRx @'
    var sx=clamp(p.x+Math.cos(ang)*rad,80,WORLD_W-80);
    var sy=clamp(p.y+Math.sin(ang)*rad,80,WORLD_H-80);
'@ @'
    var _sc=netStrikeAt(p);   // v16.06: the host takes each party member up top in turn as the centre; alone it is always him (no draw)
    var sx=clamp(_sc.x+Math.cos(ang)*rad,80,WORLD_W-80);
    var sy=clamp(_sc.y+Math.sin(ang)*rad,80,WORLD_H-80);
'@

SubRx @'
    G.strikes.push({x:sx,y:sy,t:STRIKE_WARN,hit:0});
'@ @'
    G.strikes.push({x:sx,y:sy,t:STRIKE_WARN,hit:0,id:(G.strikeN=(G.strikeN||0)+1)});   // v16.06: numbered, so the party draws the same bolt once
'@

SubRx @'
    G.strikes.splice(i,1);
'@ @'
    G.strikes.splice(i,1);
    if(S.rm){ G.lightning=0.34; if(!G.sim) sfx('alarm',S.x,S.y); continue; }   // v16.06: a host bolt on a linked window: the flash and the crack only; the host lands the hit (netAreaHitPeers)
'@

SubRx @'
      G.beaconT=z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
'@ @'
      G.beaconT=z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
      netBeaconCalled(z);   // v16.06: a linked window asks the host, which owns the rings, to call it for the party
'@

SubRx @'
  if(NET.role==='host') netContTick();   // v15.91: on the same clock, every container that arrived, opened or shut since the last tick
'@ @'
  if(NET.role==='host') netContTick();   // v15.91: on the same clock, every container that arrived, opened or shut since the last tick
  if(NET.role==='host'&&NET.upN%5===0) netWorldSend();   // v16.06: twice a second, the raid clock, the weather, the bolts and the rings
'@

SubRx @'
function netEntsHost(){
'@ @'
// v16.06, MULTIPLAYER: THE HOST OWNS THE RAID CLOCK, THE WEATHER, THE LIGHTNING AND THE EXTRACTION RINGS. Before this each window
// ran its own: the weather turned on its own seeded stream, so two players could stand in rain and in fog; the clocks drifted;
// a bolt the host made could land on a teammate who never saw its warning ring; and a beacon one player called existed on his
// window alone. Twice a second the host sends {t:'wd'}: the seed, time left, the sky, the sky it is turning to and how far, the
// live bolts by number, the active ring, and for every ring whether it is open, the beacon countdown, the hold and when it
// closes. A linked window on that seed takes the clock when it is more than 0.3 s off, the sky outright (it runs no wxTick of its
// own), the rings, and each new bolt as a warning ring that flashes and cracks but never hits: the host lands the hit through
// netAreaHitPeers by the roof and wall rules. A linked window makes no bolts of its own; the host centres each bolt on the next
// member of the party up top in turn, so the storm reaches everyone, with the same two draws. A beacon called on a linked window
// goes to the host ({t:'bcn'}) and is called there for the party; the linked window keeps its own call for 1.5 s so the next
// word cannot cancel it on the way. Each player still boards, extracts, dies or abandons alone. Solo play is untouched.
function netWxOf(id){ var i; if(typeof WEATHER==='undefined') return null; for(i=0;i<WEATHER.length;i++) if(WEATHER[i].id===id) return WEATHER[i]; return null; }
function netNum(v){ return (typeof v==='number'&&isFinite(v))?+v.toFixed(2):null; }
function netStrikeAt(p){
  var L=[p], i, g;
  if(!netEntsHost()||!netInCount()) return p;
  for(i=0;i<NET.up.length;i++){ g=NET.up[i]; if(g&&g.seat!==NET.seat&&!g.dn&&g.sd===(NET.upSeed>>>0)&&netSeatName(g.seat)!==null) L.push(g); }
  G.strikeWho=((G.strikeWho|0)+1)%L.length;
  return L[G.strikeWho]||p;
}
function netWorldSend(){
  var z=[], s=[], i, Z, S, m, n=0;
  if(!netEntsHost()) return 0;
  for(i=0;i<(G.zones||[]).length;i++){ Z=G.zones[i]; z.push([(Z.open===undefined)?null:Z.open,netNum(Z.beaconT),netNum(Z.hold),netNum(Z.holdMax),netNum(Z.closeAt)]); }
  for(i=0;i<(G.strikes||[]).length;i++){ S=G.strikes[i]; if(S.id&&!S.rm&&S.t>0) s.push([S.id,Math.round(S.x),Math.round(S.y),netNum(S.t)]); }
  m={t:'wd',sd:G.seed>>>0,tl:netNum(G.timeLeft),wx:(G.wx&&G.wx.id)||'',wn:(G.wxNext&&G.wxNext.id)||'',wt:netNum(G.wxT)||0,ai:(G.zones||[]).indexOf(G.active),z:z,s:s};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&netSendFast(NET.peers[i],m)) n++;
  return n;
}
function netWorldTake(peer,m){
  var i, a, Z, w, k, S, have;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netEntsPeer()||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
  if(typeof m.tl==='number'&&isFinite(m.tl)&&Math.abs((G.timeLeft||0)-m.tl)>0.3) G.timeLeft=m.tl;
  w=netWxOf(m.wx); if(w) G.wx=w;
  G.wxNext=netWxOf(m.wn); G.wxT=(typeof m.wt==='number'&&isFinite(m.wt))?clamp(m.wt,0,1):0;
  if(m.z&&typeof m.z.length==='number') for(i=0;i<m.z.length&&i<(G.zones||[]).length;i++){
    a=m.z[i]; Z=G.zones[i]; if(!a||!Z) continue;
    if(typeof Z.netCallAt==='number'&&G.t-Z.netCallAt<1.5&&a[1]===null) continue;
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=a[4];
  }
  if(typeof m.ai==='number'&&m.ai>=0&&G.zones&&G.zones[m.ai]){ G.active=G.zones[m.ai]; G.beaconT=G.active.beaconT; }
  if(m.s&&typeof m.s.length==='number') for(i=0;i<m.s.length&&i<12;i++){
    a=m.s[i]; if(!a||typeof a[0]!=='number') continue;
    have=false; for(k=0;k<G.strikes.length;k++) if(G.strikes[k].rid===a[0]) have=true;
    if(have||(G.netBolts&&G.netBolts[a[0]])) continue;
    (G.netBolts=G.netBolts||{})[a[0]]=1;
    S={x:+a[1]||0,y:+a[2]||0,t:Math.max(0.05,+a[3]||0.05),hit:0,rm:1,rid:a[0]}; G.strikes.push(S);
    if(!G.sim) sfx('charge',S.x,S.y);
  }
  return 'wd';
}
// A beacon called on this window: a linked window asks the host for the party. Returns whether it asked.
function netBeaconCalled(z){
  var i, ix;
  if(!netEntsPeer()) return false;
  ix=G.zones.indexOf(z); if(ix<0) return false;
  z.netCallAt=G.t;
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'bcn',i:ix});
  return true;
}
// On the host: a teammate called the beacon at ring i; it is called here, where the rings live, as his own call makes it.
function netBeaconTake(peer,m){
  var Z;
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(!netEntsHost()||typeof m.i!=='number') return 'off';
  Z=G.zones[m.i|0]; if(!Z) return 'bad';
  if(Z.beaconT!==null&&Z.beaconT!==undefined) return 'called already';
  if(Z.open===false) return 'closed';
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=null; Z.pullN=0; Z.pinged=0;
  G.active=Z; G.beaconT=Z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
  if(G.tel) G.tel.beaconCalls=(G.tel.beaconCalls||0)+1;
  blip('beacon'); say((netSeatName(peer.seat)||'Your teammate')+' called the extraction. Inbound '+Math.ceil(Z.beaconT)+'s.');
  return 'called';
}
function netEntsHost(){
'@

SubRx @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@ @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='wd') return netWorldTake(peer,m);   // v16.06: the raid clock, the weather, the bolts and the rings, from the host
  if(m.t==='bcn') return netBeaconTake(peer,m);   // v16.06: a teammate called the beacon; the host calls it for the party
'@

SubRx @'
var VER='16.05';
'@ @'
var VER='16.06';
'@

$pat = "(?m)^  now:'v16\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.06: THE HOST OWNS THE RAID CLOCK, THE WEATHER, THE LIGHTNING AND THE EXTRACTION RINGS. Multiplayer. Each window ran its own, so two players could stand in different weather, their clocks drifted, a host bolt could hit a teammate who never saw its warning, and a beacon one player called existed for him alone. Twice a second the host now tells the party the clock, the sky, the live bolts and every ring; a linked window follows it, draws the host bolts, and asks the host to call a beacon for the party. The storm now centres on each of the party in turn. Each player still extracts alone. Solo untouched. No number moved. Check 16.06 fails on v16.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
