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

# A KEY OPENS THE DOOR FOR THE WHOLE PARTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      doorNear.open=true;
      for(var dw=G.map.walls.length-1;dw>=0;dw--)
        if(G.map.walls[dw].door===doorNear.id) G.map.walls.splice(dw,1);
      rebuildGeometry();   // shared with destruction, v2.83; fixes the window re-seal and the ghost-wall ray grid
'@ @'
      lockedOpen(doorNear);   // v20.29 (H15): the same opening on every window
      netDoorSend(doorNear.id);
'@

SubRx @'
function netWorldSend(){
'@ @'
// v20.29, from the whole-game bug hunt of 2026-10-08 (H15, H57): A KEY OPENS THE DOOR FOR THE WHOLE PARTY. A door opened with its key
// came down only in the window that used the key, and the key is single use, so the other player could never get into that room.
// The opening is told to the party: the host tells everyone, a joined window tells the host, which tells the rest, and every window
// opens the same door. No key is spent on the receiving side and no seeded draw moves.
function lockedOpen(LKR){
  if(!LKR||LKR.open) return false;
  LKR.open=true;
  for(var dw=G.map.walls.length-1;dw>=0;dw--) if(G.map.walls[dw].door===LKR.id) G.map.walls.splice(dw,1);
  rebuildGeometry();   // shared with destruction, v2.83; fixes the window re-seal and the ghost-wall ray grid
  return true;
}
function netDoorSend(id){
  var i;
  if(netEntsHost()){ netBroadcast({t:'door',sd:G.seed>>>0,id:id}); return true; }
  if(netEntsPeer()){ for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'door',sd:G.seed>>>0,id:id}); return true; }
  return false;
}
function netDoorTake(peer,m){
  var i, Lk;
  if(!peer||peer.state!=='in') return 'ignored';
  if(!(typeof m.id==='number'||(typeof m.id==='string'&&m.id.length<48))) return 'bad';
  if(!G||G.over||!G.map||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
  Lk=G.map.locked||[];
  for(i=0;i<Lk.length;i++) if(Lk[i].id===m.id){
    if(lockedOpen(Lk[i])){ say(Lk[i].name+' is open.'); if(NET.role==='host') netBroadcast({t:'door',sd:G.seed>>>0,id:m.id}); }
    return 'door';
  }
  return 'gone';
}
function netWorldSend(){
'@

SubRx @'
  if(m.t==='wdmg'||m.t==='wall') return netWallTake(peer,m);   // v17.36, co-op hunt 2026-09-28: a hit on a wall asked of the host, or a wall that fell, from the host
'@ @'
  if(m.t==='wdmg'||m.t==='wall') return netWallTake(peer,m);   // v17.36, co-op hunt 2026-09-28: a hit on a wall asked of the host, or a wall that fell, from the host
  if(m.t==='door') return netDoorTake(peer,m);   // v20.29 (H15): a door opened with its key, for the whole party
'@

SubRx @'
ww=netWallById(m.wg[i]|0); if(!ww) continue;
'@ @'
ww=netWallById(m.wg[i]|0); if(!ww) continue; if(ww.door!==undefined) (G.map.locked||[]).forEach(function(R){ if(R.id===ww.door) R.open=true; });   /* v20.29 (H15): a door already open is open here too */
'@

SubRx @'
var VER='20.28';
'@ @'
var VER='20.29';
'@

$pat = "(?m)^  now:'v20\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.29: In co-op, a locked room opened with its key is open for both players. Check 20.29 fails on v20.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
