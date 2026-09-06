$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# START-HERE: the leftovers of the draft review wf_cfc891c0-f2e, appended to
# the NOT DRAFTED bullet of the current queue block. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\START-HERE.md'
$s = [IO.File]::ReadAllText($f)
$marker = 'check 11.88 should reset and restore P.hud'
if ($s.IndexOf($marker) -ge 0) { Write-Output 'START-HERE: already current'; exit 0 }
$old = '- **DRY RUN BEFORE SHIPPING 1189:**'
$i = $s.IndexOf($old)
if ($i -lt 0) { throw 'dry-run bullet not found' }
$add = @(
  '- **LEFTOVERS OF THE DRAFT REVIEW wf_cfc891c0-f2e (47 findings; highs and mediums folded in by fixdrafts5.ps1 + fixdup5.ps1):** check 11.88 should reset and restore P.hud (a collapsed CONDITIONS panel on the saved profile reads as a red for the wrong reason; copy the idiom at mkfixture ~3191); the v11.88 patch left the quiet and swift verdict branches unreachable rather than deleting them, and the v9.70 comment under it still cites "nothing killed yet" as a live example (delete both branches and reword the comment in a polish build); check 11.97 has no arm for the named belt heal slot (stage P.hotAssign the way check ~1468 does, then setHot and useHot); the 1188 check spies fillText by hand where __textTrace exists; the queue drafts still use the DEVNOW idiom `now:''v11\.NN:[^'']*''` which cannot carry an apostrophe (never put one in a DEVNOW sentence).',
  ''
) -join "`n"
$s = $s.Substring(0, $i) + $add + $s.Substring($i)
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'START-HERE: leftovers recorded'
