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
// v28.xx (cw-cx-spawnloot), his answer g-43 (2026-10-25): "Yes, loot in sight". Both windows build these boxes on side stream 80.
function spawnLootSight(g){
  var m=g&&g.map, made=0;
  if(!m||!m.spawns||!Array.isArray(g.containers)) return 0;
  sideStream(g.seed,80,function(){
    for(var i=0;i<m.spawns.length;i++){
      var s=m.spawns[i], found=false, c, j;
      for(j=0;j<g.containers.length;j++){
        c=g.containers[j];
        if(!c||c.opened||c.dropped||c.cache||c.strong||c.type==='cache'||c.type==='vault'||c.inLocked!=null) continue;
        if(Math.hypot(c.x-s.x,c.y-s.y)<=340&&losClear(s.x,s.y,c.x,c.y,m.segs)){ found=true; break; }
      }
      if(found) continue;
      for(j=0;j<24;j++){
        var a=rr()*Math.PI*2, r=140+rr()*180, x=s.x+Math.cos(a)*r, y=s.y+Math.sin(a)*r;
        if(!spotFree(m,x,y,20)||!navReachable(m,x,y)||shutRoomAt(m,x,y)||!losClear(s.x,s.y,x,y,m.segs)) continue;
        c=mkContainer(x,y,'crate'); c.time=1.0; g.containers.push(c); made++; break;
      }
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
  spawnLootSight(g);   // v28.xx (cw-cx-spawnloot): the career start has ordinary loot in sight, on its own stream.
'@

SubRx @'
  try{ arcadeKeycards(g); }catch(_ak){}   // v23.9x (feat4c): a keycard per vault in a box outside (side stream)
'@ @'
  try{ arcadeKeycards(g); }catch(_ak){}   // v23.9x (feat4c): a keycard per vault in a box outside (side stream)
  spawnLootSight(g);   // v28.xx (cw-cx-spawnloot): the demo uses the same deterministic placement in both windows.
'@

SubRx @'
var VER='37.53';
'@ @'
var VER='37.54';
'@

$pat = "(?m)^  now:'v37\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.54: Career and demo starts reuse a visible ordinary box or try up to 24 clear reachable positions for a one-second crate. Side stream 80 preserves the main stream and gives both windows the same boxes. No markers or extra text. LINKED REVIEW NEEDED: synced (g.containers). Check 37.54 fails on v37.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
