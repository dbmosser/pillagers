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

# CO-OP FIXES FROM THE BACKCHECK of 2026-09-26 (findings on v16.04, v16.05, v16.06 and v16.09).

SubRx @'
function strikeTick(dt){
  if(!G||G.over||G.paused) return;
'@ @'
function strikeTick(dt){
  if(!G||G.over||(G.paused&&!netUpShared())) return;   // v16.11, backcheck: a pause in a shared raid is an overlay (v16.04), so the storm runs on
'@

SubRx @'
document.getElementById('confirmabandon').onclick=function(){
'@ @'
document.getElementById('confirmabandon').onclick=function(){
  // v16.11, backcheck: THE CONFIRM REFUSES A DOWNED OR DYING PLAYER TOO. In solo the world stands still while the pause box is
  // open, so nothing can put him down between ABANDON and YES; in a shared co-op raid the world runs on under the box (v16.04),
  // so ABANDON armed on his feet and YES pressed after he went down turned the death into an abandon, the swap v9.37 closed.
  if(G&&!G.over&&(G.nuking||(G.player&&(G.player.downed||G.player.hp<=0||(G.deathBeat||0)>0)))){ this.style.display='none'; var _blq2=document.getElementById('pausebleed'); if(_blq2&&!G.nuking&&G.player&&G.player.downed) _blq2.style.display=''; return; }
'@

SubRx @'
function netRevHold(p,dt){
  var s=-1, nm;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  if(s<0||!keys['KeyE']||p.roll>0){ if(G.netRevT){ G.netRevT=0; G.netRevS=-1; } return false; }
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; }
  nm=netSeatName(s)||'PILLAGER';
  if(!G.netRevT) say('Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.');
  G.netRevT=(G.netRevT||0)+dt;
  if(G.netRevT<NET_REV_T) return false;
  G.netRevT=0; G.netRevS=-1;
'@ @'
// v16.11, backcheck: THE PICK-UP TAKES E. It returns true while E is working a pick-up, and the caller takes E off the other
// E acts for that step (the loop gives it back after), so holding E over a teammate beside an open ring no longer calls the
// extraction or searches a box as well. After a pick-up is sent, E held on stays on that teammate (G.netRevDone) until it is
// let go, so the line is not written over by a fresh Picking up and a second pick-up is never sent.
function netRevHold(p,dt){
  var s=-1, nm;
  try{ s=netMateDown(p); }catch(e){ s=-1; }
  if(!keys['KeyE']) G.netRevDone=-1;
  if(typeof G.netRevDone==='number'&&G.netRevDone>=0&&keys['KeyE']&&s===G.netRevDone) return true;
  if(s<0||!keys['KeyE']||p.roll>0){ if(G.netRevT){ G.netRevT=0; G.netRevS=-1; } return false; }
  if(G.netRevS!==s){ G.netRevS=s; G.netRevT=0; }
  nm=netSeatName(s)||'PILLAGER';
  if(!G.netRevT) say('Picking up '+nm+'. Keep holding '+keyLabel('KeyE','E')+'.');
  G.netRevT=(G.netRevT||0)+dt;
  if(G.netRevT<NET_REV_T) return true;
  G.netRevT=0; G.netRevS=-1; G.netRevDone=s;
'@

SubRx @'
  netRevHold(p,dt);   // v16.05: holding E beside a downed teammate picks him up (the net section)
'@ @'
  if(netRevHold(p,dt)&&keys['KeyE']){ keys['KeyE']=false; G.netRevEat=1; }   // v16.05: holding E beside a downed teammate picks him up; v16.11: and takes E for this step
'@

SubRx @'
      else updatePlayer(dt);
'@ @'
      else updatePlayer(dt);
      if(G&&G.netRevEat){ G.netRevEat=0; keys['KeyE']=true; }   // v16.11: E given back after the step a pick-up took it (netRevHold)
'@

SubRx @'
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=a[4];
  }
  if(typeof m.ai==='number'&&m.ai>=0&&G.zones&&G.zones[m.ai]){ G.active=G.zones[m.ai]; G.beaconT=G.active.beaconT; }
'@ @'
    // v16.11, backcheck: a pull this player began is left to finish as the v11.98 order says, not cut by the host word; and a
    // ring that never closes keeps closeAt undefined (null read as a closing time of 0 warned and showed a countdown).
    if(Z.pullT!==null&&Z.pullT!==undefined&&G.player&&dist(G.player,Z)<Z.r) continue;
    Z.open=(a[0]===null)?undefined:a[0]; Z.beaconT=a[1]; Z.hold=a[2]; if(a[3]!==null) Z.holdMax=a[3]; Z.closeAt=(a[4]===null)?undefined:a[4];
  }
  // v16.11, backcheck: the pointer to the ring this window called moves only when it has no call of its own running (v12.57).
  if(typeof m.ai==='number'&&m.ai>=0&&G.zones&&G.zones[m.ai]&&!(G.active&&G.active.beaconT!==null&&G.active.beaconT!==undefined)){ G.active=G.zones[m.ai]; G.beaconT=G.active.beaconT; }
'@

SubRx @'
  G.active=Z; G.beaconT=Z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0;
  if(G.tel) G.tel.beaconCalls=(G.tel.beaconCalls||0)+1;
'@ @'
  if(!(G.active&&G.active!==Z&&G.active.beaconT!==null&&G.active.beaconT!==undefined)){ G.active=Z; G.beaconT=Z.beaconT; G.shipHold=null; G.siegeSpawned=0; G.siegeSpawnT=0; }   // v16.11: never taken off a call of the host's own (v12.57)
  if(G.tel) G.tel.beaconCalls=(G.tel.beaconCalls||0)+1;
'@

SubRx @'
      NET.roster=netRosterClean(m.roster);
      hn='';
'@ @'
      NET.roster=netRosterClean(m.roster);
      for(i=0;i<NET.roster.length;i++) if(NET.roster[i].host&&NET.roster[i].pid) peer.pid=NET.roster[i].pid;   // v16.11, backcheck: the link to the host knows his id, so MUTE beside the host works
      hn='';
'@

SubRx @'
var VER='16.10';
'@ @'
var VER='16.11';
'@

$pat = "(?m)^  now:'v16\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.11: CO-OP FIXES FROM THE BACKCHECK. Paused in a shared raid the storm now runs on with the world. YES, ABANDON refuses a player who went down after arming it, as ABANDON already did. Holding E over a downed teammate takes E, so it no longer calls the extraction or searches a box too, and holding on after the pick-up sends nothing twice. The host world word no longer cuts a pull you began, no longer makes a ring that never closes look like it closes, and no longer moves your called ring. MUTE beside the host works. No number moved. Check 16.11 fails on v16.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
