$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The v11.80 record, from the read-only review of the shipped code: the p1180
# draft's SubRx new-block lacked the shipped second line (the re-asserted
# cut) and its comment; a1180.txt, cm1180.txt and the AUDIT.md row still gave
# the disproven "arrives downed" reason. All brought to what shipped.
# Idempotent; line breaks match \r?\n.
$enc = New-Object Text.UTF8Encoding $false
function L { param([string[]]$lines) return ($lines -join "`n") }
function RepRx([string]$path, [string]$old, [string]$new, [int]$n) {
  $s = [IO.File]::ReadAllText($path)
  if ($s.IndexOf($new) -ge 0 -and $s.IndexOf($old) -lt 0) { Write-Output ($path + ': already repaired'); return }
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($s, $pat)).Count
  if ($c -ne $n) { throw ($path + ': anchor matched ' + $c + ' times, wanted ' + $n + ': ' + $old.Substring(0, [Math]::Min(60, $old.Length))) }
  $s = [regex]::Replace($s, $pat, { param($m) $new })
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($path + ': repaired')
}
$H = 'C:\claudecode\dark raiders\tools\handoff\'
# p1180: the SubRx new-block becomes the block that shipped.
RepRx ($H + 'p1180.ps1') (L @(
  '      // v11.80, HIS NOTE: the extraction hold ends the raid inside updatePlayer',
  "      // above, and this frame runs on to here after endRaid's cut. Not downed",
  '      // after an extraction, so this wrote the bed back up to its floor in the',
  '      // same frame, and the level held on the Undercroft floor for as long as',
  '      // the page was open. Over an ended raid the bed is driven to silence.',
  '      tickAmbience(dt,G.over?0:th,!pp.downed&&!G.over,G.over?0:wdread);')) (L @(
  '      // v11.80, HIS NOTE: the extraction hold ends the raid inside updatePlayer',
  "      // above, and this frame runs on to here after endRaid's cut, so this wrote",
  '      // the bed back up to its floor in the same frame, and the level held on the',
  '      // Undercroft floor for as long as the page was open. A death never did:',
  '      // it ends the raid from the death-beat branch, which never reaches here.',
  '      // Over an ended raid the bed is driven to silence, and the cut is written',
  '      // again LAST, because two automations at one currentTime resolve to the',
  "      // later one and this drive's ramps are four to ten times slower than it.",
  '      tickAmbience(dt,G.over?0:th,!pp.downed&&!G.over,G.over?0:wdread);',
  '      if(G.over){ try{ ambienceOff(); }catch(_a2){} }')) 1
RepRx ($H + 'p1180.ps1') (L @(
  '# endRaid. A death',
  '# leaves him downed, alive reads false, and the same order writes 0, which is',
  '# why only a completed run hummed.')) (L @(
  '# endRaid. A death',
  '# ends the raid from the death-beat branch, which never reaches this line,',
  '# which is why only a completed run hummed.')) 1
# a1180 and the AUDIT row (same sentence), cm1180.
$oldA = 'A death arrives downed and writes 0, so only extractions hummed. Over an ended raid the bed is driven with threat 0, alive false, dread 0.'
$newA = 'A death ends the raid from the death-beat branch, which never reaches the bed drive, so only extractions hummed. Over an ended raid the bed is driven with threat 0, alive false, dread 0, and the 0.12 s cut is written again last.'
RepRx ($H + 'a1180.txt') $oldA $newA 1
RepRx 'C:\claudecode\dark raiders\AUDIT.md' $oldA $newA 1
RepRx ($H + 'cm1180.txt') (L @(
  'meaning not downed, true after an extraction, so the bed was written back',
  'up to its 0.16 floor after the cut and held that level on the Undercroft',
  'floor once the raid was dropped. A death arrives downed and writes 0, so',
  'only completed runs hummed. Over an ended raid the bed is now driven to',
  'silence.')) (L @(
  'meaning not downed, true after an extraction, so the bed was written back',
  'up to its 0.16 floor after the cut and held that level on the Undercroft',
  'floor once the raid was dropped. A death ends the raid from the death-beat',
  'branch, which never reaches the drive, so only completed runs hummed. Over',
  'an ended raid the bed is driven to silence and the cut is written again last.')) 1
