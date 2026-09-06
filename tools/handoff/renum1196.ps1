$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# HIS BELT-DRAG NOTES (v11.95) and HIS EXTRACTION-RING NOTE (v11.96) of
# 2026-09-06 13:40 to 13:50 go in next, so every draft from 1195 to 1214
# moves up TWO: files renamed, then every version label from 11.95 to 12.14
# inside them shifted by two hundredths, descending. The draft that was 1195
# also has its previous-build label 11.94 shifted to 11.96.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
function Lab([int]$n) { if ($n -ge 100) { return '12(\\?\.)' + ($n - 100).ToString('00') } else { return '11(\\?\.)' + $n } }
function Rep([int]$n) { if ($n -ge 100) { return @('12', ($n - 100).ToString('00')) } else { return @('11', [string]$n) } }
function MoveSet([int]$from, [int]$to) {
  foreach ($t in @('p','f')) { Move-Item -LiteralPath ($H + $t + $from + '.ps1') -Destination ($H + $t + $to + '.ps1') }
  foreach ($t in @('d','a','cm')) { Move-Item -LiteralPath ($H + $t + $from + '.txt') -Destination ($H + $t + $to + '.txt') }
}
if (Test-Path ($H + 'p1218.ps1')) { throw 'p1216 already exists' }
if (-not (Test-Path ($H + 'p1214.ps1'))) { throw 'p1214 missing: run renum1195 first' }
for ($k = 1214; $k -ge 1195; $k--) { MoveSet $k ($k + 4) }
Write-Output 'drafts 1195-1214 moved to 1199-1218'
$total = 0
foreach ($k in 1199..1218) {
  foreach ($f in @("p$k.ps1","f$k.ps1","d$k.txt","a$k.txt","cm$k.txt")) {
    $path = $H + $f
    $s = [IO.File]::ReadAllText($path)
    $n = 0
    $lo = 95; if ($k -eq 1199) { $lo = 94 }
    for ($v = 114; $v -ge $lo; $v--) {
      $pat = (Lab $v) + '(?![0-9])'
      $r = Rep ($v + 4)
      $m = [regex]::Matches($s, $pat)
      if ($m.Count -gt 0) {
        $n += $m.Count
        $maj = $r[0]; $min = $r[1]
        $s = [regex]::Replace($s, $pat, { param($mm) $maj + $mm.Groups[1].Value + $min })
      }
    }
    if ($n -gt 0) { [IO.File]::WriteAllText($path, $s, $enc); $total += $n }
  }
}
Write-Output ("total " + $total)
