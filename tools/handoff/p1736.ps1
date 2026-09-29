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

# A WALL, A PIECE OF COVER OR A WINDOW BROKEN IN CO-OP NOW FALLS IN EVERY WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(CFG.decks!==1) clearDecks(g);   // v13.41: last, after every placement roll
'@ @'
  if(CFG.decks!==1) clearDecks(g);   // v13.41: last, after every placement roll
  // v17.36, co-op hunt 2026-09-28: every wall keeps the number it was built with, so a party can name the same wall after others
  // have fallen (the list is spliced as walls go, so an index moves). The same build numbers them the same in every window; no draw.
  for(var _wid=0;_wid<g.map.walls.length;_wid++) g.map.walls[_wid].wid=_wid;
'@

SubRx @'
  w.hpHit=G.t;
'@ @'
  w.hpHit=G.t;
  // v17.36, co-op hunt 2026-09-28: in a raid the host runs, the host breaks walls. Player 2 broke only his own copy of the map, so
  // cover stood in one window and was gone in the other. His window keeps the bar and asks the host (netWallAsk).
  if(netWallAsk(w,amt)) return false;
'@

SubRx @'
  if(G.dmgWalls){ var dx=G.dmgWalls.indexOf(w); if(dx>=0) G.dmgWalls.splice(dx,1); }
'@ @'
  if(G.dmgWalls){ var dx=G.dmgWalls.indexOf(w); if(dx>=0) G.dmgWalls.splice(dx,1); }
  netWallGone(w);   // v17.36, co-op hunt 2026-09-28: the host tells the party which wall fell, whoever broke it
'@

SubRx @'
  if(m.t==='wd') return netWorldTake(peer,m);   // v16.06: the raid clock, the weather, the bolts and the rings, from the host
'@ @'
  if(m.t==='wd') return netWorldTake(peer,m);   // v16.06: the raid clock, the weather, the bolts and the rings, from the host
  if(m.t==='wdmg'||m.t==='wall') return netWallTake(peer,m);   // v17.36, co-op hunt 2026-09-28: a hit on a wall asked of the host, or a wall that fell, from the host
'@

SubRx @'
function netWorldSend(){
'@ @'
// v17.36, co-op hunt 2026-09-28: THE HOST BREAKS THE WALLS. Each window broke only its own copy of the map, so a wreck the machines
// shot away on the host still stood for player 2, who was hit through it, and furniture he shot out was gone only for him, so he
// fired through a wall the enemies still stood behind. A linked window up top asks the host ({t:'wdmg'}) with the wall build number
// (wid) and the damage, and changes nothing but its bar; the host takes the damage through its own damageWall, and whenever a wall
// falls there, from any source, the party is told ({t:'wall'}) and each linked window takes it out and rebuilds. No seeded draw.
function netWallById(id){ var W=G.map.walls, i; for(i=0;i<W.length;i++) if(W[i].wid===id) return W[i]; return null; }
function netWallAsk(w,amt){
  var i;
  if(!w||w.wid===undefined||!netEntsPeer()) return false;
  for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],{t:'wdmg',sd:G.seed>>>0,id:w.wid,a:+(+amt||0).toFixed(2)});
  return true;
}
function netWallGone(w){
  if(!w||w.wid===undefined||!netEntsHost()) return false;
  netBroadcast({t:'wall',sd:G.seed>>>0,id:w.wid});
  return true;
}
function netWallTake(peer,m){
  var w, i, a;
  if(!peer||peer.state!=='in') return 'ignored';
  if(typeof m.id!=='number'||m.id!==(m.id|0)) return 'bad';
  if(m.t==='wdmg'){
    if(NET.role!=='host'||!netEntsHost()||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
    a=+m.a; if(!isFinite(a)||a<=0) return 'bad';
    w=netWallById(m.id); if(!w) return 'gone';
    return damageWall(w,a,w.x+w.w/2,w.y+w.h/2)?'wall:down':'wall:hit';
  }
  if(NET.role!=='join'||!netEntsPeer()||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
  w=netWallById(m.id); if(!w) return 'gone';
  G.map.walls.splice(G.map.walls.indexOf(w),1);
  if(G.dmgWalls){ i=G.dmgWalls.indexOf(w); if(i>=0) G.dmgWalls.splice(i,1); }
  rebuildGeometry();
  spark(w.x+w.w/2,w.y+w.h/2,'#c9b490',18,260);
  if(G.tel) G.tel.wallsDown=(G.tel.wallsDown||0)+1;
  return 'wall';
}
function netWorldSend(){
'@

SubRx @'
var VER='17.35';
'@ @'
var VER='17.36';
'@

$pat = "(?m)^  now:'v17\.35:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.36: Wall sync, co-op hunt 2026-09-28: damageWall spliced G.map.walls and ran rebuildGeometry in whichever window called it, and no word carried it, so after the first break the host (whose geometry decides enemy sight and netBulletPeer) and the player 2 window (whose geometry decides his movement and his rounds, which netShotTake applies with no sight test) held different maps. Every wall now keeps its build number (wid, stamped in buildRaid after clearDecks, the same in every window from the same build, no random draw), because the walls list is spliced as walls fall and an index would shift. On a linked window up top (netEntsPeer) damageWall keeps its hit points and bar but asks the host ({t:wdmg,sd,id,a}) and removes nothing; the host takes the ask through its own damageWall. Whenever a wall falls on the host, from any source, netWallGone tells the party ({t:wall,sd,id}) and netWallTake on each linked window splices that wall, clears its bar and rebuilds its geometry. A keyed door opened in one window is still not told to the others. No number moved and no player text changed. Check 17.36 fails on v17.35',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
