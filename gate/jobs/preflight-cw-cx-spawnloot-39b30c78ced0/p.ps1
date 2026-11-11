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

# LOOT IN SIGHT AT EVERY START (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeKeycardOut(){
'@ @'
// v28.xx (cw-cx-spawnloot), his g-43 answer: "Yes, loot in sight". The 11-11 amendment permits the fallback bands, never closer than 60.
function spawnLootSight(g){
  var m=g&&g.map, made=0, cs=null, sn=null;
  if(!m||!m.spawns||!Array.isArray(g.containers)) return 0;
  function spawnSightOk(s,x,y){
    return losClear(s.x,s.y,x,y,m.segs)&&spotFree(m,x,y,20)&&navReachable(m,x,y)&&!shutRoomAt(m,x,y);
  }
  function spawnSightRoll(s,lo,hi){
    for(var t=0;t<24;t++){
      var a=rr()*Math.PI*2, r=lo+rr()*(hi-lo), x=s.x+Math.cos(a)*r, y=s.y+Math.sin(a)*r;
      if(spawnSightOk(s,x,y)) return {x:x,y:y};
    }
    return null;
  }
  function spawnSightSweep(s,lo,hi){
    if(!cs){
      cs=[]; sn=[];
      for(var q=0;q<360;q++){ cs[q]=Math.cos(q*Math.PI/180); sn[q]=Math.sin(q*Math.PI/180); }
    }
    for(var r=lo;r<=hi;r++) for(var a=0;a<360;a++){
      var x=s.x+cs[a]*r, y=s.y+sn[a]*r;
      if(spawnSightOk(s,x,y)) return {x:x,y:y};
    }
    return null;
  }
  sideStream(g.seed,80,function(){
    for(var i=0;i<m.spawns.length;i++){
      var s=m.spawns[i], found=false, c, j, d;
      for(j=0;j<g.containers.length;j++){
        c=g.containers[j];
        if(!c||c.opened||c.dropped||c.cache||c.strong||c.type==='cache'||c.type==='vault'||c.inLocked!=null) continue;
        d=Math.hypot(c.x-s.x,c.y-s.y);
        if((d<=340||(c.spawnLootStart===i&&d<=600))&&losClear(s.x,s.y,c.x,c.y,m.segs)){ found=true; break; }
      }
      if(found) continue;
      // v28.xx (cw-cx-spawnloot): exhaust a band before falling back. The sweep uses one-unit radii and one-degree bearings, nearest radius first.
      var p=spawnSightRoll(s,140,320)||spawnSightSweep(s,140,320)
        ||spawnSightRoll(s,60,140)||spawnSightSweep(s,60,140)
        ||spawnSightRoll(s,320,480)||spawnSightSweep(s,320,480)||spawnSightSweep(s,60,600);
      if(!p) continue;
      c=mkContainer(p.x,p.y,'crate'); c.time=1.0; c.spawnLootStart=i; g.containers.push(c); made++;
    }
  });
  return made;
}
function arcadeKeycardOut(){
'@

SubRx @'
  try{ arcadeKeycards(g); }catch(_ck){}   // v24.xx (careervault): a keycard per vault in a box outside (side stream)
'@ @'
  try{ arcadeKeycards(g); }catch(_ck){}   // v24.xx (careervault): a keycard per vault in a box outside (side stream)
  spawnLootSight(g);   // v28.xx (cw-cx-spawnloot): career starts get visible ordinary loot on their own stream.
'@

SubRx @'
  try{ arcadeKeycards(g); }catch(_ak){}   // v23.9x (feat4c): a keycard per vault in a box outside (side stream)
'@ @'
  try{ arcadeKeycards(g); }catch(_ak){}   // v23.9x (feat4c): a keycard per vault in a box outside (side stream)
  spawnLootSight(g);   // v28.xx (cw-cx-spawnloot): both demo windows generate the same boxes.
'@

SubRx @'
var VER='37.67';
'@ @'
var VER='37.68';
'@

$pat = "(?m)^  now:'v37\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.68: Career and demo reuse a visible ordinary box or add one one-second crate. Prefer 140-320, then 60-140, then 320-480, then the nearest sampled legal point within 600; never closer than 60. After 24 seeded tries a deterministic one-unit, one-degree sweep checks the band before falling back. All placement and loot rolls use side stream 80. Map geometry and the main RNG stay unchanged. Strict checks isolate all 144 starts and require 142 in the preferred band; Cold Mile spawn 3 on seeds 39041 and 61261 must use fallback. No career box-count retarget is known; stop and report any old-check conflict without editing the fixture. No markers or player text. LINKED REVIEW NEEDED: synced (g.containers indices, positions and loot). Check 37.68 fails on v37.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
