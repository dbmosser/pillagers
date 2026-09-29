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

# AFTER PLAYER 1 IS OUT, A RING PLAYER 2 CALLS GETS ITS SIEGE, AND HE CAN CALL IT AGAIN AFTER A MISSED SHIP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netSpecTick(dt){
'@ @'
// v17.33, co-op hunt 2026-09-28: THE RINGS OF THE KEPT RAID RUN ON THE HOST. tickExtractPoints runs only in a raid frame, so once the
// host was out nothing counted down a ring a teammate called: no siege machine came, the re-ping never pulled the ring, and the call
// stood for good, so his next call there after a missed ship was refused as called already without a sound. This is the part of
// tickExtractPoints the world needs, by the same rules and numbers: the clock and the boarding window, the siege arrivals kept 700
// clear of the party (netNearDist, never the spectating host), and the two second re-ping and pull. The words, the sounds and the
// HUD mirrors stay with the teammate window, which runs its own rings.
function netSpecRings(dt){
  var zi, z, GR, sv, iv, cap, ss, st, nm, pc, bi, be, jx, jy, first, n=0;
  if(!G||!G.zones||!(dt>0)) return 0;
  for(zi=0;zi<G.zones.length;zi++){
    z=G.zones[zi];
    if(z.beaconT===null||z.beaconT===undefined) continue;
    n++;
    z.beaconT-=dt;
    if(z.siegeGreed===undefined||z.siegeGreed===null) z.siegeGreed=greedOf();
    GR=z.siegeGreed; sv=(CFG.siegeVol===undefined?1:CFG.siegeVol);
    iv=(8-4.6*GR)/sv; cap=Math.round((6+8*GR)*sv);
    z.siegeSpawnT=(z.siegeSpawnT||0)+dt; z.siegeSpawned=z.siegeSpawned||0;
    if(z.siegeSpawnT>=iv&&z.siegeSpawned<cap){
      z.siegeSpawnT=0; ss=null; st=0;
      do{ ss=freeSpot(G.map,30); st++; }while(netNearDist(ss)<700&&st<40);
      if(netNearDist(ss)>=700){
        z.siegeSpawned++;
        nm=rr()<.5?mkSentry(ss.x,ss.y):mkCrawler(ss.x,ss.y);
        nm.siegeBorn=1; nm.alert=3; nm.state='investigate'; nm.tx=z.x+rnd(-60,60); nm.ty=z.y+rnd(-60,60);
        G.ents.push(nm);
        if(G.tel) G.tel.siegeArrivals=(G.tel.siegeArrivals||0)+1;
      }
    }
    z.siege=(z.siege||0)+dt;
    if(z.siege>=2){
      z.siege=0; first=!z.pinged; z.pinged=1;
      ping(z.x,z.y,1200*(1+0.7*GR)*(first?1:(CFG.siegeEcho===undefined?1:CFG.siegeEcho)),true,false,'env','fire');
      pc=Math.round((6+8*GR)*(CFG.siegePull===undefined?0.5:CFG.siegePull)); z.pullN=z.pullN||0;
      for(bi=0;bi<G.ents.length;bi++){
        be=G.ents[bi];
        if(dist(be,z)>1500||be.state==='chase') continue;
        jx=rnd(-50,50); jy=rnd(-50,50);
        if(be.pullZ!==z){ if(z.pullN>=pc) continue; be.pullZ=z; z.pullN++; }
        be.alert=Math.max(be.alert,2.4);
        if(be.state!=='extract'&&!onYourTail(be.state)){ be.state='investigate'; be.tx=z.x+jx; be.ty=z.y+jy; }
      }
    }
    if(z.beaconT>0) continue;
    if(z.hold===null||z.hold===undefined){ z.hold=raidClockOn()?Math.min(30,Math.max(3,G.timeLeft-1)):30; if(raidClockOn()&&z.hold>G.timeLeft) z.hold=Math.max(0.5,G.timeLeft); z.holdMax=z.hold; }
    z.hold-=dt;
    if(z.hold<=0){ z.beaconT=null; z.hold=null; z.pullT=null; if(z===G.active){ G.beaconT=null; G.shipHold=null; } }
  }
  return n;
}
function netSpecTick(dt){
'@

SubRx @'
    netSrchTick(wdt);
'@ @'
    netSrchTick(wdt);
    netSpecRings(wdt);   // v17.33, co-op hunt 2026-09-28: and the rings a teammate called, which only a raid frame counted down
'@

SubRx @'
var VER='17.32';
'@ @'
var VER='17.33';
'@

$pat = "(?m)^  now:'v17\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.33: Kept raid rings, co-op hunt 2026-09-28: tickExtractPoints runs only from tryExtractTick in a raid frame, which stops once G.over is set, and netSpecTick (the host running the raid for the party after his own run ended) stepped the bodies, rounds, throwables and searches but never the rings. netWorldSend sends no rings once the raid is over, so player 2 runs his own, and his own siege arrivals are removed by netEntsEase since a linked window spawns nobody. So a call from player 2 while the host spectated reached netBeaconTake, which set beaconT on the kept world, and nothing ever counted it down: no siege arrival came, the two second re-ping and its pull never fired, and a second call on that ring after a missed boarding window was refused as called already with no ping and no word back. A new netSpecRings, called from netSpecTick after netSrchTick with the same world step, runs the part of tickExtractPoints the world needs for every called ring, by the same numbers: the inbound clock and the boarding window (cleared when it runs out), the per call siege clock and cap from the siege greed with each arrival placed 700 clear of the party by netNearDist (never the spectating host body), and the two second re-ping with its capped pull. It says nothing, plays nothing and leaves the HUD mirrors alone, since those belong to the teammate window, which still runs its own rings. Solo play never reaches it. No number moved. Check 17.33 fails on v17.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
