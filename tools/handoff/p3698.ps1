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

# THE SEAL OPENS IN TWO THIRDS OF THE TIME AND CALLS A WAVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sealNeed(tier){ return 34+tier*21; }   // v17.97: his note of 2026-10-03, marginally quicker (was 40+tier*25)

'@ @'
// v28.xx (cw-sealwave), HIS ORDER (2026-10-31): "make the seal 50% faster to open and make it so enemies spawn and attack when you start opening the seal".
// FASTER: opening at one and a half times the speed is two thirds of the time at every stage (34 + 21 per stage became 23, 37, 51 and so on).
// The need is the one number every reader asks (the cut, the bar, the map ring, the end card words), so they all follow. A cut banked under the
// old need that now sits past it still opens on one frame of E (v18.50).
// DEFENDED: the first frame of progress on a seal calls one wave on the opener, once per seal per raid (stopping and starting again calls no second).
// The first batch comes at once, a few more one by one while the cut runs, all of them machines in from 700 to 1000 away from the seal and 700 or
// more from every player, out of the seal's line of sight where the map allows, heading for it. The size follows the stage and the siege dial. The
// host runs it: a linked window sends swv and the host calls it for the party. Every draw is on the effects side stream (fxBorrow), never the main one.
function sealNeed(tier){ return Math.round((34+tier*21)*2/3); }
var SEAL_WAVE_IV=7;
function sealWaveVol(){ return (CFG.siegeVol===undefined?1:CFG.siegeVol); }
function sealWaveSize(tier){ return Math.round((3+Math.min(tier|0,3))*sealWaveVol()); }
function sealWaveMore(tier){ return Math.round((2+Math.min(tier|0,2))*sealWaveVol()); }
function sealWaveSpawn(n){
  var S=G&&G.seal, made=0;
  if(!S||G.sim) return 0;
  fxBorrow(function(){
    var i, ss, st, d, nm;
    for(i=0;i<n;i++){
      ss=null; st=0;
      do{
        ss=freeSpot(G.map,30); st++; d=dist(ss,S);
      }while(!(netNearDist(ss)>=700&&d>=700&&d<=1000&&(st>40||!G.vseg||!losClear(ss.x,ss.y,S.x,S.y,G.vseg)))&&st<80);
      if(!(netNearDist(ss)>=700)) continue;
      nm=rr()<.3?mkSentry(ss.x,ss.y):mkCrawler(ss.x,ss.y);
      nm.sealBorn=1; nm.alert=3; nm.state='investigate'; nm.tx=S.x+rnd(-60,60); nm.ty=S.y+rnd(-60,60);
      G.ents.push(nm); made++;
    }
  });
  if(G.tel) G.tel.sealArrivals=(G.tel.sealArrivals||0)+made;
  return made;
}
function sealWaveCall(){
  var S=G&&G.seal, R, i, n=0;
  if(!S||S.done||S.waved||G.sim) return 0;
  S.waved=1;
  R=sealHere(); S.waveMore=sealWaveMore(R.tier); S.waveT=0;
  if(netEntsPeer()){
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'swv'});
  } else n=sealWaveSpawn(sealWaveSize(R.tier));
  say('SEAL BREACH: INCOMING','warn',{key:'sealwave'});
  if(CFG.xAlarm!==0) blip('alarm');
  return n;
}
function sealWaveTick(dt){
  var S=G&&G.seal;
  if(!S||!S.waved||S.done||G.sim||netEntsPeer()||!((S.waveMore|0)>0)) return;
  S.waveT=(S.waveT||0)+dt;
  if(S.waveT<SEAL_WAVE_IV) return;
  S.waveT=0; S.waveMore--;
  sealWaveSpawn(1);
}
function netSealWaveTake(peer,m){
  if(!peer||peer.state!=='in'||NET.role!=='host') return 'ignored';
  if(!netEntsHost()||!G.seal) return 'off';
  if(G.seal.waved||G.seal.done) return 'called already';
  sealWaveCall();
  return 'called';
}

'@

SubRx @'
        if(SR.cut+G.seal.gained>=need){

'@ @'
        if(!G.seal.waved&&SR.cut+G.seal.gained<need) sealWaveCall();   // v28.xx (cw-sealwave): the first frame of progress calls the wave, once
        if(SR.cut+G.seal.gained>=need){

'@

SubRx @'
  tickExtractPoints(dt);
  tickRaiderWaves(dt);

'@ @'
  tickExtractPoints(dt);
  tickRaiderWaves(dt);
  sealWaveTick(dt);   // v28.xx (cw-sealwave): the few more machines that come while a seal is being cut

'@

SubRx @'
  if(m.t==='bcn') return netBeaconTake(peer,m);   // v16.06: a teammate called the beacon; the host calls it for the party

'@ @'
  if(m.t==='bcn') return netBeaconTake(peer,m);   // v16.06: a teammate called the beacon; the host calls it for the party
  if(m.t==='swv') return netSealWaveTake(peer,m);   // v28.xx (cw-sealwave): a teammate began cutting the seal; the host calls its wave once for the party

'@

SubRx @'
var VER='36.97';
'@ @'
var VER='36.98';
'@

$pat = "(?m)^  now:'v36\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.98: The seal opens in two thirds of the time but calls a wave of machines on you the moment you start cutting it. Check 36.98 fails on v36.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
