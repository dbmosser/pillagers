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
Not verified: whether a green gun and a blue one are the right two to be
holding on a first raid rather than in reserve, which is a balance question
and his to judge; and the stash screen's own gun cells, which read the same
two fields and were not opened here.
'@ @'
### The harness poisoned itself, and it cost me two full runs

The corpus failed twice on this build and named three different checks. Run
one said v9.25 and v10.50; run two of the same corpus on the same build
passed both of those and said v8.72 instead. Every one of them passed when
run on its own. Three red checks and no agreement between runs is the shape
of a broken ruler, not a broken build, so I stopped and measured the ruler.

Two faults, both mine, both in the harness rather than the game.

The first: the extraction card is not a modal, so showScreen cannot clear
it, and six checks end a raid without closing it afterwards. It then lies on
top of the page for every check that follows. v8.72 drags an item off the
belt into the stash, and with the card up the release lands on the card, so
the item stays where it was and the check reports his old symptom back to
me. Proved by hand rather than by reading: v8.72 failed four times running
with the card up and passed the moment the card was closed, with nothing
else touched. This is the v9.82 lesson in a second place, and this time the
answer is not one more check learning to tidy up. Every check now starts
with the card shut, which is safe because the only two checks that read the
card open it themselves.

The second: neither runner pinned the ruler or cleaned the saved profile
before starting, so the corpus inherited whatever the last hand probe in
that tab had left behind. Run one inherited a deployed raid and a set of
cosmetics from a probe of mine, which is what "the fullbeard paints nothing"
was actually reading. Both runners now pin the display and clean the profile
before the first check.

Not verified: whether a green gun and a blue one are the right two to be
holding on a first raid rather than in reserve, which is a balance question
and his to judge; the stash screen's own gun cells, which read the same two
fields and were not opened here; and whether the six checks that leave the
extraction card up have other victims besides v8.72, since the runner now
clears it and I did not go on to audit each of the six.
'@

SubFile 'C:\claudecode\dark raiders\AUDIT.md' @'
| THE WELCOME PACK GUNS GO INTO HIS HANDS | v10.67 |
'@ @'
| HARNESS, MY ERROR: the corpus named three different checks on one build | v10.67 | the full run failed twice and disagreed with itself: v9.25 and v10.50 on run one, v8.72 on run two, all three green run alone. TWO CAUSES, both mine. The extraction card is not a modal so showScreen cannot clear it, and six checks end a raid without closing it; it then covers the page and v8.72's belt drag releases onto the card, which reads back as his old symptom. Proved by hand: four failures in a row with the card up, PASS the moment it was closed, nothing else touched. And neither runner pinned the display or cleaned the saved profile before starting, so run one inherited a deployed raid and a hand probe's cosmetics, which is what "the fullbeard paints nothing" was reading. FIX: every check starts with the card shut, safe because the only two checks that read it open it themselves, and both runners now call __pinDPR and __cleanProfile first. The v9.82 lesson in a second place |
| THE WELCOME PACK GUNS GO INTO HIS HANDS | v10.67 |
'@

Write-Output "OK, $n edits applied"
