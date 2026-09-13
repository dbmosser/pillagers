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

# A CONTROLLER COULD NOT SURRENDER.
#
# Found by the 2026-09-13 read-only hunt, confirmed by two skeptics, reproduced live on
# v13.34: downed with the self-revive spent (downed, revived and downT staged), a faked
# pad holding B for 130 frames set keys.Space on none of them and the surrender bar
# stayed at 0; keyboard Space held the same 130 frames raised it to 1.49 of 1.5.
#
# The downed screen and the DOWN line both say hold B to surrender. Pad B is a PADTAP:
# the tap loop in pollPad raises Space through raidKey and clears it in the same poll,
# and giveUpTick reads keys.Space every frame, so it never saw B held.
#
# FIX: one line after the tap loop holds Space through padHold while B is down and the
# player is downed, and lets go of it the way the other held buttons are let go. After
# the tap loop on purpose, so the tap cannot clear it. A downed player cannot roll, so
# the tap still does nothing there, and giveUpTick keeps every rule about when the hold
# counts: not while a self-revive is left, not inside a landed extraction. No words,
# labels or numbers change.
SubRx @'
  // v6.79, his note: the bumpers walk the belt. Wrapping at both ends, because a
'@ @'
  // v13.37, audit: B IS A TAP, BUT THE SURRENDER IS A HOLD. The downed screen and the
  // DOWN line both name B for the surrender, and B reaches the game as a Space tap
  // that the loop above clears inside the same poll, so giveUpTick, which reads the
  // key every frame, never saw it held: the bar never filled and a controller player
  // with the revive spent could only bleed out. While he is down B is also HELD,
  // through padHold, so it is let go the same way the other held buttons are. After
  // the tap loop on purpose, so the tap cannot clear it. A downed man cannot roll, so
  // the tap still does nothing there, and giveUpTick keeps every rule about when the
  // hold counts.
  padHold('Space',pressed(1)&&!G.over&&!!(G.player&&G.player.downed));
  // v6.79, his note: the bumpers walk the belt. Wrapping at both ends, because a
'@

SubRx @'
var VER='13.36';
'@ @'
var VER='13.37';
'@

$pat = "(?m)^  now:'v13\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.37: A CONTROLLER COULD NOT SURRENDER. Found by a read-only hunt, confirmed by two skeptics and reproduced live on v13.34: downed with the self-revive spent, a faked controller holding B for 130 frames never registered the key and the surrender bar stayed empty, while the keyboard space bar held as long filled it to 1.49 of 1.5 seconds. The downed screen and the DOWN line both say hold B to surrender. B reaches the game as a tap that is raised and cleared in the same poll, and the surrender reads the key every frame, so it never saw B held. One line now holds the key while B is down and the player is downed, and lets it go the way the other held buttons are let go; a downed player cannot roll, so the tap still does nothing there, and every rule about when the hold counts is unchanged. Check 13.37 fakes a controller, confirms a tap of B still rolls a standing player and the space bar can surrender, then requires an unspent revive to refuse, a one second hold not to surrender, letting go to release the key, and a held B for 2.5 seconds with the revive spent to surrender under the machine that put him down; it fails on v13.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
