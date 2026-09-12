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

# THE OTHER HALF OF THE v12.58 BUG, and it is the same bug.
#
# v12.58 found that a PINNED weather left this clock expired, so the function ran
# its whole draw loop again on every single frame for the rest of the raid,
# burning thirteen seeded rolls a frame and quietly making two paired runs
# compare two different seeded streams. It fixed the pinned case by giving a
# weather that cannot change zero turns.
#
# The unpinned case is still live one line below. If the twelve-deep guard loop
# never finds a sky different from the one overhead, the line just returns: the
# clock is not put forward and the turns are not spent, so the next frame walks
# straight back in and draws thirteen more. Nothing on screen changes, which is
# exactly what made the first half dangerous.
#
# A FAILED TURN COSTS THE SAME WAIT AS A MADE ONE. The turn is still owed, so
# wxTurnsLeft is deliberately not spent; what changes is that the game waits
# before asking again instead of asking every frame forever.
SubRx @'
  if(nw.id===G.wx.id) return;
'@ @'
  if(nw.id===G.wx.id){
    // v13.12: the unpinned twin of the v12.58 bug. Falling out here without
    // touching the clock meant this whole block ran again on the very next
    // frame, and every frame after it, thirteen seeded draws at a time. The
    // turn is still owed, so the turn count is untouched; the wait is what is
    // reset, so the next attempt is a turn from now rather than a frame from
    // now.
    G.wxAt=rnd(120,220);
    return;
  }
'@

SubRx @'
var VER='13.11';
'@ @'
var VER='13.12';
'@

# DEVNOW is REPLACED, not preceded: two now keys in one object literal would
# leave the stale one winning. p1311 forgot this line entirely and parsecheck,
# which is the only thing guarding it, failed the build. Mine.
$pat = "(?m)^  now:'v13\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.12: the other half of the v12.58 bug, and it is the same bug. v12.58 found that a PINNED weather left the weather clock expired, so the turn block ran its whole draw loop again on every frame for the rest of the raid, burning thirteen seeded rolls a frame and quietly making two paired runs compare two different seeded streams; it fixed the pinned case. The unpinned case was still live one line below: if the twelve-deep guard loop never found a sky different from the one overhead, the line returned without putting the clock forward and without spending the turn, so the next frame walked straight back in and drew thirteen more, forever, with nothing on screen changing, which is exactly what made the first half dangerous. A failed turn now costs the same wait as a made one: the turn is still owed so the turn count is untouched, and what resets is the wait, so the next attempt is a turn away rather than a frame away. Reproduced inside the closure rather than argued from the code, because the picker and the weather table cannot be reached from the page: check 13.12 stubs the picker to keep answering with the sky already overhead, runs the clock, and requires that one expired clock costs one round of draws rather than a round every frame. It counts the draws, so the control is a number and not an opinion; on v13.11 the second and third frames draw another thirteen each. AUDIT status corrected in the same build: the 2026-09-06 in-raid section still listed this as the one P3 left open, and the pinned half of it has been shipped since v12.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
