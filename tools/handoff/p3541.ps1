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

# SOLO PINGS IN ALL THREE VIEWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // With a party it marks what is under the cursor for them (netPingMake, the N key, and on the open map your marker). Alone there is nobody to
  // ping and it does nothing. It latches no key.
'@ @'
  // v28.xx (cw-cx-solopings), his pick 46: "middle mouse pinging doesn't even work in 1 player". Use the same ping alone and in a party.
  // On the open map it still places your waypoint. It latches no key.
'@

SubRx @'
    if(NET.on) netPingMake();
'@ @'
    netPingMake();
'@

SubRx @'
  if(code==='KeyN'&&G&&!G.over&&!repeat&&NET.on) netPingMake();   // v16.43: ping for the party
'@ @'
  if(code==='KeyN'&&G&&!G.over&&!repeat) netPingMake();   // v28.xx (cw-cx-solopings): N also works alone.
'@

SubRx @'
  // v16.46, HIS ORDER: PING ON D-PAD UP. A tap pings for the party (in solo it opens and shuts the map as before); a hold of 0.4 s
'@ @'
  // v28.xx (cw-cx-solopings), his pick 46: a tap pings alone or in a party; a hold of 0.4 s
'@

SubRx @'
      if(G.mapOpen&&G.mapCur) netWpFromMap(); else if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;   // v16.47: with the map cursor moved, a tap places the marker
'@ @'
      if(G.mapOpen&&G.mapCur) netWpFromMap(); else if(G.mapOpen) G.mapOpen=false; else netPingMake();   // v28.xx (cw-cx-solopings): solo uses the same tap; hold still toggles the map.
'@

SubRx @'
  if(typeof G==='undefined'||!G||G.over||!G.player||!NET.on||!NET.upSeed) return null;
'@ @'
  // v28.xx (cw-cx-solopings): only a party needs a shared raid seed. No ping behind a panel, while down, or on the Undercroft floor.
  if(typeof G==='undefined'||!G||G.over||!G.player||G.hubFloor||G.sim||G.paused||G.bagOpen||G.trade||G.forgeUI||G.player.downed||G.player.dying||(NET.on&&!NET.upSeed)) return null;
'@

SubRx @'
    if(NET.pingLast&&!NET.pingLast.dg){ NET.pingLast.dg=1; netBroadcast(NET.pingLast); netPingPush(NET.seat,NET.pingLast); }
'@ @'
    if(NET.pingLast&&!NET.pingLast.dg){ NET.pingLast.dg=1; if(NET.on) netBroadcast(NET.pingLast); netPingPush(NET.seat,NET.pingLast,NET.pingTarget); }
'@

SubRx @'
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(!e.nid||e.hp<=0||e.merc) continue; d=dist(e,w); if(d<bd){ bd=d; hit=e; } }
'@ @'
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if((NET.on&&!e.nid)||e.hp<=0||e.merc) continue; d=dist(e,w); if(d<bd){ bd=d; hit=e; } }
'@

SubRx @'
  netBroadcast(m);
  NET.pingLast=m;
  netPingPush(NET.seat,m);
'@ @'
  if(NET.on) netBroadcast(m);
  NET.pingLast=m;
  NET.pingTarget=NET.on?null:hit;   // v28.xx (cw-cx-solopings): solo targets have no network id; keep the local body out of the wire word.
  netPingPush(NET.seat,m,NET.pingTarget);
'@

SubRx @'
function netPingPush(s,o){
'@ @'
function netPingPush(s,o,target){
'@

SubRx @'
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,pl:o.pl?1:0,at:Date.now()});
'@ @'
  NET.pings.push({s:s,x:o.x,y:o.y,w:o.w||'',id:o.id,dg:o.dg?1:0,pl:o.pl?1:0,at:Date.now(),target:target||null});
'@

SubRx @'
function netPingDraw(){
'@ @'
// v28.xx (cw-cx-solopings): update before each drawing pass, including the paused map, so all three views follow and expire together.
function netPingUpdate(){
  var i, p, e, now=Date.now();
  if(!NET.pings) return 0;
  for(i=NET.pings.length-1;i>=0;i--){
    p=NET.pings[i];
    if((now-p.at)/1000>NET_PING_T){ NET.pings.splice(i,1); continue; }
    e=p.target||(p.id&&NET.entMap?NET.entMap[p.id]:null);
    if(e&&e.hp>0&&G&&G.ents.indexOf(e)>=0){ p.x=e.x; p.y=e.y; }
  }
  return NET.pings.length;
}
function netPingDraw(){
  netPingUpdate();
'@

SubRx @'
    if((now-p.at)/1000>NET_PING_T){ NET.pings.splice(i,1); continue; }
    e=(p.id&&NET.entMap)?NET.entMap[p.id]:null;
    if(e&&e.hp>0){ p.x=e.x; p.y=e.y; }   // a pinged enemy is followed while it lives
'@ @'

'@

SubRx @'
  try{ if(NET.on) netPingDraw(); }catch(_npd){}   // v16.43: the party pings
'@ @'
  try{ netPingDraw(); }catch(_npd){}   // v28.xx (cw-cx-solopings): your ping is visible in solo too.
'@

SubRx @'
  // the party's marks and pings, then your waypoint
  if(typeof NET==='object'&&NET){
'@ @'
  // v28.xx (cw-cx-solopings): the same live pings in solo and in a party, then your waypoint.
  if(typeof NET==='object'&&NET){
    netPingUpdate();
'@

SubRx @'
function netWpMapDraw(ox,oy,sc){
'@ @'
function netWpMapDraw(ox,oy,sc){
  netPingUpdate();   // v28.xx (cw-cx-solopings): opening the map must not freeze a target or extend its ping.
'@

SubRx @'
  try{ if(NET.on) netWpMapDraw(ox,oy,sc); }catch(_wm){}   // v16.46: the party's map markers on the map
'@ @'
  try{ netWpMapDraw(ox,oy,sc); }catch(_wm){}   // v28.xx (cw-cx-solopings): solo pings on the full map.
'@

SubRx @'
  if(NET.on&&NET.role==='host'&&!G.sim) netUpAnnounce(G);   // v15.79: the party is told to ascend into this world (the net section)
'@ @'
  NET.wps={}; NET.pings=[]; NET.pingAt=0; NET.pingLast=null; NET.pingTarget=null;   // v28.xx (cw-cx-solopings): no marks or double-tap state from the previous raid.
  if(NET.on&&NET.role==='host'&&!G.sim) netUpAnnounce(G);   // v15.79: the party is told to ascend into this world (the net section)
'@

SubRx @'
var VER='35.40';
'@ @'
var VER='35.41';
'@

$pat = "(?m)^  now:'v35\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.41: Solo mouse, N and pad pings show in the world, minimap and full map and follow an enemy for 10 seconds. Check 35.41 fails on v35.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
