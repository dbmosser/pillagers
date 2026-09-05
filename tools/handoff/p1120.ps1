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

# THE FOLLOWER AND seekPoint DISAGREED ABOUT ARRIVING, AND A BODY STOOD STILL.
# v11.15 made a waypoint count as reached at 10 units, or at 30 when the next
# one can be walked straight to. seekPoint, one call down, treats a target
# inside ONE STEP as already reached and returns without moving. At the live
# frame a step is about 3 units and the two never meet; at the sim's 0.15 second
# step a 150 unit body steps 27, so a waypoint between 10 and 27 units away is
# "not reached" to the follower and "reached" to seekPoint, and the body does
# nothing, forever, with a route in hand. TRACED on seed 9071, COLD STORAGE: the
# bot at 490,1157 with its waypoint 24 units off, moving nothing from 45 to 120
# seconds. The paired run of v11.19 read the cost as timeouts, 5 to 12. A slow
# live frame, 0.1 seconds, steps 18 and can do the same. The waypoint counts as
# reached at one step, whatever the step is, floored at the 10.
SubRx @'
      if(_dwf<10||(_dwf<30&&(CFG.navBody===0||walkClearR(e.x,e.y,e.path[e.pathI+1].x,e.path[e.pathI+1].y,e.r)))) e.pathI++; else break; }
'@ @'
      if(_dwf<Math.max(10,spd*dt*1.2+0.5)||(_dwf<30&&(CFG.navBody===0||walkClearR(e.x,e.y,e.path[e.pathI+1].x,e.path[e.pathI+1].y,e.r)))) e.pathI++; else break; }
'@
SubRx @'
    if(_dw<10||(_dw<30&&(CFG.navBody===0||walkClearR(e.x,e.y,e.path[e.pathI+1].x,e.path[e.pathI+1].y,e.r)))) e.pathI++; else break; }
'@ @'
    // v11.20: and never under one step, because seekPoint calls one step
    // arrived and returns without moving. At the sim's 0.15 second step that
    // is 27 units for a 150 unit body, and a waypoint 24 away deadlocked the
    // two: the bot on seed 9071 stood at 490,1157 from 45 to 120 seconds with
    // a route in hand. A 0.1 second live frame steps 18 and can do the same.
    if(_dw<Math.max(10,spd*dt*1.2+0.5)||(_dw<30&&(CFG.navBody===0||walkClearR(e.x,e.y,e.path[e.pathI+1].x,e.path[e.pathI+1].y,e.r)))) e.pathI++; else break; }
'@

SubRx @'
var VER='11.19';
'@ @'
var VER='11.20';
'@
SubRx @'
var WHATSNEW_VER='11.19';
'@ @'
var WHATSNEW_VER='11.20';
'@
SubRx @'
  'NOTHING IN THE GAME CHANGED IN THIS BUILD. It measures what the last seven did:
'@ @'
  'A MACHINE ON A LONG FRAME NO LONGER FREEZES ON ITS OWN ROUTE. Two parts of the route follower disagreed about when a waypoint counts as reached, and on a slow frame a body could stand still with a route in hand. Found in the test robot, where it cost raids to the clock; fixed for everything that walks a route.',
  'NOTHING IN THE GAME CHANGED IN THIS BUILD. It measures what the last seven did:
'@
SubRx @'
  now:'v11.19: the measurement the last seven builds owed. Sixty seeded robot raids on COLD STORAGE, each run twice, once with every building rule since v11.12 switched off and once with them on, so the extract rate difference of machines that can get out of buildings is a number and not a direction. Nothing in the game changed.',
'@ @'
  now:'v11.20: the route follower and seekPoint disagreed about arriving. A waypoint between 10 units and one step away was not reached to one and already reached to the other, so a body stood still with a route in hand. At the sim step that is 10 to 27 units and it cost the robot raids to the clock; on a slow live frame it is 10 to 18 and can freeze a machine. Traced on seed 9071. A waypoint counts as reached at one step, floored at 10.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
