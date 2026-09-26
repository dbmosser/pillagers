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

# THREE BACKCHECK FIXES (findings on v15.88, v15.80 and v16.06).

SubRx @'
  P.mapRunN=(o.mr&&typeof o.mr==='object'&&!Array.isArray(o.mr))?o.mr:null;
'@ @'
  P.mapRunN=(o.mr&&typeof o.mr==='object'&&!Array.isArray(o.mr))?o.mr:{};   // v16.13, backcheck: a code with no tally starts a clean one ({}), so the next commit never seeds it from the replaced character's log
'@

SubRx @'
    if(P.mapRunN&&(P.mapRunN[M.name]|0)>_myR) _myR=P.mapRunN[M.name]|0;
'@ @'
    if(P.mapRunN) _myR=P.mapRunN[M.name]|0;   // v16.13, backcheck: once there is a tally it is the count (seeded from the log, never below it); the log is read only before one exists, so a restored character does not show the replaced character's runs
'@

SubRx @'
    e=NET.entMap[id]; if(!e) return 'ent:unknown';
    delete NET.entMap[id];
'@ @'
    e=NET.entMap[id]; if(!e) return 'ent:unknown';
    delete NET.entMap[id];
    // v16.13, backcheck: the host sends the gone word before the kill word on the same ordered channel, so the kill word found no
    // body and a pillager a friend killed was never remembered (grudge, standing, met). The last bodies gone are kept for it.
    if(!NET.entDead||Object.keys(NET.entDead).length>40) NET.entDead={};
    NET.entDead[id]=e;
'@

SubRx @'
  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||null;
'@ @'
  k=netClean(m.k,12); T=G.tel; e=(NET.entMap&&NET.entMap[m.id|0])||(NET.entDead&&NET.entDead[m.id|0])||null;   // v16.13: or the body the gone word just took off
'@

SubRx @'
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'bcn',i:ix});
'@ @'
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'bcn',i:ix,g:+greedOf().toFixed(3)});   // v16.13: with the caller's greed, which sizes the siege
'@

SubRx @'
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=null; Z.pullN=0; Z.pinged=0;
'@ @'
  var _cg=(typeof m.g==='number'&&isFinite(m.g))?clamp(m.g,0,1):null;   // v16.13, backcheck: the siege is sized by the caller's backpack, as his own window promised
  Z.beaconT=CFG.extractWait; Z.hold=null; Z.siegeSpawned=0; Z.siegeSpawnT=0; Z.siegeGreed=_cg; Z.pullN=0; Z.pinged=0;
  // and the call is as loud on the host as the host's own: the ping by the caller's greed, and everything within 2200 alerted and
  // sent to the ring, never overwriting a hunt (the rule of the local call). No jitter is drawn: the net code draws nothing seeded.
  try{
    ping(Z.x,Z.y,700*(1+0.8*(_cg===null?0:_cg)),true,false,'env','fire');
    for(var _wi=0;_wi<G.ents.length;_wi++){ var _we=G.ents[_wi]; if(dist(_we,Z)>2200) continue; _we.alert=Math.max(_we.alert,3); if(_we.kind==='raider'&&_we.bag&&_we.bag.length>=5) continue; if(!onYourTail(_we.state)){ _we.state='investigate'; _we.tx=Z.x; _we.ty=Z.y; } }
  }catch(_wk){}
'@

SubRx @'
var VER='16.12';
'@ @'
var VER='16.13';
'@

$pat = "(?m)^  now:'v16\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.13: THREE BACKCHECK FIXES. A restore code with no tally starts a clean one, and the sector card reads the tally once there is one, so a restored character no longer shows the runs of the replaced character. A pillager a friend kills is remembered again (the kill word came after the gone word had taken the body off). A beacon a friend calls is sized by the backpack of that friend and wakes the map as loudly as a call the host makes. No number moved. Check 16.13 fails on v16.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
