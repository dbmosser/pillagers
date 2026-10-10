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

# THE LIFT MAPS SHOW THE RINGS WHERE THEY ARE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function extractsOutside(list,builds){
'@ @'
function extractsOutside(list,builds,W,H){
  // v22.16, from the whole-game bug hunt of 2026-10-08 (K27): the world size can be given, so the lift's sector maps can move the
  // rings as the raid does with no raid built. The raid gives none and builds its map with WORLD_W and WORLD_H already set to the
  // sector size, so its rings land where they always did.
  W=W||WORLD_W; H=H||WORLD_H;
'@

SubRx @'
        var nx=clamp(e.x+Math.cos(th)*rad,140,WORLD_W-140);
        var ny=clamp(e.y+Math.sin(th)*rad,140,WORLD_H-140);
'@ @'
        var nx=clamp(e.x+Math.cos(th)*rad,140,W-140);
        var ny=clamp(e.y+Math.sin(th)*rad,140,H-140);
'@

SubRx @'
  if(!c) return 0;
  c.setTransform(1,0,0,1,0,0); c.clearRect(0,0,cv.width,cv.height);
'@ @'
  if(!c) return 0;
  // v22.16, from the whole-game bug hunt of 2026-10-08 (K27): THE RINGS WHERE THE RAID PUTS THEM. The raid moves every extraction
  // ring that touches a building out into the open (extractsOutside), and this map drew them where the map file has them, so ring
  // C on COLD STORAGE sat inside the dock bays and five rings on THE COLD MILE were off, and the zone names kept clear of the wrong
  // spots. The same move is made here from the same buildings and the sector size, with no seeded draw, so the lift map and the
  // raid map agree.
  var EX=(M.extracts&&M.buildings)?extractsOutside(M.extracts,M.buildings,M.w,M.h):(M.extracts||null);
  c.setTransform(1,0,0,1,0,0); c.clearRect(0,0,cv.width,cv.height);
'@

SubRx @'
if(!M.extracts) return false; for(j=0;j<M.extracts.length;j++){ e2=M.extracts[j];
'@ @'
if(!EX) return false; for(j=0;j<EX.length;j++){ e2=EX[j];
'@

SubRx @'
if(M.extracts) for(j=0;j<M.extracts.length;j++){ e2=M.extracts[j];
'@ @'
if(EX) for(j=0;j<EX.length;j++){ e2=EX[j];
'@

SubRx @'
  if(M.extracts) for(i=0;i<M.extracts.length;i++){ e=M.extracts[i]; if(!e) continue;
'@ @'
  if(EX) for(i=0;i<EX.length;i++){ e=EX[i]; if(!e) continue;
'@

SubRx @'
var VER='22.15';
'@ @'
var VER='22.16';
'@

$pat = "(?m)^  now:'v22\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.16: The sector maps at the lift show the extraction rings where they really are in the raid. Check 22.16 fails on v22.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
