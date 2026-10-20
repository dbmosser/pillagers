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

# A DROPPED ITEM PINGS YOUR TEAMMATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v21.95, from the whole-game bug hunt of 2026-10-08 (K5): A HOST'S ARMOURY GUN DROPPED WITH A TEAMMATE UP TOP COMES OFF HIS SAVED

'@ @'
  // v32.xx (cw-droppings), planner draft 2026-10-20 (his pick 48, "drop an item with an auto-ping so the teammate sees it"): the host's drop pings the teammate.
  if(!G.sim&&typeof NET==='object'&&NET&&NET.on&&NET.role==='host'&&typeof netUpShared==='function'&&netUpShared()) netPileShare(NET.seat,key,c.x,c.y);
  // v21.95, from the whole-game bug hunt of 2026-10-08 (K5): A HOST'S ARMOURY GUN DROPPED WITH A TEAMMATE UP TOP COMES OFF HIS SAVED

'@

SubRx @'
  G.containers.push(c);
  return 'pile';

'@ @'
  G.containers.push(c);
  netPileShare(peer.seat,k,c.x,c.y);   // v32.xx (cw-droppings): the other window of the party gets the pile ping
  return 'pile';

'@

SubRx @'
  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24),dg:m.dg?1:0};
  if(typeof m.id==='number') o.id=m.id|0;
  if(NET.role==='host'){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'png',s:s,x:o.x,y:o.y,w:o.w,id:o.id,dg:o.dg}); }

'@ @'
  var o={x:clamp(m.x,-9000,NET_UP_MAX),y:clamp(m.y,-9000,NET_UP_MAX),w:netClean(m.w,24),dg:m.dg?1:0,pl:m.pl?1:0};   // v32.xx (cw-droppings): pl marks a pile ping
  if(typeof m.id==='number') o.id=m.id|0;
  if(NET.role==='host'){ var i; for(i=0;i<NET.peers.length;i++) if(NET.peers[i]!==peer&&NET.peers[i].state==='in') netSend(NET.peers[i],{t:'png',s:s,x:o.x,y:o.y,w:o.w,id:o.id,dg:o.dg,pl:o.pl}); }

'@

SubRx @'
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,at:Date.now()});

'@ @'
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,pl:o.pl?1:0,at:Date.now()});

'@

SubRx @'
function netPingDraw(){

'@ @'
// v32.xx (cw-droppings), planner draft 2026-10-20 (his pick 48): A DROPPED ITEM PINGS THE TEAMMATE. The host makes every pile, so it is the one place that
// knows a pile was made: it sends the ordinary ping word (png, the v16.43 ping and its look) marked pl, with the item name, to every window of the party but
// the one that dropped it, and keeps the ping itself when the dropper was a guest. The dropper gets none, and solo gets none. Returns how many windows got it.
function netPileShare(seat,key,x,y){
  var i, pe, m, n=0, it=(typeof ITEMS==='object'&&ITEMS)?ITEMS[key]:null;
  if(typeof NET!=='object'||!NET||!NET.on||NET.role!=='host'||!it||typeof G==='undefined'||!G||G.sim||!isFinite(x)||!isFinite(y)) return 0;
  m={t:'png',s:seat,x:Math.round(x),y:Math.round(y),w:netClean(it.name,24),pl:1};
  for(i=0;i<NET.peers.length;i++){ pe=NET.peers[i]; if(pe.state!=='in'||pe.seat===seat) continue; if(netSend(pe,m)) n++; }
  if(seat!==NET.seat){ netPingPush(seat,{x:m.x,y:m.y,w:m.w,pl:1}); n++; }
  return n;
}
// A pile ping ends when its pile is taken (the box is opened, on every window) or after the normal ping time, whichever is first. The first 1.5 s are
// left alone so a window still waiting for the host box word does not clear it.
function netPilePrune(){
  var i, j, p, c, live, now=Date.now();
  if(!NET.pings||typeof G==='undefined'||!G||!G.containers) return 0;
  for(i=NET.pings.length-1;i>=0;i--){
    p=NET.pings[i]; if(!p.pl||now-p.at<1500) continue;
    live=false;
    for(j=0;j<G.containers.length&&!live;j++){ c=G.containers[j]; if(c.dropped&&!c.opened&&Math.abs(c.x-p.x)<8&&Math.abs(c.y-p.y)<8) live=true; }
    if(!live) NET.pings.splice(i,1);
  }
  return NET.pings.length;
}
function netPingDraw(){
  netPilePrune();   // v32.xx (cw-droppings)

'@

SubRx @'
var VER='32.96';
'@ @'
var VER='32.97';
'@

$pat = "(?m)^  now:'v32\.96:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.97: A dropped item shows as a ping with its name on the teammate map, minimap and in the world until someone takes it. Check 32.97 fails on v32.96',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
