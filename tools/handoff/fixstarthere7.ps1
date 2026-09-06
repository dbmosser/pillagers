$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: 1208 and 1209 join the current queue after 1207. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = '- **1208 THE LIFT FREEBIE KIT CLEARS THE BELT PLAN**'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: already current'; exit 0 }
$old = '- **NOT DRAFTED, from the same audits, in value order:**'
$i = $s.IndexOf($old)
if ($i -lt 0) { throw 'not-drafted bullet not found' }
$add = @(
  '- **1208 THE LIFT FREEBIE KIT CLEARS THE BELT PLAN** (first-ten-minutes audit, verified 2026-09-06 13:20: askKit ASKALT set freeKit and nothing else while the stash button clears P.kit, P.hotAssign, P._gunSlot). Drafted, NOT yet dry-run.',
  '- **1209 ESC CLOSES THE OPEN FLOOR BACKPACK** (same audit, verified: the v8.70 pause branch does not count hubBagOpen and returns before the v8.95 backpack line). Drafted, NOT yet dry-run. Dry-run both with dry.ps1 from the tree VER+1 to 1209.',
  ''
) -join "`n"
$s = $s.Substring(0, $i) + $add + $s.Substring($i)
$s = $s.Replace('the lift FREEBIE KIT button does not clear the belt plan (the stash one does); ESC with the floor backpack open raises the pause box instead of closing the bag; ', '')
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: 1208 and 1209 queued'
