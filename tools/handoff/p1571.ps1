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
    var el=q[i],cs=getComputedStyle(el);
    if(cs.display==='none'||cs.visibility==='hidden'||el.disabled) continue;
'@ @'
    var el=q[i],cs=getComputedStyle(el);
    // v15.71, grid audit finding: WITH THE FREEBIE KIT TAKEN, A CONTROLLER CANNOT PACK OR UNPACK IN THE GREYED OUT STASH AND
    // BACKPACK. TAKE THE FREEBIE KIT greys the stash, the backpack and the tactical belt out on the Stash screen and on the
    // ascent check (#hub.freekit .hubgrid and #stagemodal.freekit .hubgrid, pointer-events:none, v6.44), so the mouse cannot
    // touch them, but this list read only display, visibility and disabled. The D-pad walked into the greyed out cells, and A,
    // a script click that pointer-events does not stop, packed one (the v14.74 detail-0 click on a stash cell) or unpacked
    // one: the dimmed backpack and LOADOUT showed it going up, while commitKit empties P.kit for the freebie kit and USE MY OWN
    // GEAR drops it. A control the mouse cannot reach is now out of reach of the pad too. pointer-events is inherited and
    // nothing in the file sets it back to auto, so only the greyed out panels leave the list: on the Stash screen the pad keeps
    // CLOSE and USE MY OWN GEAR, on the ascent check the freebie button, ASCEND and CLOSE. No number and no seeded draw moved.
    if(cs.display==='none'||cs.visibility==='hidden'||cs.pointerEvents==='none'||el.disabled) continue;   // a panel greyed out for the mouse is greyed out for the pad
'@
SubRx @'
var VER='15.70';
'@ @'
var VER='15.71';
'@

$pat = "(?m)^  now:'v15\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.71: WITH THE FREEBIE KIT TAKEN, A CONTROLLER CANNOT PACK OR UNPACK IN THE GREYED OUT STASH AND BACKPACK. With the freebie kit taken the stash, the backpack and the tactical belt grey out and the mouse cannot touch them, but a controller could still walk into them and press A, which packed or unpacked items the freebie kit then threw away. The controller highlight now skips whatever the mouse cannot touch, so only the freebie button, CLOSE and, on the ascent check, ASCEND are in reach. Check 15.71 takes the freebie kit with a faked controller on the Stash screen and tries to reach the Medkit in the stash; it fails on v15.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
