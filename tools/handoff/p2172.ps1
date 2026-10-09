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

# A PEDDLER SALE IS SOLD FOR THE WHOLE PARTY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  st.sold=true; G.trade.traded=1;
'@ @'
  st.sold=true; G.trade.traded=1; if(typeof NET==='object'&&NET&&NET.on&&!G.sim) netPedSoldSend(G.trade,ix);   // v21.72 (K4): and the rest of the party is told the row is sold
'@

SubRx @'
function netWorldSend(){
'@ @'
// v21.72, from the whole-game bug hunt of 2026-10-08 (K4): A PEDDLER SALE IS SOLD FOR THE WHOLE PARTY. Every window keeps its own
// copy of the stall (the same rows, from the shared seed), and a purchase was never told: a row player 2 bought was still for sale
// on the host, so the stall gun or the showpiece could be bought twice, and when the Peddler died there the PEDLAR STOCK cache
// dropped it again. The window that sells now tells the others, as a door opened with its key is told (netDoorSend): the host
// tells everyone, a joined window tells the host, which tells the rest. No Credits move on the receiving side and no seeded draw
// moves.
function netPedSoldSend(e,ix){
  var i, w;
  if(!e||!e.nid) return false;
  w={t:'pedsold',sd:G.seed>>>0,id:e.nid,ix:ix|0};
  if(netEntsHost()){ netBroadcast(w); return true; }
  if(netEntsPeer()){ for(i=0;i<NET.peers.length;i++) if(NET.peers[i].state==='in') netSend(NET.peers[i],w); return true; }
  return false;
}
function netPedSoldTake(peer,m){
  var e, st;
  if(!peer||peer.state!=='in') return 'ignored';
  if(!G||(G.over&&G!==NET.specG)||((+m.sd)>>>0)!==(G.seed>>>0)) return 'other';
  e=(NET.entMap&&NET.entMap[m.id|0])||null;
  if(!e||e.kind!=='peddler'||!Array.isArray(e.stock)) return 'gone';
  st=e.stock[m.ix|0]; if(!st) return 'bad';
  if(!st.sold){ st.sold=true; if(NET.role==='host') netBroadcast({t:'pedsold',sd:G.seed>>>0,id:m.id|0,ix:m.ix|0}); }
  return 'pedsold';
}
function netWorldSend(){
'@

SubRx @'
  if(m.t==='door') return netDoorTake(peer,m);   // v20.29 (H15): a door opened with its key, for the whole party
'@ @'
  if(m.t==='door') return netDoorTake(peer,m);   // v20.29 (H15): a door opened with its key, for the whole party
  if(m.t==='pedsold') return netPedSoldTake(peer,m);   // v21.72 (K4): a Peddler row bought on another window is sold here too
'@

SubRx @'
var VER='21.71';
'@ @'
var VER='21.72';
'@

$pat = "(?m)^  now:'v21\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.72: In co-op, a stall item one player buys from the Peddler shows SOLD for the other and is not in his dropped stock. Check 21.72 fails on v21.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
