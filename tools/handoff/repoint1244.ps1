$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The 1243 slot changed hands, so the file that comes after it quotes a corpus
# header that no longer exists. Both copies are re-pointed at the header the new
# 1243 actually writes. Nothing else in f1244 moves.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false

$f43 = [IO.File]::ReadAllText($H + 'f1243.ps1')
$m = [regex]::Matches($f43, "(?m)^  \{v:'12\.43',what:'[^\r\n]*$")
if ($m.Count -ne 1) { throw "f1243 has $($m.Count) headers for 12.43, wanted 1" }
$hdr = $m[0].Value
if ($hdr -notmatch 'born already migrated') { throw 'f1243 header is not the new build' }

$f44 = [IO.File]::ReadAllText($H + 'f1244.ps1')
$old = [regex]::Matches($f44, "(?m)^  \{v:'12\.43',what:'[^\r\n]*$")
if ($old.Count -ne 2) { throw "f1244 has $($old.Count) copies of the old anchor, wanted 2" }
if ($old[0].Value -notmatch 'sprint') { throw 'f1244 anchor is not the sprint trail header, so this has already run' }
$f44 = [regex]::Replace($f44, "(?m)^  \{v:'12\.43',what:'[^\r\n]*$", { param($x) $hdr })
[IO.File]::WriteAllText($H + 'f1244.ps1', $f44, $enc)
Write-Output 're-pointed: f1244 now quotes the new 12.43 header, both copies'
