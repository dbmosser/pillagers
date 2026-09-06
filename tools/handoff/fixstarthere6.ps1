$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: 1207 joins the current queue after the polish builds. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = '- **1207 THE SECOND DOWN TELLS THE TRUTH**'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: already current'; exit 0 }
$old = '- **NOT DRAFTED, from the same audits, in value order:**'
$i = $s.IndexOf($old)
if ($i -lt 0) { throw 'not-drafted bullet not found' }
$add = @(
  '- **1207 THE SECOND DOWN TELLS THE TRUTH** (first-ten-minutes audit, verified 2026-09-06 12:50: the down branch reads only hp, so a second hit to zero downs him with the revive spent and the toast still says F gets him up). Drafted; dry-run it with the rest (dry.ps1 from the tree VER+1 to 1207).',
  ''
) -join "`n"
$s = $s.Substring(0, $i) + $add + $s.Substring($i)
$s = $s.Replace('the DOWN toast says F gets you up on the second down when it cannot; ', '')
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: 1207 queued'
