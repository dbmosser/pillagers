$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# The eight polish drafts moved from 1191-1198 to 1199-1206 to make room for
# the first-ten-minutes fixes. Every version label inside them shifts by eight:
# 11.90 (their old previous build) becomes 11.98, 11.91 becomes 11.99, 11.92
# becomes 12.00 and so on to 12.06. Descending, so a shifted label is never
# shifted twice. Every 11.90 in these files is an anchor or a control
# reference (checked by grep before the move). Idempotent: a file with no
# label left in the 11.90 to 11.98 range is skipped.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
$files = @()
foreach ($k in 1199..1206) { $files += ("p$k.ps1","f$k.ps1","d$k.txt","a$k.txt","cm$k.txt") }
$total = 0
foreach ($f in $files) {
  $path = $H + $f
  $s = [IO.File]::ReadAllText($path)
  $orig = $s
  $n = 0
  for ($v = 98; $v -ge 90; $v--) {
    $t = $v + 8
    if ($t -ge 100) { $maj = '12'; $min = ($t - 100).ToString('00') } else { $maj = '11'; $min = [string]$t }
    $pat = '11(\\?\.)' + $v + '(?![0-9])'
    $m = [regex]::Matches($s, $pat)
    if ($m.Count -gt 0) {
      $n += $m.Count
      $s = [regex]::Replace($s, $pat, { param($mm) $maj + $mm.Groups[1].Value + $min })
    }
  }
  if ($n -gt 0) { [IO.File]::WriteAllText($path, $s, $enc); $total += $n }
  Write-Output ($f + ': ' + $n + ' labels shifted')
}
Write-Output ("total " + $total)
