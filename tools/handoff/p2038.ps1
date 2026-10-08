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

# THE CRIER MARKS THE PLAYER IT SAW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
        e.markX=p.x; e.markY=p.y;      // the position that gets called in
        sfx('alarm',e.x,e.y);
        say('A crier has you. Kill it or move.');
'@ @'
        e.markX=p.x; e.markY=p.y;      // the position that gets called in
        sfx('alarm',e.x,e.y);
        // v20.38, from the whole-game bug hunt of 2026-10-08 (H11): THE PLAYER IT MARKS IS THE ONE TOLD. A Crier that spotted
        // player 2 warned the host and later flashed MARKED on the host, while player 2 got no line, no countdown and no banner.
        // The marked seat is kept on the Crier; the host hears the line only when it is him, and the party is told the windup so
        // every window draws the countdown and the marked player gets his own line and banner.
        e.markSeat=(p&&p.net)?(p.seat|0):0;
        if(!e.markSeat) say('A crier has you. Kill it or move.');
        if(NET.on) netMarkSend({t:'mark',k:'on',nid:e.nid|0,wind:+(+e.wind).toFixed(2),seat:e.markSeat});
'@

SubRx @'
          G.marked=2.2; T.marked=(T.marked||0)+1;
say(sees?'The Crier raised the alarm. They know exactly where you are.'   // v11.94, HIS NOTE: name the Crier
'@ @'
          if(NET.on) netMarkSend({t:'mark',k:'fire',nid:e.nid|0,seat:e.markSeat|0,sees:sees?1:0});   // v20.38 (H11)
          if(!e.markSeat){ G.marked=2.2; T.marked=(T.marked||0)+1; }
          // v20.38 (H11): the lines below are for the host only when the Crier marked him; player 2 gets them from the word above
          if(!e.markSeat)
say(sees?'The Crier raised the alarm. They know exactly where you are.'   // v11.94, HIS NOTE: name the Crier
'@

SubRx @'
        if(!e.announced){ e.announced=true; say('Something very large has noticed you.'); sfx('alarm',e.x,e.y); } }
'@ @'
        if(!e.announced){ e.announced=true; if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'big',nid:e.nid|0,seat:p.seat|0}); } else say('Something very large has noticed you.'); sfx('alarm',e.x,e.y); } }   // v20.38 (H11): said to the player it noticed
'@

SubRx @'
  if(m.t==='door') return netDoorTake(peer,m);   // v20.29 (H15): a door opened with its key, for the whole party
'@ @'
  if(m.t==='door') return netDoorTake(peer,m);   // v20.29 (H15): a door opened with its key, for the whole party
  if(m.t==='mark') return netMarkTake(peer,m);   // v20.38 (H11): a Crier or THE OVERSEER on one of the party, told to his window
'@

SubRx @'
    if(e.overheat>0) e.overheat-=dt; if(e.shotT>0) e.shotT-=dt;
'@ @'
    if(e.overheat>0) e.overheat-=dt; if(e.shotT>0) e.shotT-=dt;
    if(typeof e.wind==='number'&&e.wind>0) e.wind=Math.max(0,e.wind-dt);   // v20.38 (H11): a Crier windup the host told this window counts down here
'@

SubRx @'
function netEntsEase(dt){
'@ @'
// v20.38, from the whole-game bug hunt of 2026-10-08 (H11): A CRIER OR THE OVERSEER ON ONE OF THE PARTY. The host tells everyone
// a Crier windup (so each window draws its countdown) and when it fires, and tells the player it marked or THE OVERSEER noticed
// his line, his banner and his tally on his own window.
function netMarkSend(w){ if(typeof netEntsHost!=='function'||!netEntsHost()) return false; netBroadcast(w); return true; }
function netMarkTake(peer,m){
  var e, k, mine;
  if(!peer||peer.state!=='in'||NET.role!=='join') return 'ignored';
  if(!netEntsPeer()) return 'down';
  k=netClean(m.k,6); e=NET.entMap?NET.entMap[m.nid|0]:null; mine=((m.seat|0)===NET.seat);
  if(k==='on'){
    if(e){ e.wind=clamp(isFinite(+m.wind)?+m.wind:3.5,0,6); e.state='alarm'; }
    if(!G.sim){ if(e) sfx('alarm',e.x,e.y); if(mine) say('A crier has you. Kill it or move.'); }
    return 'mark:on';
  }
  if(k==='fire'){
    if(e) e.wind=null;
    if(mine){
      G.marked=2.2; if(G.tel) G.tel.marked=(G.tel.marked||0)+1;
      if(!G.sim) say(m.sees?'The Crier raised the alarm. They know exactly where you are.':'The Crier raised the alarm. They are heading to where it last saw you.');
    }
    return 'mark:fire';
  }
  if(k==='big'){ if(mine&&!G.sim) say('Something very large has noticed you.'); return 'mark:big'; }
  return 'bad';
}
function netEntsEase(dt){
'@

SubRx @'
var VER='20.37';
'@ @'
var VER='20.38';
'@

$pat = "(?m)^  now:'v20\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.38: In co-op, a Crier that spots player 2 warns player 2, shows him its countdown, and marks him, not the host. Check 20.38 fails on v20.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
