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

# CRATES OUTLIVE A WINDOW COMING AND GOING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      netSrchEndSeat(peer.seat);   // v15.91: a box he was searching is free again
'@ @'
      netSrchEndSeat(peer.seat);   // v15.91: a box he was searching is free again
      try{ if(typeof HB==='object'&&HB&&HB.drops) HB.drops=HB.drops.filter(function(q){ return q.by!==peer.seat; }); }catch(_hd){}   // v18.58: his crates leave the floor with him; they go home to his own stash (floorDropsRestore)
'@

SubRx @'
      netSend(peer,{t:'welcome',you:seat,roster:NET.roster,ver:VER,up:netWelcomeUp()});   // v17.53: and the raid the host is in, for a teammate who links late
'@ @'
      netSend(peer,{t:'welcome',you:seat,roster:NET.roster,ver:VER,up:netWelcomeUp()});   // v17.53: and the raid the host is in, for a teammate who links late
      try{ hubDropsTell(peer,false); }catch(_ht){}   // v18.58: and every crate on the floor, dropped before he linked
'@

SubRx @'
      if(typeof m.up==='number'&&m.up>0){ NET.hostSeed=m.up>>>0; NET.status+=' They are in a raid now: go up at the lift to join it.'; }   // v17.53: a teammate who links late can drop in
'@ @'
      if(typeof m.up==='number'&&m.up>0){ NET.hostSeed=m.up>>>0; NET.status+=' They are in a raid now: go up at the lift to join it.'; }   // v17.53: a teammate who links late can drop in
      try{ hubDropsTell(peer,true); }catch(_jt){}   // v18.58: and the host is told this window's own crates again
'@

SubRx @'
  if(NET.on&&d.by===NET.seat){ say2(
'@ @'
  if(NET.on&&d.by===NET.seat&&netHubSeat()>=0){ say2(
'@

SubRx @'
function floorDropForget(id){
'@ @'
// v18.58, FROM THE CODE COMB (2026-10-07): CRATES OUTLIVE A WINDOW COMING AND GOING. A crate was told to the party only once, when it
// was dropped, so one dropped before the other window linked (or while it reloaded, as picking a character does) was never seen
// there, and the dropper could not take it back while linked: it sat until the party ended. And a window that left kept its
// crates on the other floor while they also came home to its own stash on its next load, so the other player could take the same
// item again. Now a linking window is told every crate on the floor (the host tells all, a teammate tells its own again), a
// window that leaves takes its crates off the other floor, and the dropper can take a crate back while no teammate is linked.
function hubDropsTell(peer,own){
  var a=(typeof HB==='object'&&HB&&HB.drops)||[], f=P.floorDrops||[], mine={}, i, n=0;
  for(i=0;i<f.length;i++) if(f[i]) mine[f[i].id]=1;
  for(i=0;i<a.length;i++){
    if(own&&!mine[a[i].id]) continue;
    if(own) a[i].by=NET.seat;
    if(netSend(peer,{t:'hdrop',op:'put',id:a[i].id,k:a[i].k,x:a[i].x,y:a[i].y})) n++;
  }
  return n;
}
function floorDropForget(id){
'@

SubRx @'
  if(!HB) return 'nofloor';
'@ @'
  if(!HB){ try{ titleSceneReady(); }catch(_tb){} }   // v18.58: a crate told before this window drew its floor is kept
  if(!HB) return 'nofloor';
'@

SubRx @'
var VER='18.57';
'@ @'
var VER='18.58';
'@

$pat = "(?m)^  now:'v18\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.58: Items dropped on the Undercroft floor show up for player 2 even if they were dropped before player 2 window opened, and can never be picked up twice. Check 18.58 fails on v18.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
