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

# THE HOST ENEMIES NOW HEAR PLAYER 2, AND HIS OWN WINDOW NO LONGER FAKES A LISTENER WAKING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function ping(x,y,s,h,quiet,src,typ,ent){
  if(!G) return;
  s*=CFG.noiseMult*wx().noise;
'@ @'
function ping(x,y,s,h,quiet,src,typ,ent,pre){
  if(!G) return;
  // v17.30, co-op hunt 2026-09-28: pre is set only for a teammate noise the host takes (netFxTake, k z). His own window already
  // scaled it by the noise setting, the weather and his own rig, so none of the three is applied twice or swapped for the host rig.
  if(!pre) s*=CFG.noiseMult*wx().noise;
'@

SubRx @'
  if(src==='player'&&G.player) s*=armorById(G.player.rig).noise;
'@ @'
  if(src==='player'&&G.player&&!pre) s*=armorById(G.player.rig).noise;
'@

SubRx @'
  listenersHear(x,y,s,src==='player');
'@ @'
  // v17.30, co-op hunt 2026-09-28: on a linked window up top the host runs every body, so a noise here wakes nothing. The mirror
  // Listener woke, screamed on both windows and said Something woke up, then the next host word put it back to sleep, while on the
  // host nothing ever heard player 2. His own noises now go to the host (netFxStep sends them, netFxTake plays them through ping).
  if(NET.on&&netEntsPeer()){ if(src==='player'){ NET.nzQ=NET.nzQ||[]; if(NET.nzQ.length<16) NET.nzQ.push([Math.round(x),Math.round(y),Math.round(s),quiet?1:0,typ==='fire'?'fire':'move']); } return; }
  listenersHear(x,y,s,src==='player');
'@

SubRx @'
  return G.fxBullets?G.fxBullets.length:0;
'@ @'
  // v17.30, co-op hunt 2026-09-28: and the noises this linked window made (ping), on their own tenth of a second clock, for the host
  // to play on the bodies it runs. A queue left from a raid that is no longer shared is dropped, not sent.
  if(NET.nzQ&&NET.nzQ.length&&!netEntsPeer()) NET.nzQ=[];
  NET.nzAcc=(NET.nzAcc||0)+dt;
  if(NET.nzAcc>=NET_HUB_STEP&&NET.nzQ&&NET.nzQ.length){
    NET.nzAcc=0; m={t:'fx',k:'z',s:NET.seat,z:NET.nzQ.slice(0,16)}; NET.nzQ=[];
    for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSendFast(NET.peers[i],m);
  }
  return G.fxBullets?G.fxBullets.length:0;
'@

SubRx @'
  if(!netUpShared()) return 'off';
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSendFast(q,m); }
'@ @'
  if(!netUpShared()) return 'off';
  // v17.30, co-op hunt 2026-09-28: the noises of a teammate (his steps, shots, hails, doors), taken on the host and played through ping on
  // the bodies it runs, so a Listener wakes and patrols investigate him as they do the host player. Scaled in his window already (pre).
  if(m.k==='z'){
    if(NET.role!=='host'||!netEntsHost()||!m.z||!m.z.length) return 'ignored';
    for(i=0;i<m.z.length&&i<16;i++){ a=m.z[i]; if(a&&isFinite(a[0])&&isFinite(a[1])&&isFinite(a[2])&&(+a[2])>0) ping(+a[0],+a[1],+a[2],false,!!a[3],'player',a[4]==='fire'?'fire':'move',null,1); }
    return 'fx:z';
  }
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSendFast(q,m); }
'@

SubRx @'
var VER='17.29';
'@ @'
var VER='17.30';
'@

$pat = "(?m)^  now:'v17\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.30: Party noise, co-op hunt 2026-09-28: every noise the enemies react to goes through ping, and on a linked window up top ping ran listenersHear and the patrol loop against the mirror bodies the host runs. A dormant mirror Listener woke, played the alarm (forwarded to the host as a sound, so both windows screamed), said Something woke up, and the next host snapshot set it back to dormant, so it repeated on every step or shot. Nothing ever reached the host: the fx n word only plays a sound. Now ping on a linked window wakes nothing and queues the player noises (x, y, the strength already scaled in his window, quiet, move or fire); netFxStep sends them on the same tenth of a second clock as a new fx word k z, and on the host netFxTake plays each through ping with a new pre flag that skips the noise setting, the weather and the rig, which his window already applied. The host own noises and solo play are unchanged. No number moved. Check 17.30 fails on v17.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
