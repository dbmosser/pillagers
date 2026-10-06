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

# FLOOR CRATES ARE NEVER LOST OR DOUBLED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  d.x=clamp(d.x,30,HUBW-30); d.y=clamp(d.y,30,HUBH-30);
  HB.drops.push(d);
'@ @'
  d.x=clamp(d.x,30,HUBW-30); d.y=clamp(d.y,30,HUBH-30);
  // v18.46, FROM THE CODE COMB (2026-10-06): A CRATE NEVER LANDS INSIDE A STATION'S REACH. Drops are made at the stash, so the crate
  // fell inside the stash's 46 unit reach, often inside its plinth, where E always opened the stash and nobody could ever take it.
  // It is pushed out from any station it lands near, toward the player who dropped it, to the station's reach plus 22.
  (function(){ var k, st, dd, ax, ay, al; for(k=0;k<(HB.stations||[]).length;k++){ st=HB.stations[k]; dd=Math.hypot(d.x-st.x,d.y-st.y);
    if(dd<(st.r||46)+22){ ax=p.x-st.x; ay=p.y-st.y; al=Math.hypot(ax,ay)||1; d.x=Math.round(st.x+ax/al*((st.r||46)+22)); d.y=Math.round(st.y+ay/al*((st.r||46)+22)); d.x=clamp(d.x,30,HUBW-30); d.y=clamp(d.y,30,HUBH-30); } } })();
  HB.drops.push(d);
  // v18.46: and it is written down, so a reload, a crash or a party ending never loses it: it goes back to this stash (floorDropsRestore)
  P.floorDrops=P.floorDrops||[]; P.floorDrops.push({id:d.id,k:d.k}); saveProfile();
'@

SubRx @'
function hubDropTake(d){
  var it=d&&ITEMS[d.k], i;
  if(!d||!it) return false;
'@ @'
// v18.46, FROM THE CODE COMB (2026-10-06): A CRATE IS NEVER TAKEN TWICE OR LOST. The dropper cannot take his own crate back while the
// party is linked (both windows pressing E at once took one item twice); his crates are written in the profile and come back to his
// stash when the party ends, on the next load after a reload or a crash, and never vanish with the floor.
function floorDropForget(id){ var i, a=P.floorDrops||[]; for(i=0;i<a.length;i++) if(a[i].id===id){ a.splice(i,1); try{ saveProfile(); }catch(_s){} return true; } return false; }
function floorDropsRestore(){
  var a=P.floorDrops||[], n=0, i, ids={};
  for(i=0;i<a.length;i++){ if(a[i]&&ITEMS[a[i].k]){ P.stash.push(a[i].k); n++; ids[a[i].id]=1; } }
  P.floorDrops=[];
  if(typeof HB==='object'&&HB&&HB.drops) HB.drops=HB.drops.filter(function(q){ return !ids[q.id]&&q.by!==NET.seat; });
  if(n){ try{ saveProfile(); }catch(_s){} try{ refreshInv(); }catch(_r){} }
  return n;
}
function hubDropTake(d){
  var it=d&&ITEMS[d.k], i;
  if(!d||!it) return false;
  if(NET.on&&d.by===NET.seat){ say2('That is the '+it.name+' you dropped for '+((typeof netHubSeat==='function'&&netHubSeat()>=0)?(netSeatName(netHubSeat())||'your teammate'):'your teammate')+'. It comes back to your stash if they leave it.'); return false; }
  floorDropForget(d.id);
'@

SubRx @'
  if(m.op==='took'){
    for(i=0;i<HB.drops.length;i++) if(HB.drops[i].id===m.id){ HB.drops.splice(i,1); break; }
'@ @'
  if(m.op==='took'){
    floorDropForget(m.id);   // v18.46: a crate this window dropped was taken, so it is no longer owed back
    for(i=0;i<HB.drops.length;i++) if(HB.drops[i].id===m.id){ HB.drops.splice(i,1); break; }
'@

SubRx @'
function netReset(keepErr){
  var ps=NET.peers.slice(), i;
'@ @'
function netReset(keepErr){
  var ps=NET.peers.slice(), i;
  try{ if(NET.on) floorDropsRestore(); if(typeof HB==='object'&&HB) HB.drops=[]; }catch(_fd){}   // v18.46: the party ends, every crate leaves the floor and this window's own come home
'@

SubRx @'
  try{ applyGameOpts(); }catch(_ag2){}   // v12.01: once more here, where a loader that threw part way cannot skip it
'@ @'
  try{ applyGameOpts(); }catch(_ag2){}   // v12.01: once more here, where a loader that threw part way cannot skip it
  try{ floorDropsRestore(); }catch(_fdr){}   // v18.46: crates left on the floor by a reload or a crash come home
'@

SubRx @'
  if(!best&&HB.drops&&HB.drops.length){ var _dbd=44, _ddd; for(i=0;i<HB.drops.length;i++){ _ddd=dist(p,HB.drops[i]); if(_ddd<_dbd){ _dbd=_ddd; HB.nearDrop=HB.drops[i]; } } }
'@ @'
  // v18.46, from the code comb: the nearest crate within reach wins over a station when the player stands nearer the crate
  if(HB.drops&&HB.drops.length){ var _dbd=44, _ddd, _dn=null; for(i=0;i<HB.drops.length;i++){ _ddd=dist(p,HB.drops[i]); if(_ddd<_dbd){ _dbd=_ddd; _dn=HB.drops[i]; } }
    if(_dn&&(!best||_dbd<dist(p,best))){ HB.nearDrop=_dn; best=null; HB.near=null; } }
'@

SubRx @'
var VER='18.45';
'@ @'
var VER='18.46';
'@

$pat = "(?m)^  now:'v18\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.46: Items dropped on the Undercroft floor can always be picked up, are never doubled, and come back to you if nobody takes them. Check 18.46 fails on v18.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
