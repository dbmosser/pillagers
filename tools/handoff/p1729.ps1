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

# A SMOKE OR A DECOY PLAYER 2 THROWS NOW WORKS ON THE ENEMIES THE HOST RUNS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(th.kind==='smoke'){ G.smokes.push({x:th.tx,y:th.ty,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12}); sfx("clank",th.tx,th.ty); }
  else if(th.kind==='decoy'){ G.decoys.push({x:th.tx,y:th.ty,t:0,life:6,acc:.7}); sfx("clank",th.tx,th.ty); }
'@ @'
  // v17.29, co-op hunt 2026-09-28: and in a shared raid the party is told (netThrSend). Player 2 spent his smoke or decoy and it
  // landed only in his own window, where the enemies are copies: the host enemies saw him through the cloud and never heard the
  // decoy. The host now puts it in the world it runs, and the other windows draw it.
  if(th.kind==='smoke'){ G.smokes.push({x:th.tx,y:th.ty,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12}); sfx("clank",th.tx,th.ty); netThrSend('smoke',th.tx,th.ty); }
  else if(th.kind==='decoy'){ G.decoys.push({x:th.tx,y:th.ty,t:0,life:6,acc:.7}); sfx("clank",th.tx,th.ty); netThrSend('decoy',th.tx,th.ty); }
'@

SubRx @'
  ping(f.x,f.y,560,false,false,'env','fire');
'@ @'
  ping(f.x,f.y,560,false,false,'env','fire');
  if(!f.by) netThrSend('nz',f.x,f.y);   // v17.29, co-op hunt 2026-09-28: the blast of player 2 own charge is heard by the enemies the host runs
'@

SubRx @'
    if(dc.acc>=.8){ dc.acc=0; ping(dc.x,dc.y,420,false,false,'env','move'); }
'@ @'
    if(dc.acc>=.8){ dc.acc=0; if(!dc.fx) ping(dc.x,dc.y,420,false,false,'env','move'); }   // v17.29, co-op hunt 2026-09-28: a decoy passed on for drawing calls nothing; the host world hears it
'@

SubRx @'
  if(m.t==='fx') return netFxTake(peer,m);   // v16.21: a round or a sound from one of the party, to draw and play
'@ @'
  if(m.t==='fx') return netFxTake(peer,m);   // v16.21: a round or a sound from one of the party, to draw and play
  if(m.t==='thr') return netThrTake(peer,m);   // v17.29, co-op hunt 2026-09-28: a smoke, a decoy or a charge blast one of the party threw
'@

SubRx @'
function netFxTake(peer,m){
'@ @'
// v17.29, co-op hunt 2026-09-28: A SMOKE OR A DECOY PLAYER 2 THREW DID NOTHING ON THE HOST. No word carried a throw, so his cloud
// never reached the sight lines the host enemies look along and his decoy called only the copies in his own window. A smoke or a
// decoy thrown in a shared raid is sent on the reliable channel ({t:'thr'}); the host puts it in the world it runs and passes it
// on to the other windows, where a decoy is drawn and calls nothing (fx). The blast of a charge player 2 threw (nz) is heard on
// the host. Nothing here draws from the seeded stream. Solo play never sends or takes it.
function netThrSend(k,x,y){
  var i, m;
  if(!netUpShared()) return false;
  if(k==='nz'&&NET.role==='host') return false;   // the host own blast already reached the enemies it runs
  m={t:'thr',k:k,x:Math.round(x),y:Math.round(y)};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],m);
  return true;
}
function netThrTake(peer,m){
  var i, q, x, y, k=m.k;
  if(!peer||peer.state!=='in') return 'ignored';
  if(!netUpShared()) return 'off';
  if(k!=='smoke'&&k!=='decoy'&&k!=='nz') return 'bad';
  if(typeof m.x!=='number'||typeof m.y!=='number'||!isFinite(m.x)||!isFinite(m.y)) return 'bad';
  x=clamp(m.x,-9000,NET_UP_MAX); y=clamp(m.y,-9000,NET_UP_MAX);
  if(k==='nz'){ if(NET.role!=='host') return 'ignored'; ping(x,y,560,false,false,'env','fire'); return 'thr:nz'; }
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSend(q,{t:'thr',k:k,x:x,y:y}); }
  if(k==='smoke') G.smokes.push({x:x,y:y,r:(CFG.smokeR===undefined?165:CFG.smokeR),t:0,life:12});
  else G.decoys.push({x:x,y:y,t:0,life:6,acc:.7,fx:(NET.role==='host')?0:1});
  return 'thr:'+k;
}
function netFxTake(peer,m){
'@

SubRx @'
var VER='17.28';
'@ @'
var VER='17.29';
'@

$pat = "(?m)^  now:'v17\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.29: Party throwables, co-op hunt 2026-09-28: no word carried a throw. activateThrow put a smoke or a decoy into the G.smokes and G.decoys of the window that threw it, so on the player 2 window the cloud never reached the host G.vseg that host enemies test sight against (canSee in updateEnts), and the decoy pinged only the snapshot copies that netEntsApply overwrites; the frag blast ping in explodeFrag likewise reached only those copies. activateThrow now calls netThrSend, which sends {t:thr,k:smoke or decoy,x,y} on the reliable channel in a shared raid; explodeFrag sends k:nz for a charge that is not an enemy charge from a linked window. netThrTake on the host pushes the smoke into G.smokes (so refreshVseg adds it to the sight lines), pushes the decoy into G.decoys (so its ping runs over the real enemies), runs the 560 blast ping for nz, and passes smoke and decoy on to every other window but the sender. A window that only draws marks the decoy fx, and the decoy loop in updateThrowables skips the ping for it, so no copy is called. The host own smoke and decoy reach player 2 the same way. Pillager smokes are still drawn only on the host. No number moved and no player text changed. Check 17.29 fails on v17.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
