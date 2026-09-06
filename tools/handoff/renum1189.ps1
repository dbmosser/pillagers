$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# HIS ORDER of 2026-09-06 (the conditions panel lines) goes in as v11.88, so
# every draft from 1188 to 1206 moves up one: files renamed, then every
# version label from 11.88 to 12.06 inside them shifted by one hundredth,
# descending so nothing is shifted twice. The draft that was 1188 also has
# its previous-build label 11.87 shifted to 11.88 (every mention in it is an
# anchor or a control reference, checked by grep before the move).
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
function Lab([int]$n) { if ($n -ge 100) { return '12(\\?\.)' + ($n - 100).ToString('00') } else { return '11(\\?\.)' + $n } }
function Rep([int]$n) { if ($n -ge 100) { return @('12', ($n - 100).ToString('00')) } else { return @('11', [string]$n) } }
# RENAME, descending.
if (Test-Path ($H + 'p1188.ps1')) {
  for ($k = 1206; $k -ge 1188; $k--) {
    $new = $k + 1
    foreach ($t in @('p','f')) { Move-Item -LiteralPath ($H + $t + $k + '.ps1') -Destination ($H + $t + $new + '.ps1') }
    foreach ($t in @('d','a','cm')) { Move-Item -LiteralPath ($H + $t + $k + '.txt') -Destination ($H + $t + $new + '.txt') }
  }
  Write-Output 'renamed 1188-1206 to 1189-1207'
} else { Write-Output 'already renamed' }
# SHIFT LABELS.
$total = 0
foreach ($k in 1189..1207) {
  foreach ($f in @("p$k.ps1","f$k.ps1","d$k.txt","a$k.txt","cm$k.txt")) {
    $path = $H + $f
    $s = [IO.File]::ReadAllText($path)
    $n = 0
    # labels 106 (12.06) down to 88 (11.88), plus 87 for the file that was 1188
    $lo = 88; if ($k -eq 1189) { $lo = 87 }
    for ($v = 106; $v -ge $lo; $v--) {
      $pat = (Lab $v) + '(?![0-9])'
      $r = Rep ($v + 1)
      $m = [regex]::Matches($s, $pat)
      if ($m.Count -gt 0) {
        $n += $m.Count
        $maj = $r[0]; $min = $r[1]
        $s = [regex]::Replace($s, $pat, { param($mm) $maj + $mm.Groups[1].Value + $min })
      }
    }
    if ($n -gt 0) { [IO.File]::WriteAllText($path, $s, $enc); $total += $n }
    Write-Output ($f + ': ' + $n)
  }
}
Write-Output ("total " + $total)
