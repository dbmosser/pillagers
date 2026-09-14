$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
function navReach(map,fx,fy){
  if(map.reachGrid) return map.reachGrid;
'@ @'
function navReach(map,fx,fy){
  if(map.reachGrid) return map.reachGrid;
  map.reachFrom={x:fx,y:fy};   // v14.34: where the flood started, so an opened door can flood it again from the same drop
'@
SubRx @'
  G.map.navD=carveDoors(_nb2>0?buildNav(walls,_nb2):G.map.nav,G.map.doors,walls,_nb2);
  refreshVseg();
'@ @'
  G.map.navD=carveDoors(_nb2>0?buildNav(walls,_nb2):G.map.nav,G.map.doors,walls,_nb2);
  // v14.34, weather audit finding 4: AN OPENED DOOR OR A DESTROYED WALL OPENS THE PLACEMENT GRIDS TOO. This rebuild made
  // the segments, the grids and the nav again but kept the free-spot wall grid, which passes its identity test because the
  // walls array is spliced in place, and the reachable-area flood, which is cached once at raid build. So a removed wall
  // still ruled spots out, and an opened room still read unreachable, so nothing found mid-raid could land in it. Both are
  // rebuilt from the new walls; the flood starts from the same drop and draws no random number.
  G.map._fsGrid=null;
  if(G.map.reachGrid&&G.map.reachFrom){ G.map.reachGrid=null; navReach(G.map,G.map.reachFrom.x,G.map.reachFrom.y); }
  refreshVseg();
'@
SubRx @'
var VER='14.33';
'@ @'
var VER='14.34';
'@

$pat = "(?m)^  now:'v14\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.34: AN OPENED DOOR OR A DESTROYED WALL OPENS THE PLACEMENT GRIDS TOO. The geometry rebuild after a door or wall kept the cached reachable-area flood and the free-spot wall grid, so an opened room still read unreachable and a removed wall still ruled spots out for anything placed mid-raid. The rebuild now clears the wall grid and floods the reachable area again from the same drop. Check 14.34 removes every wall of a live raid and rebuilds; it fails on v14.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
