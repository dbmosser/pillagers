$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# 1277 is parked, so the two behind it move down one to keep the chain unbroken:
# 1278 -> 1277 and 1279 -> 1278. Labels shift with them, and the two anchors that
# quote the PREVIOUS build's own words are re-pointed at v12.76, which is HEAD.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
if (Test-Path ($H + 'p1277.ps1')) {
  if (-not (Test-Path ($H + 'parked'))) { New-Item -ItemType Directory ($H + 'parked') | Out-Null }
  foreach ($f in @('p1277.ps1','f1277.ps1','d1277.txt','a1277.txt','cm1277.txt')) {
    if (Test-Path ($H + $f)) { Move-Item ($H + $f) ($H + 'parked\' + $f) -Force }
  }
}
if (-not (Test-Path ($H + 'p1278.ps1'))) { throw 'p1278 is missing' }

# The real anchors from v12.76, which the moved build now sits behind.
$mk = [IO.File]::ReadAllText('C:\claudecode\dark raiders\tools\mkfixture.ps1')
$m76 = [regex]::Matches($mk, "(?m)^  \{v:'12\.76',what:'[^\r\n]*?$")
if ($m76.Count -ne 1) { throw "mkfixture has $($m76.Count) headers for 12.76, wanted 1" }
$hdr76 = $m76[0].Value
$gm = [IO.File]::ReadAllText('C:\claudecode\dark raiders\dark_raiders.html')
$w76 = [regex]::Matches($gm, "(?m)^  'HOW FAR YOU DIED FROM EXTRACTION[^\r\n]*?$")
if ($w76.Count -ne 1) { throw "the game has $($w76.Count) copies of the 12.76 line, wanted 1" }
$wn76 = $w76[0].Value

foreach ($step in @(@(1278,1277,'78','77','77','76'), @(1279,1278,'79','78','78','77'))) {
  foreach ($ext in @('p;ps1','f;ps1','d;txt','a;txt','cm;txt')) {
    $pre = $ext.Split(';')[0]; $sfx = $ext.Split(';')[1]
    $src = $H + $pre + $step[0] + '.' + $sfx
    if (-not (Test-Path $src)) { continue }
    $t = [IO.File]::ReadAllText($src)
    $t = [regex]::Replace($t, '12(\?\.)' + $step[2] + '(?![0-9])', '12${1}' + $step[3])
    $t = [regex]::Replace($t, '12(\?\.)' + $step[4] + '(?![0-9])', '12${1}' + $step[5])
    [IO.File]::WriteAllText(($H + $pre + $step[1] + '.' + $sfx), $t, $enc)
    Remove-Item $src
  }
}

# Re-point the two anchors that quote words rather than numbers, on the build that
# now sits directly behind v12.76.
$f = [IO.File]::ReadAllText($H + 'f1277.ps1')
$bad = [regex]::Matches($f, "(?m)^  \{v:'12\.76',what:'[^\r\n]*?$")
if ($bad.Count -ne 2) { throw "f1277 has $($bad.Count) headers to re-point, wanted 2" }
$f = [regex]::Replace($f, "(?m)^  \{v:'12\.76',what:'[^\r\n]*?$", { param($m) $hdr76 })
[IO.File]::WriteAllText($H + 'f1277.ps1', $f, $enc)

$p = [IO.File]::ReadAllText($H + 'p1277.ps1')
$bw = [regex]::Matches($p, "(?m)^  'DYING WITH THE FREEBIE KIT[^\r\n]*?$")
if ($bw.Count -ne 2) { throw "p1277 has $($bw.Count) copies of the old WHATSNEW anchor, wanted 2" }
$p = [regex]::Replace($p, "(?m)^  'DYING WITH THE FREEBIE KIT[^\r\n]*?$", { param($m) $wn76 })
[IO.File]::WriteAllText($H + 'p1277.ps1', $p, $enc)
Write-Output 'renumbered: 1278 is now 1277 on v12.76, 1279 is now 1278; the parked build is in handoff/parked'
