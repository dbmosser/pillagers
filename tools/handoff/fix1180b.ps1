$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# v11.80 delta, from the 2026-09-06 read-only review, applied to the tree
# (p1180 is already in) AND mirrored into the p1180 draft for the record.
# (1) tickAmbience's setTargetAtTime at the same currentTime supersedes
#     ambienceOff's, so the zeroed drive replaced the 0.12 s cut with 0.45 s
#     (bed), 1.2 s (weather) and 0.6 s (dread) ramps: re-assert the cut last.
# (2) The stated reason a death never hummed was false: killPlayer clears
#     p.downed and a live death ends the raid from the death-beat branch, which
#     never reaches the bed drive. The comment and DEVNOW say the true thing.
# Line breaks match as \r?\n (the game is CRLF with LF blocks inside).
$enc = New-Object Text.UTF8Encoding $false
function RepRx([string]$path, [string]$old, [string]$new, [int]$n) {
  $s = [IO.File]::ReadAllText($path)
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($path + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($path + ': repaired')
}
$oldComment = @'
      // v11.80, HIS NOTE: the extraction hold ends the raid inside updatePlayer
      // above, and this frame runs on to here after endRaid's cut. Not downed
      // after an extraction, so this wrote the bed back up to its floor in the
      // same frame, and the level held on the Undercroft floor for as long as
      // the page was open. Over an ended raid the bed is driven to silence.
      tickAmbience(dt,G.over?0:th,!pp.downed&&!G.over,G.over?0:wdread);
'@
$newComment = @'
      // v11.80, HIS NOTE: the extraction hold ends the raid inside updatePlayer
      // above, and this frame runs on to here after endRaid's cut, so this wrote
      // the bed back up to its floor in the same frame, and the level held on the
      // Undercroft floor for as long as the page was open. A death never did:
      // it ends the raid from the death-beat branch, which never reaches here.
      // Over an ended raid the bed is driven to silence, and the cut is written
      // again LAST, because two automations at one currentTime resolve to the
      // later one and this drive's ramps are four to ten times slower than it.
      tickAmbience(dt,G.over?0:th,!pp.downed&&!G.over,G.over?0:wdread);
      if(G.over){ try{ ambienceOff(); }catch(_a2){} }
'@
$oldDev = "A death leaves him downed, so only extractions hummed. Over the card the bed is driven to silence."
$newDev = "A death ends the raid from the death-beat branch, which never reaches the bed drive, so only extractions hummed. Over an ended raid the bed is driven to silence and the 0.12 s cut is written again last, since two automations at one time resolve to the later one."
# THE TREE.
RepRx 'C:\claudecode\dark raiders\dark_raiders.html' $oldComment $newComment 1
RepRx 'C:\claudecode\dark raiders\dark_raiders.html' $oldDev $newDev 1
# THE DRAFT, for the record.
RepRx 'C:\claudecode\dark raiders\tools\handoff\p1180.ps1' $oldComment $newComment 1
RepRx 'C:\claudecode\dark raiders\tools\handoff\p1180.ps1' $oldDev $newDev 1
RepRx 'C:\claudecode\dark raiders\tools\handoff\p1180.ps1' @'
# endRaid. A death
# leaves him downed, alive reads false, and the same order writes 0, which is
# why only a completed run hummed.
'@ @'
# endRaid. A death
# ends the raid from the death-beat branch, which never reaches this line,
# which is why only a completed run hummed.
'@ 1
