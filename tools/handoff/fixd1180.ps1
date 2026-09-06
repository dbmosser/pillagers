$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The v11.80 DESIGN entry (already in the tree) and d1180.txt stated a false
# reason a death never hummed. The true one: a death ends the raid from the
# death-beat branch, which never reaches the bed drive. Also records the
# re-asserted cut the review found.
$enc = New-Object Text.UTF8Encoding $false
foreach ($f in @('C:\claudecode\dark raiders\DESIGN.md', 'C:\claudecode\dark raiders\tools\handoff\d1180.txt')) {
  $s = [IO.File]::ReadAllText($f)
  $nl = if ($s.IndexOf("`r`n") -ge 0) { "`r`n" } else { "`n" }
  $old1 = ('on to the bed''s drive line with "alive" meaning "not downed". After an' + $nl +
    'EXTRACTION he is not downed, so in the very frame the raid ended, after the' + $nl +
    'cut, the bed was written back up to its floor of 0.16; no later frame drives' + $nl +
    'it, and it held that level on the Undercroft floor for as long as the page' + $nl +
    'was open. A death leaves him downed, so the same order writes 0. That is why' + $nl +
    'it hummed after a completed run and never after one he died in.')
  $new1 = ('on to the bed''s drive line, which wrote the bed back up to its floor of 0.16' + $nl +
    'in the very frame the raid ended, after the cut; no later frame drives it, and' + $nl +
    'it held that level on the Undercroft floor for as long as the page was open.' + $nl +
    'A death never did this: a live death sets the death beat and the raid is' + $nl +
    'ended a second or two later from that branch, which never reaches the drive' + $nl +
    'line at all. That is why it hummed after a completed run and never after one' + $nl +
    'he died in. (My first explanation said a death "arrives downed"; the read-only' + $nl +
    'review showed killPlayer clears downed, and the branch is the real reason.)')
  $old2 = ('THE FIX. One line. When the raid is over the bed is driven with threat 0,' + $nl +
    'alive false and dread 0, which is silence, the same thing endRaid asked for' + $nl +
    'one call earlier in the same frame.')
  $new2 = ('THE FIX. Two lines. When the raid is over the bed is driven with threat 0,' + $nl +
    'alive false and dread 0, which is silence, and then endRaid''s cut is written' + $nl +
    'once more, last: two automations scheduled at the same instant resolve to the' + $nl +
    'later one, and the drive''s ramps are four to ten times slower than the cut,' + $nl +
    'so without that second write the zeroed drive would have slowed the fade' + $nl +
    'from under half a second to over one (the review caught this too).')
  $old3 = ('the other paths that end a raid from inside the update' + $nl +
    '(a death inside damagePlayer arrives downed and already wrote 0).')
  $new3 = ('the other paths that end a raid, which never reach the' + $nl +
    'drive line (the death beat, the clock, the abandon).')
  foreach ($pair in @(@($old1, $new1), @($old2, $new2), @($old3, $new3))) {
    $c = ([regex]::Matches($s, [regex]::Escape($pair[0]))).Count
    if ($c -ne 1) { throw ('anchor matched ' + $c + ' times in ' + $f + ': ' + $pair[0].Substring(0, 50)) }
    $s = $s.Replace($pair[0], $pair[1])
  }
  [IO.File]::WriteAllText($f, $s, $enc)
  Write-Output ('amended: ' + $f)
}
