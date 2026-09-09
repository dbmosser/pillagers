$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The 1247 slot changed hands, so the file after it quotes a corpus header and a
# WHATSNEW line that no longer exist. Both are re-pointed at what the new 1247
# actually writes.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false

$f47 = [IO.File]::ReadAllText($H + 'f1247.ps1')
$m = [regex]::Matches($f47, "(?m)^  \{v:'12\.47',what:'[^\r\n]*$")
if ($m.Count -ne 1) { throw "f1247 has $($m.Count) headers for 12.47, wanted 1" }
$hdr = $m[0].Value
if ($hdr -notmatch 'raised deck edge') { throw 'f1247 header is not the new build' }

$p47 = [IO.File]::ReadAllText($H + 'p1247.ps1')
$w = [regex]::Matches($p47, "(?m)^  'THE EDGE OF A RAISED DECK IS WHERE IT LOOKS[^\r\n]*$")
if ($w.Count -ne 1) { throw "p1247 has $($w.Count) copies of its WHATSNEW line, wanted 1" }
$wn = $w[0].Value

$f48 = [IO.File]::ReadAllText($H + 'f1248.ps1')
$old = [regex]::Matches($f48, "(?m)^  \{v:'12\.47',what:'[^\r\n]*$")
if ($old.Count -ne 2) { throw "f1248 has $($old.Count) copies of the old anchor, wanted 2" }
if ($old[0].Value -notmatch 'downed') { throw 'f1248 anchor is not the downed screen header, so this has already run' }
$f48 = [regex]::Replace($f48, "(?m)^  \{v:'12\.47',what:'[^\r\n]*$", { param($x) $hdr })
[IO.File]::WriteAllText($H + 'f1248.ps1', $f48, $enc)

$p48 = [IO.File]::ReadAllText($H + 'p1248.ps1')
$oldw = [regex]::Matches($p48, "(?m)^  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER[^\r\n]*$")
if ($oldw.Count -ne 2) { throw "p1248 has $($oldw.Count) copies of the old WHATSNEW anchor, wanted 2" }
$p48 = [regex]::Replace($p48, "(?m)^  'THE DOWNED SCREEN STOPS OFFERING A SURRENDER[^\r\n]*$", { param($x) $wn })
[IO.File]::WriteAllText($H + 'p1248.ps1', $p48, $enc)
Write-Output 're-pointed: f1248 and p1248 now quote the new 12.47'
