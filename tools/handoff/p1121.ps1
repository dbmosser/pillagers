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

# THE STAMPS. Whether this build changes the game is decided by the mile run;
# the game edit, if one is needed, comes as p1121b.
SubRx @'
var VER='11.20';
'@ @'
var VER='11.21';
'@
SubRx @'
var WHATSNEW_VER='11.20';
'@ @'
var WHATSNEW_VER='11.21';
'@
SubRx @'
  'A MACHINE ON A LONG FRAME NO LONGER FREEZES ON ITS OWN ROUTE.
'@ @'
  'THE SECOND MAP MEASURED THE SAME WAY. The test robot ran the same 320 raids on THE COLD MILE with the building rules off and on, so the bigger map has its own number and not the first map borrowed.',
  'A MACHINE ON A LONG FRAME NO LONGER FREEZES ON ITS OWN ROUTE.
'@
SubRx @'
  now:'v11.20: the route follower and seekPoint disagreed about arriving. A waypoint between 10 units and one step away was not reached to one and already reached to the other, so a body stood still with a route in hand. At the sim step that is 10 to 27 units and it cost the robot raids to the clock; on a slow live frame it is 10 to 18 and can freeze a machine. Traced on seed 9071. A waypoint counts as reached at one step, floored at 10.',
'@ @'
  now:'v11.21: THE COLD MILE measured the way COLD STORAGE was at v11.19 and v11.20: 320 paired seeds, the seven building rules off and on, the robot at its pinned greed, with the follower fix in both arms. The mile is where most of the doors, partitions and furniture moved, so it gets its own number.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
