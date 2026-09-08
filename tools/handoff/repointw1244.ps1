$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The WHATSNEW line p1244 inserts after belonged to the draft that moved to the
# end of the queue, so it is re-pointed at the line the new 1243 actually adds.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
$p43 = [IO.File]::ReadAllText($H + 'p1243.ps1')
$m = [regex]::Matches($p43, "(?m)^  'A NEW CHARACTER KEEPS WHAT THEIR FIRST SESSION EARNED[^\r\n]*$")
if ($m.Count -ne 1) { throw "p1243 has $($m.Count) copies of its WHATSNEW line, wanted 1" }
$new = $m[0].Value
$p44 = [IO.File]::ReadAllText($H + 'p1244.ps1')
$old = [regex]::Matches($p44, "(?m)^  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL[^\r\n]*$")
if ($old.Count -ne 2) { throw "p1244 has $($old.Count) copies of the old anchor, wanted 2" }
$p44 = [regex]::Replace($p44, "(?m)^  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL[^\r\n]*$", { param($x) $new })
[IO.File]::WriteAllText($H + 'p1244.ps1', $p44, $enc)
Write-Output 're-pointed: p1244 now inserts after the new 12.43 line, both copies'
