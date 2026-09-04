$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$n = 0
function SubFile([string]$p, [string]$old, [string]$new) {
  $s = [IO.File]::ReadAllText($p)
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times in ${p}: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($p, $s, (New-Object Text.UTF8Encoding $false))
  $script:n++
}

SubFile 'C:\claudecode\dark raiders\DESIGN.md' @'
### Found while driving a first session, not built here
'@ @'
### Two checks that had been green for the wrong reason

The corpus went red on this build naming v10.50 and v9.25. Neither is a
regression: v10.50 fails identically on a v10.67 fixture, run as the first
check on a freshly loaded page. What changed was not the build, it was the
PROFILE. Driving a friend''s first session rewrote the saved profile on this
origin to a young character, and both checks were quietly leaning on an old
one.

COSMETICS ARE EARNED. cosWorn refuses any rack the profile does not own and
falls back to the default without a word, so writing P.cosBeard=''fullbeard''
on a profile with eight extractions paints Clean Shaven, and the check reads
that as "the fullbeard paints nothing". The Full Beard is earned at ten. The
Stubble and the Goatee are gated on raids run, which this profile had, which
is exactly why one of the three beards failed and the other two did not. The
check now sets his own v10.53 unlock-everything flag and puts it back
afterwards, which is what it should have done the day the racks were gated.

AND v9.25 WAS WORSE, because it was green for a reason that had nothing to
do with what it claimed. Its notoriety control read the ABSOLUTE total on the
profile and passed at 1 or more. On a profile carrying 12 that is true before
the check fires a round. Starting it from zero turned it red, so I measured
it rather than believing either side, and found the check had been sitting in
the wrong seat since it was written: a peaceful pillager turns hostile on
PROXIMITY ALONE inside 180 units, and the stand ladder started at 110. Driven
by hand at 110 he turns hostile at frame 4, the round lands later, and the
charge correctly declines because by then he was already fighting. That is
the game being right.

Then the fix for that went red too, and the reason is worth writing down: the
pillager this check picks has a reach of 187 units. He is peaceful only
beyond 180 and can only shoot back inside 187 less a margin, so THERE IS NO
DISTANCE THAT ANSWERS BOTH QUESTIONS. The check now takes two seats. Close,
inside his reach, proves he fights back, which is his report and the thing
v9.25 fixed. Far, outside his temper, proves the charge, measured as a rise
from zero, 0 to 1. Neither assertion is asked to stand in for the other any
more.

### Found while driving a first session, not built here
'@

SubFile 'C:\claudecode\dark raiders\AUDIT.md' @'
| A FOUND GUN TAKES THE EMPTY SLOT, THE OTHER HALF | v10.68 |
'@ @'
| HARNESS, MY ERROR: two checks were leaning on an old profile | v10.68 | the corpus went red naming v10.50 and v9.25, and neither is a regression: v10.50 fails identically on a v10.67 fixture as the first check on a fresh page. What changed was the PROFILE, which driving a friend''s first session rewrote to a young character. COSMETICS ARE EARNED and cosWorn falls back to the default for any rack the profile does not own, so P.cosBeard=''fullbeard'' on a profile with 8 extractions paints Clean Shaven; the Full Beard needs ten, the Stubble and Goatee are gated on runs which it had, which is why one beard of three failed. Fixed with his own v10.53 unlock flag, restored afterwards. v9.25 read notoriety as an ABSOLUTE TOTAL and passed at 1 or more, so a profile carrying 12 made it green before a round was fired. From zero it went red and the cause is older than the check: a peaceful pillager turns hostile on PROXIMITY inside 180 units and the ladder started at 110, so he was fighting before the round landed and the charge correctly declined. Measured by hand: at 110 hostile at frame 4 and no charge, at 190 the charge fires 0 to 1. AND HIS REACH IS 187, so no single distance can prove both that he fights back and that the charge fires. Split into two seats, close for the fight and far for the charge |
| A FOUND GUN TAKES THE EMPTY SLOT, THE OTHER HALF | v10.68 |
'@

Write-Output "OK, $n edits applied"
