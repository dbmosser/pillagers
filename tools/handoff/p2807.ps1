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

# THE BARRELS ARE THE SAME IN CO-OP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(p&&Math.hypot(x-p.x,y-p.y)<460) return false;
'@ @'
for(i=0;i<(m.spawns||[]).length;i++) if(Math.hypot(x-m.spawns[i].x,y-m.spawns[i].y)<460) return false;   // v27.xx (brlnet): clear of every drop point of the map, so every window lays the same barrels
  if(p&&Math.hypot(x-p.x,y-p.y)<460) return false;
'@

SubRx @'
function brlLight(B,by,fuse){
  if(!B||B.gone||B.fuse>=0) return false;
  B.fuse=fuse; B.by=by;
  return true;
}
'@ @'
function brlLight(B,by,fuse,net){
  if(!B||B.gone||B.fuse>=0) return false;
  B.fuse=fuse; B.by=by;
  if(!net){ try{ brlNetOut(B); }catch(_bno){} }   // v27.xx (brlnet): and the other windows light their copy
  return true;
}
// v27.xx (brlnet), the cloud review of 2026-10-15 (finding 4): THE BARRELS ARE THE SAME IN EVERY WINDOW AND A BLAST IS FELT IN EVERY WINDOW. They were laid by each
// window clear of its own player, so two windows could lay different sets; and a barrel one window lit went up only there. Now the set is laid clear of every drop point of
// the map (brlOk), and a barrel lit anywhere is told to the others ({t:'brl', i: the barrel, by: the seat that lit it or -1, f: its fuse}, on the reliable channel; the host passes a
// joined window word on to the rest, as a thrown charge is). Each window then runs the same fuse and the same blast: its own effects, the damage to its own player (a barrel a
// teammate lit still never hurts you, his rule of no team damage; one an enemy round lit, or you lit, does) and its walls; the host window also hurts the bodies it runs, credited to
// the seat that lit it. A barrel lit by the chain is lit the same way in both, and a word for one already lit is dropped. Solo play never sends or takes it.
function brlNetOut(B){
  var i, m;
  if(!G||G.sim||typeof netUpShared!=='function'||!netUpShared()) return false;
  m={t:'brl',i:B.id|0,by:(B.by|0)===B.by?B.by:-1,f:+(+B.fuse).toFixed(2)};
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],m);
  return true;
}
function brlNetTake(peer,m){
  var B, by, f, i, q;
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof netUpShared!=='function'||!netUpShared()) return 'off';
  if(!G||G.sim||!G.brl||typeof m.i!=='number'||!isFinite(m.i)) return 'bad';
  B=G.brl[m.i|0]; if(!B||B.id!==(m.i|0)||B.gone) return 'gone';
  by=(typeof m.by==='number'&&m.by===(m.by|0)&&m.by>=0&&m.by<8)?m.by:-1;
  f=clamp(+m.f||0.1,0.05,1);
  if(!brlLight(B,by,f,1)) return 'dup';
  if(NET.role==='host') for(i=0;i<NET.peers.length;i++){ q=NET.peers[i]; if(q!==peer&&q.state==='in') netSend(q,{t:'brl',i:B.id|0,by:by,f:f}); }
  return 'brl';
}
'@

SubRx @'
  if(m.t==='thr') return netThrTake(peer,m);
'@ @'
  if(m.t==='brl') return brlNetTake(peer,m);   // v27.xx (brlnet): an explosive barrel one of the party lit
  if(m.t==='thr') return netThrTake(peer,m);
'@

SubRx @'
var VER='28.06';
'@ @'
var VER='28.07';
'@

$pat = "(?m)^  now:'v28\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.07: Explosive barrels now go up in both windows of a two-player game, and both windows lay the same barrels. Check 28.07 fails on v28.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
