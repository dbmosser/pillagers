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

# TEAMMATE REVIVES. Multiplayer, his ruling of 2026-09-25 (teammate revives in the first co-op version).

SubRx @'
  var downRdr=null;
'@ @'
  netRevHold(p,dt);   // v16.05: holding E beside a downed teammate picks him up (the net section)
  var downRdr=null;
'@

SubRx @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
'@ @'
  if(m.t==='kill') return netKillTake(peer,m);   // v15.80: a kill credited to this seat, from the host
  if(m.t==='rev') return netRevTake(peer,m);   // v16.05: a teammate picked this player up, or (on the host) passes it on
'@

SubRx @'
function netKillTake(peer,m){
'@ @'
// v16.05, HIS RULING OF 2026-09-25: TEAMMATE REVIVES IN THE FIRST CO-OP VERSION. Up top, a player on his feet who holds E within
// NET_REV_R of a teammate who is down (the dn flag of his state word, on this raid seed) fills a pick-up for NET_REV_T seconds,
// the time a hire takes to pick you up; letting go or stepping away starts it again. When it fills, the word {t:'rev',s:seat}
// goes to the host, which applies it to itself or passes it to that seat with by:the reviver. The downed window checks it is
// down, not already finished, and that the reviver stands within reach as it last heard, then gets up exactly as a hire picks
// him up: health 40 percent, two seconds of cover, no killer pending, a revive on his tally. His one self-revive is untouched.
// No new number: 64 is the reach of the pillager pick-up and 3.2 the hire pick-up time. Nothing here draws from the seeded stream.
var NET_REV_R=64, NET_REV_T=3.2;
function netMateDown(p){
  var i, g, best=-1, bd=NET_REV_R, d;
  if(!NET.on||!netUpShared()||!p||p.downed||!NET.upSeed) return -1;
  for(i=0;i<NET.up.length;i++){
    g=NET.up[i];
    if(!g||!g.dn||g.seat===NET.seat||netSeatName(g.seat)===null||g.sd!==(NET.upSeed>>>0)) continue;
    d=Math.hypot(g.x-p.x,g.y-p.y); if(d<=bd){ bd=d; best=g.seat; }
  }
  return best;
}
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
  if(NET.role==='host') netRevPass(s,NET.seat);
  else for(var i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'rev',s:s});
  say('You pull '+nm+' up.'); blip('pick');
  return true;
}
// On the host: a pick-up for its own player, or passed on to the seat it names.
function netRevPass(s,by){
  var i;
  if(s===NET.seat) return netRevApply(by);
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in'&&NET.peers[i].seat===s) return netSend(NET.peers[i],{t:'rev',s:s,by:by})?'passed':'lost';
  return 'nobody';
}
function netRevTake(peer,m){
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.s!=='number'||m.s!==(m.s|0)) return 'bad';
  if(NET.role==='host') return netRevPass(m.s,peer.seat);
  if(NET.role==='join'){ if(m.s!==NET.seat) return 'ignored'; return netRevApply((typeof m.by==='number')?(m.by|0):0); }
  return 'off';
}
// This player is picked up by seat by, if he is down and that teammate stands within reach of him as this window last heard.
function netRevApply(by){
  var p, g;
  if(typeof G==='undefined'||!G||G.over||G.sim||!G.player) return 'no raid';
  p=G.player;
  if(!p.downed||(G.deathBeat!==undefined&&G.deathBeat!==null)) return 'not down';
  g=NET.up[by];
  if(!g||Math.hypot(g.x-p.x,g.y-p.y)>NET_REV_R*1.5) return 'far';
  p.downed=false; p.hp=Math.round(p.maxhp*0.4); p.iv=2; p.pendKiller=null;
  if(G.tel) G.tel.revives=(G.tel.revives||0)+1;
  blip('pick'); say((netSeatName(by)||'Your teammate')+' pulls you up.');
  label(p.x,p.y-22,'PICKED UP','#4de3d0',0,true);
  return 'up';
}
function netKillTake(peer,m){
'@

SubRx @'
var VER='16.04';
'@ @'
var VER='16.05';
'@

$pat = "(?m)^  now:'v16\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.05: TEAMMATE REVIVES. Multiplayer, his ruling. Up top, hold E beside a downed teammate for 3.2 seconds, the time a hire takes, and he gets up with 40 percent health exactly as a hire picks you up. Letting go starts it again. The word goes through the host, and the downed window checks he is down and the teammate is beside him. His one self-revive is untouched. No new number. Check 16.05 fails on v16.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
