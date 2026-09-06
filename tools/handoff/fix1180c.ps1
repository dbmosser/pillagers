$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The DEVNOW sentence for v11.80 (tree and draft): the true reason a death
# never hummed, and the re-asserted cut. Idempotent.
$enc = New-Object Text.UTF8Encoding $false
$old = "A death leaves him downed, so only extractions hummed. Over an ended raid the bed is driven to silence."
$new = "A death ends the raid from the death-beat branch, which never reaches the bed drive, so only extractions hummed. Over an ended raid the bed is driven to silence and the 0.12 s cut is written again last, since two automations at one time resolve to the later one."
foreach ($f in @('C:\claudecode\dark raiders\dark_raiders.html', 'C:\claudecode\dark raiders\tools\handoff\p1180.ps1')) {
  $s = [IO.File]::ReadAllText($f)
  if ($s.IndexOf($new) -ge 0) { Write-Output ($f + ': already repaired'); continue }
  $c = ([regex]::Matches($s, [regex]::Escape($old))).Count
  if ($c -ne 1) { throw ($f + ': anchor matched ' + $c + ' times') }
  $s = $s.Replace($old, $new)
  [IO.File]::WriteAllText($f, $s, $enc)
  Write-Output ($f + ': repaired')
}
