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

# A CONTROLLER THAT DROPS OR COMES BACK NO LONGER MOVES THE OTHER PLAYER'S CONTROLLER TO ITS WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPadFor(side,pick,taken,gps){
  var i, n=(gps&&gps.length)||0;
'@ @'
// v17.27, co-op hunt 2026-09-28: THE PAD EACH SIDE IS PLAYING IS KEPT (NET.padWas, by pair code), so slot order alone no
// longer decides it every frame. When the pad of player 2 dropped, the host pad was the first connected one and went to the
// player 2 window, and a pad coming back to a lower slot swapped the two. Now, with was, a side keeps its pad while it stays
// plugged in, player 2 never takes the pad the host is on, and only a pad nobody is on fills a side with none. A pick clears it.
function netPadWasFor(){ var w=NET.padWas; return (w&&w.pair===NET.pair)?w:null; }
function netPadStick(host,p2){ NET.padWas={pair:NET.pair,host:netPadIxOk(host),p2:netPadIxOk(p2)}; }
function netPadFor(side,pick,taken,gps,was){
  var i, n=(gps&&gps.length)||0, held=-1;
'@

SubRx @'
    taken=netPadFor('p2',taken,-1,gps);
    for(i=0;i<n;i++) if(i!==taken&&gps[i]&&gps[i].connected) return i;
'@ @'
    taken=netPadFor('p2',taken,-1,gps,was);
    held=was?netPadIxOk(was.host):-1;   // v17.27: the pad the host was playing stays on the host while it is plugged in
    if(held>=0&&held!==taken&&held<n&&gps[held]&&gps[held].connected) return held;
    for(i=0;i<n;i++) if(i!==taken&&gps[i]&&gps[i].connected) return i;
'@

SubRx @'
  for(i=0;i<n;i++) if(i!==taken&&gps[i]&&gps[i].connected) return i;
  return -1;
}
'@ @'
  if(was){   // v17.27: player 2 keeps the pad it was playing while it is plugged in, and never takes the one the host is on
    i=netPadIxOk(was.p2);
    if(i>=0&&i!==taken&&i<n&&gps[i]&&gps[i].connected) return i;
    if(taken<0) held=netPadIxOk(was.host);
  }
  for(i=0;i<n;i++) if(i!==taken&&i!==held&&gps[i]&&gps[i].connected) return i;
  return -1;
}
'@

SubRx @'
function netPadInit(){ netPadLoad(); NET.padOther=-1; NET.padFwd=null; netPadPost(); return NET.padIx; }
'@ @'
function netPadInit(){ netPadLoad(); NET.padOther=-1; NET.padFwd=null; NET.padWas=null; netPadPost(); return NET.padIx; }   // v17.27: a new pair starts the kept sides over
'@

SubRx @'
  netPadPost();
  netRefresh();
'@ @'
  NET.padWas=null;   // v17.27, co-op hunt 2026-09-28: a new pick starts the kept sides over
  netPadPost();
  netRefresh();
'@

SubRx @'
  if(m.t==='padpick'){ NET.padOther=netPadIxOk(m.ix); return 'padpick'; }
'@ @'
  if(m.t==='padpick'){ if(netPadIxOk(m.ix)!==NET.padOther) NET.padWas=null; NET.padOther=netPadIxOk(m.ix); return 'padpick'; }   // v17.27: a changed pick from the other window starts the kept sides over
'@

SubRx @'
  NET.padFwd=null; NET.padOther=-1;   // v15.77: the handed-over state and the other window's pick go with the channel; this window's own pick stays
'@ @'
  NET.padFwd=null; NET.padOther=-1;   // v15.77: the handed-over state and the other window's pick go with the channel; this window's own pick stays
  NET.padWas=null;   // v17.27: and the kept sides
'@

SubRx @'
function netPadSend(g,ix){
'@ @'
function netPadSend(g,ix,at){   // v17.27: at is the pad the sending window plays, so the other window keeps the same sides
'@

SubRx @'
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,p:p,v:v,a:a})) return false;
'@ @'
  if(!netSamePost({t:'pad',pair:NET.pair,ix:ix,own:NET.padIx,at:netPadIxOk(at),p:p,v:v,a:a})) return false;
'@

SubRx @'
  NET.padGot++;
'@ @'
  NET.padGot++;
  if(typeof m.at==='number'){ if(NET.same==='host') netPadStick(ix,netPadIxOk(m.at)); else netPadStick(netPadIxOk(m.at),ix); }   // v17.27: keep the sides the window in front keeps
'@

SubRx @'
    other=netPadFor((NET.same==='host')?'p2':'host',NET.padOther,NET.padIx,gps);
    if(other>=0) netPadSend(gps[other],other);
    mine=netPadFor(NET.same,NET.padIx,NET.padOther,gps);
'@ @'
    var was=netPadWasFor();   // v17.27, co-op hunt 2026-09-28: the sides kept from the frame before, so a pad that drops or comes back moves no one else
    other=netPadFor((NET.same==='host')?'p2':'host',NET.padOther,NET.padIx,gps,was);
    mine=netPadFor(NET.same,NET.padIx,NET.padOther,gps,was);
    if(NET.same==='host') netPadStick(mine,other); else netPadStick(other,mine);
    if(other>=0) netPadSend(gps[other],other,mine);
'@

SubRx @'
var VER='17.26';
'@ @'
var VER='17.27';
'@

$pat = "(?m)^  now:'v17\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.27: Co-op hunt 2026-09-28, finding 9: netPadTick worked out both sides every frame from netPadFor, which reads only slot order and the two picks. With no picks player 2 was the first connected pad and the host the first other one, so when the pad of player 2 left slot 0 the host pad became the first connected pad, was handed to the player 2 window (netPadRecv takes any pad but the sender own with no pick) and the host let go of it; a pad that came back to a lower slot than the player 2 pad took player 2 over the same way. The live window now keeps the pad each side played on the frame before (NET.padWas, tagged with the pair code): netPadFor takes it as an optional last argument, and with it a side keeps its pad while it stays plugged in, player 2 never takes the pad the host is on, and a side whose pad went takes only a pad nobody is on. Every handed-over state now carries the pad the sending window plays (at), and the window that takes it keeps the same sides, so when the other window comes to the front it goes on with them. A new pick on either side, a new pair and the end of the channel start the sides over, so his v16.35 order still sets them at the start. A call of netPadFor without the last argument answers as before. No number and no player text moved. Check 17.27 fails on v17.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
