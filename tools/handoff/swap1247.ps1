$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# 2026-09-08. HIS LIVE REPORT: he gets stuck in the horizontal wall of the long
# thin building, with graphic and position glitches, always in the same place.
# That is the deck kerbs painting a building-wall body over the deck he is
# standing on, and it jumps the queue. The draft already in the 1247 slot (the
# downed screen) moves to the END as 1279, the same trade as the 1243 swap: two
# re-pointings instead of a hundred and sixty file edits.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false

if (-not (Test-Path ($H + 'p1247.ps1'))) { throw 'p1247 is missing' }
if (Test-Path ($H + 'p1279.ps1')) { throw 'p1279 exists: this swap has already run' }
if ((Get-Content ($H + 'd1247.txt') -TotalCount 1) -notmatch 'SURRENDER') { throw 'd1247 is not the downed screen draft' }
if (-not (Test-Path ($H + 'f1278.ps1'))) { throw 'f1278 is missing, so the new anchor cannot be read' }
foreach ($f in @('p1247.ps1','f1247.ps1','d1247.txt','a1247.txt','cm1247.txt')) {
  if (-not (Test-Path ($H + $f))) { throw "$f missing" }
}

# THE TRUE ANCHORS from the build that will now sit before the moved one.
$f78 = [IO.File]::ReadAllText($H + 'f1278.ps1')
$m78 = [regex]::Matches($f78, "(?m)^  \{v:'12\.78',what:'[^\r\n]*$")
if ($m78.Count -ne 1) { throw "f1278 has $($m78.Count) headers for 12.78, wanted 1" }
$hdr78 = $m78[0].Value
$p78 = [IO.File]::ReadAllText($H + 'p1278.ps1')
$w78 = [regex]::Matches($p78, "(?m)^  'THE PRICE OF WALKING OUT[^\r\n]*$")
if ($w78.Count -ne 1) { throw "p1278 has $($w78.Count) copies of its WHATSNEW line, wanted 1" }
$wn78 = $w78[0].Value

$moved = 0
foreach ($pair in @(@('p1247.ps1','p1279.ps1'), @('f1247.ps1','f1279.ps1'), @('d1247.txt','d1279.txt'), @('a1247.txt','a1279.txt'), @('cm1247.txt','cm1279.txt'))) {
  $src = [IO.File]::ReadAllText($H + $pair[0])
  # The dot is escaped in the DEVNOW regexes and bare everywhere else.
  $src = [regex]::Replace($src, '12(\\?\.)47(?![0-9])', '12${1}79')
  $src = [regex]::Replace($src, '12(\\?\.)46(?![0-9])', '12${1}78')
  [IO.File]::WriteAllText($H + $pair[1], $src, $enc)
  Remove-Item ($H + $pair[0])
  $moved++
}
if ($moved -ne 5) { throw "moved $moved files, wanted 5" }

# RE-POINT ONE: the corpus header the f-file quotes carries the PREVIOUS build's
# own sentence, so relabelling produced 12.78 wearing 12.46's words.
$f = [IO.File]::ReadAllText($H + 'f1279.ps1')
$bad = [regex]::Matches($f, "(?m)^  \{v:'12\.78',what:'[^\r\n]*$")
if ($bad.Count -ne 2) { throw "f1279 has $($bad.Count) headers to re-point, wanted 2" }
$f = [regex]::Replace($f, "(?m)^  \{v:'12\.78',what:'[^\r\n]*$", { param($m) $hdr78 })
[IO.File]::WriteAllText($H + 'f1279.ps1', $f, $enc)

# RE-POINT TWO: the WHATSNEW line the p-file inserts after is also the previous
# build's own words and carries no number to relabel.
$p = [IO.File]::ReadAllText($H + 'p1279.ps1')
$bw = [regex]::Matches($p, "(?m)^  'AUTO-JOG STOPS WHEN YOU GO DOWN[^\r\n]*$")
if ($bw.Count -ne 2) { throw "p1279 has $($bw.Count) copies of the old WHATSNEW anchor, wanted 2" }
$p = [regex]::Replace($p, "(?m)^  'AUTO-JOG STOPS WHEN YOU GO DOWN[^\r\n]*$", { param($m) $wn78 })
[IO.File]::WriteAllText($H + 'p1279.ps1', $p, $enc)

Write-Output 'swapped: 1247 (the downed screen) is now 1279 at v12.79, anchored on v12.78; the 1247 slot is free'
