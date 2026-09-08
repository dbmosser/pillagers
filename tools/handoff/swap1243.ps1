$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# 2026-09-08. THE FIRST-HOUR AUDIT FOUND SILENT DATA LOSS ON A BRAND NEW PROFILE
# and it jumps the queue, so it takes the 1243 slot. The draft already there (the
# sprint trail laid while aiming or wading) moves to the END of the queue as 1271,
# because the queue is a chain of anchors and moving one draft to the end costs
# two re-pointings, while shifting all twenty eight up one costs a hundred and
# forty file edits.
#
# The moved draft is relabelled 12.43 -> 12.71 and its previous-build anchors
# 12.42 -> 12.70. Two anchors cannot simply be relabelled, because they quote the
# PREVIOUS build's own words rather than its number, so they are re-pointed from
# the real 1270 files: the corpus header the f-file quotes, and the WHATSNEW line
# the p-file inserts after.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false

if (-not (Test-Path ($H + 'p1243.ps1'))) { throw 'p1243 is missing' }
if (Test-Path ($H + 'p1271.ps1')) { throw 'p1271 exists: this swap has already run' }
if ((Get-Content ($H + 'd1243.txt') -TotalCount 1) -notmatch 'SPRINT TRAIL') { throw 'd1243 is not the sprint trail draft' }
if (-not (Test-Path ($H + 'f1270.ps1'))) { throw 'f1270 is missing, so the new anchor cannot be read' }
foreach ($f in @('p1243.ps1','f1243.ps1','d1243.txt','a1243.txt','cm1243.txt')) {
  if (-not (Test-Path ($H + $f))) { throw "$f missing" }
}

# THE TRUE ANCHORS, taken from the build that will now sit before the moved one.
$f70 = [IO.File]::ReadAllText($H + 'f1270.ps1')
$m70 = [regex]::Matches($f70, "(?m)^  \{v:'12\.70',what:'[^\r\n]*$")
if ($m70.Count -ne 1) { throw "f1270 has $($m70.Count) headers for 12.70, wanted 1" }
$hdr70 = $m70[0].Value
$p70 = [IO.File]::ReadAllText($H + 'p1270.ps1')
$w70 = [regex]::Matches($p70, "(?m)^  'A SEARCH CONTRACT NAMES A PLACE[^\r\n]*$")
if ($w70.Count -ne 1) { throw "p1270 has $($w70.Count) copies of its WHATSNEW line, wanted 1" }
$wn70 = $w70[0].Value

$moved = 0
foreach ($pair in @(@('p1243.ps1','p1271.ps1'), @('f1243.ps1','f1271.ps1'), @('d1243.txt','d1271.txt'), @('a1243.txt','a1271.txt'), @('cm1243.txt','cm1271.txt'))) {
  $src = [IO.File]::ReadAllText($H + $pair[0])
  # The dot is escaped in the DEVNOW regexes and bare everywhere else, so both
  # forms are matched and whichever one was there is put back.
  $src = [regex]::Replace($src, '12(\\?\.)43(?![0-9])', '12${1}71')
  $src = [regex]::Replace($src, '12(\\?\.)42(?![0-9])', '12${1}70')
  [IO.File]::WriteAllText($H + $pair[1], $src, $enc)
  Remove-Item ($H + $pair[0])
  $moved++
}
if ($moved -ne 5) { throw "moved $moved files, wanted 5" }

# RE-POINT ONE: the corpus header the f-file quotes is the previous build's own
# sentence, so relabelling it produced 12.70 wearing 12.42's words.
$f = [IO.File]::ReadAllText($H + 'f1271.ps1')
$bad = [regex]::Matches($f, "(?m)^  \{v:'12\.70',what:'[^\r\n]*$")
if ($bad.Count -ne 2) { throw "f1271 has $($bad.Count) headers to re-point, wanted 2" }
$f = [regex]::Replace($f, "(?m)^  \{v:'12\.70',what:'[^\r\n]*$", { param($m) $hdr70 })
[IO.File]::WriteAllText($H + 'f1271.ps1', $f, $enc)

# RE-POINT TWO: the WHATSNEW line the p-file inserts after is also the previous
# build's own words, and carries no number to relabel, so it was left behind.
$p = [IO.File]::ReadAllText($H + 'p1271.ps1')
$bw = [regex]::Matches($p, "(?m)^  'A GUN YOU STOW KEEPS ITS ROUNDS[^\r\n]*$")
if ($bw.Count -ne 2) { throw "p1271 has $($bw.Count) copies of the old WHATSNEW anchor, wanted 2" }
$p = [regex]::Replace($p, "(?m)^  'A GUN YOU STOW KEEPS ITS ROUNDS[^\r\n]*$", { param($m) $wn70 })
[IO.File]::WriteAllText($H + 'p1271.ps1', $p, $enc)

Write-Output "swapped: 1243 (sprint trail) is now 1271 at v12.71, anchored on v12.70; the 1243 slot is free"
