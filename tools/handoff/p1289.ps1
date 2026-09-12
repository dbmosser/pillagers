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

# FINDING 9 OF THE 2026-09-11 AUDIT, and it is the raid twin of the v12.11 fix on
# the Undercroft floor. HIS 2026-09-03 ANSWER: CLOSE and ESC on every menu.
#
# WHAT HAPPENS. Mid-raid he presses TAB to look in the backpack, or M for the map,
# then presses ESC to back out of it, which is what every other window in this game
# has taught him. The pause box rises OVER the open panel and the raid freezes. A
# second ESC closes the pause box and the backpack is still sitting there
# underneath; only TAB, I or M will actually shut it. ESC closed the wrong window
# twice and the panel he was looking at neither time. And while the box was up the
# v12.22 lockout blocked TAB, I and M as well, so the one key that would have shut
# the panel was the one key he could not use.
#
# IT IS ALREADY INCONSISTENT INSIDE ONE RAID. ESC does close the emote bar and it
# does close the Peddler stall, because both are handled above this line. The same
# key answered two in-raid panels and paused over the other two.
#
# THE MAP IS IN FRONT OF THE BACKPACK, because drawMapOverlay runs after drawBag,
# so one press takes the map and the next takes the bag. The pause box is in front
# of both, so a box already up still gets the key first: that is what pauseOpen is
# doing in the guard, and without it ESC would shut the panel behind the box.
SubRx @'
  if((code==='Escape'||code==='KeyP')&&G&&!G.over)
    togglePauseBox(!document.getElementById('pausebox').classList.contains('on'));
'@ @'
  // v12.89, audit finding 9: ESC BELONGS TO WHATEVER IS IN FRONT, which in a raid
  // is the map, then the backpack, then the pause box behind neither. A held drag
  // goes with the bag, the way the focus-loss rescue already drops it.
  if(code==='Escape'&&G&&!G.over&&!pauseOpen&&(G.mapOpen||G.bagOpen)&&!repeat){
    if(ev) ev.preventDefault();
    if(G.mapOpen) G.mapOpen=false;
    else { G.bagOpen=false; G.drag=null; }
    return;
  }
  if((code==='Escape'||code==='KeyP')&&G&&!G.over)
    togglePauseBox(!document.getElementById('pausebox').classList.contains('on'));
'@

# NEW IN.
SubRx @'
  'A FRIEND YOU IMPORT CARRIES THE GUN THEY ACTUALLY CARRIED.
'@ @'
  'ESC CLOSES THE BACKPACK AND THE MAP IN A RAID. It raised the pause box over whatever you had open instead, and a second press closed the box and left the panel sitting there, so ESC shut the wrong window twice. The map is in front of the backpack, and the pause box is in front of both.',
  'A FRIEND YOU IMPORT CARRIES THE GUN THEY ACTUALLY CARRIED.
'@

# STAMPS.
SubRx @'
var VER='12.88';
'@ @'
var VER='12.89';
'@
SubRx @'
var WHATSNEW_VER='12.88';
'@ @'
var WHATSNEW_VER='12.89';
'@
$cnt=([regex]::Matches($s,"now:'v12\.88:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.88 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.88:[^']*'",{ param($m) "now:'v12.89: finding 9 of the 2026-09-11 audit, and the raid twin of the v12.11 fix on the Undercroft floor; his 2026-09-03 answer is CLOSE and ESC on every menu. Mid-raid he presses TAB to look in the backpack, or M for the map, then presses ESC to back out of it, which is what every other window in this game has taught him, and the pause box rises OVER the open panel and the raid freezes; a second ESC closes the box and the backpack is still sitting there underneath, and only TAB, I or M will actually shut it, so ESC closed the wrong window twice and the panel he was looking at neither time. Worse, while the box was up the v12.22 lockout blocked TAB, I and M as well, so the one key that would have shut the panel was the one key he could not use. It was already inconsistent inside one raid: ESC does close the emote bar and the Peddler stall, because both are handled above that line, so the same key answered two in-raid panels and paused over the other two. The map is in front of the backpack, because drawMapOverlay runs after drawBag, so one press takes the map and the next takes the bag; the pause box is in front of both, which is what pauseOpen is doing in the guard, because without it ESC would shut the panel behind the box. A held drag goes with the bag, the way the focus-loss rescue already drops it. Check 12.89 deploys, opens the backpack and presses the real key, requiring the backpack shut and the box down, does the same for the map, requires one press each when both are open with the map going first, and controls that ESC with nothing open still raises the box and that ESC with the box up closes the box and not the panel behind it; fails on v12.88 where the first press raises the box over the panel.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
