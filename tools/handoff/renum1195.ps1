$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# HIS THREE WORDING NOTES of 2026-09-06 13:20 go in as v11.94, so every draft
# from 1194 to 1213 moves up one: files renamed, then every version label
# from 11.94 to 12.13 inside them shifted by one hundredth, descending so
# nothing is shifted twice. The draft that was 1194 also has its previous
# build label 11.93 shifted to 11.94 (anchors and control references only).
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
function Lab([int]$n) { if ($n -ge 100) { return '12(\\?\.)' + ($n - 100).ToString('00') } else { return '11(\\?\.)' + $n } }
function Rep([int]$n) { if ($n -ge 100) { return @('12', ($n - 100).ToString('00')) } else { return @('11', [string]$n) } }
function MoveSet([int]$from, [int]$to) {
  foreach ($t in @('p','f')) { Move-Item -LiteralPath ($H + $t + $from + '.ps1') -Destination ($H + $t + $to + '.ps1') }
  foreach ($t in @('d','a','cm')) { Move-Item -LiteralPath ($H + $t + $from + '.txt') -Destination ($H + $t + $to + '.txt') }
}
if (Test-Path ($H + 'p1194.ps1')) {
  if (Test-Path ($H + 'p1214.ps1')) { throw 'p1214 already exists' }
  for ($k = 1213; $k -ge 1194; $k--) { MoveSet $k ($k + 1) }
  Write-Output 'drafts 1194-1213 moved to 1195-1214'
} else { Write-Output 'already moved' }
$total = 0
foreach ($k in 1195..1214) {
  foreach ($f in @("p$k.ps1","f$k.ps1","d$k.txt","a$k.txt","cm$k.txt")) {
    $path = $H + $f
    $s = [IO.File]::ReadAllText($path)
    $n = 0
    $lo = 94; if ($k -eq 1195) { $lo = 93 }
    for ($v = 113; $v -ge $lo; $v--) {
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
