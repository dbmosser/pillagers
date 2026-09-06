$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Repair of renum1189.ps1, which moved 1199-1206 to 1200-1207 and then died
# on the never-drafted 1198. The eight polish drafts go back to 1199-1206
# (their labels 11.99 to 12.06 already assume an 11.98 before them), and
# 1188-1197 move to 1189-1198 with their labels shifted by one hundredth.
# 11.87 shifts only in the draft that was 1188 (every mention is an anchor).
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
function MoveSet([int]$from, [int]$to) {
  foreach ($t in @('p','f')) { Move-Item -LiteralPath ($H + $t + $from + '.ps1') -Destination ($H + $t + $to + '.ps1') }
  foreach ($t in @('d','a','cm')) { Move-Item -LiteralPath ($H + $t + $from + '.txt') -Destination ($H + $t + $to + '.txt') }
}
if (Test-Path ($H + 'p1207.ps1')) {
  for ($k = 1200; $k -le 1207; $k++) { MoveSet $k ($k - 1) }
  Write-Output 'polish drafts back at 1199-1206'
} else { Write-Output 'polish drafts already at 1199-1206' }
if (Test-Path ($H + 'p1188.ps1')) {
  for ($k = 1197; $k -ge 1188; $k--) { MoveSet $k ($k + 1) }
  Write-Output 'drafts 1188-1197 moved to 1189-1198'
} else { Write-Output 'drafts already at 1189-1198' }
$total = 0
foreach ($k in 1189..1198) {
  foreach ($f in @("p$k.ps1","f$k.ps1","d$k.txt","a$k.txt","cm$k.txt")) {
    $path = $H + $f
    $s = [IO.File]::ReadAllText($path)
    $n = 0
    $lo = 88; if ($k -eq 1189) { $lo = 87 }
    for ($v = 97; $v -ge $lo; $v--) {
      $pat = '11(\\?\.)' + $v + '(?![0-9])'
      $min = [string]($v + 1)
      $m = [regex]::Matches($s, $pat)
      if ($m.Count -gt 0) {
        $n += $m.Count
        $s = [regex]::Replace($s, $pat, { param($mm) '11' + $mm.Groups[1].Value + $min })
      }
    }
    if ($n -gt 0) { [IO.File]::WriteAllText($path, $s, $enc); $total += $n }
    Write-Output ($f + ': ' + $n)
  }
}
Write-Output ("total " + $total)
