$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The p1180 header sentence, with the exact lines this time. Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\p1180.ps1'
$s = [IO.File]::ReadAllText($f)
$old = @(
  '# held on the Undercroft floor for as long as the page was open. A death',
  '# leaves him downed, alive reads false, and the same order writes 0, which is',
  '# why only a completed run hummed. Over an ended raid the bed is now driven to',
  '# silence, which is what endRaid asked for one call earlier.') -join "`n"
$new = @(
  '# held on the Undercroft floor for as long as the page was open. A death',
  '# never did this: it ends the raid from the death-beat branch, which never',
  '# reaches that line, which is why only a completed run hummed. Over an ended',
  '# raid the bed is driven to silence, and the 0.12 s cut is written again last',
  '# (two automations at one currentTime resolve to the later one).') -join "`n"
if ($s.IndexOf('# never did this: it ends the raid from the death-beat branch') -ge 0) { Write-Output 'p1180 header: already repaired'; exit 0 }
$pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_) }) -join "\r?\n"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw ('anchor matched ' + $c + ' times') }
$s = [regex]::Replace($s, $pat, { param($m) $new })
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'p1180 header: repaired'
