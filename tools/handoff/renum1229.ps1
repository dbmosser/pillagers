$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# 2026-09-08. His order of the morning ("machines Few and extraction heat Light
# by default") jumps the queue, so it takes the 1229 slot and everything already
# drafted moves up one: 1229 crawler -> 1230, 1230 blank belt cell -> 1231,
# 1231 crafting -> 1232, 1232 footprints -> 1233, 1233 the frozen extraction
# clocks -> 1234. His defaults were drafted as 1234 and land as 1229.
# Every one of these builds bumps VER and WHATSNEW_VER, so each file needs only
# its own label and its previous label rewritten (through placeholders, so the
# two rewrites cannot collide), and each f-file needs its anchor re-pointed at
# the header of the build that now sits before it. Run verifychain after.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
function LabelOf([int]$k) { return '12.' + ($k - 1200).ToString('00') }
function LabPat([int]$k) { $l = LabelOf $k; return $l.Substring(0,2) + '(\\?\.)' + $l.Substring(3,2) + '(?![0-9])' }
function Files([int]$k) { return @("p$k.ps1", "f$k.ps1", "d$k.txt", "a$k.txt", "cm$k.txt") }
function HeaderOf([string]$path, [string]$label) {
  $s = [IO.File]::ReadAllText($path)
  $m = [regex]::Matches($s, "(?m)^  \{v:'" + [regex]::Escape($label) + "',what:'[^\r\n]*$")
  if ($m.Count -lt 1) { throw "no header with label $label in $path" }
  return $m[0].Value
}
function WithLabel([string]$line, [string]$label) { return [regex]::Replace($line, "^  \{v:'[0-9.]+'", "  {v:'" + $label + "'") }

# Guards: this must run exactly once, on the state it was written for.
if (-not (Test-Path ($H + 'p1234.ps1'))) { throw 'p1234 (his defaults, drafted) is missing' }
if ((Get-Content ($H + 'd1234.txt') -TotalCount 1) -notmatch 'FEWER MACHINES') { throw 'd1234 is not the defaults draft' }
if ((Get-Content ($H + 'd1229.txt') -TotalCount 1) -notmatch 'CRAWLER') { throw 'd1229 is not the crawler draft' }
if (Test-Path ($H + 'p1235.ps1')) { throw 'p1235 exists: this renumber has already run' }
foreach ($k in 1229..1234) { foreach ($f in (Files $k)) { if (-not (Test-Path ($H + $f))) { throw "$f missing" } } }

# Headers by NEW number, read BEFORE anything moves. 1229 becomes his defaults,
# whose check is currently labelled 12.34 and will be relabelled 12.29.
$hdr = @{}
$hdr[1229] = WithLabel (HeaderOf ($H + 'f1234.ps1') '12.34') '12.29'
foreach ($old in 1229..1233) { $new = $old + 1; $hdr[$new] = WithLabel (HeaderOf ($H + "f$old.ps1") (LabelOf $old)) (LabelOf $new) }

# His defaults step aside, the queue shifts up from the top down, then they land.
foreach ($f in (Files 1234)) { Move-Item -LiteralPath ($H + $f) -Destination ($H + 'x' + $f) }
foreach ($old in 1233..1229) {
  $new = $old + 1; $of = Files $old; $nf = Files $new
  for ($i = 0; $i -lt 5; $i++) { Move-Item -LiteralPath ($H + $of[$i]) -Destination ($H + $nf[$i]) }
}
$sf = Files 1234; $tf = Files 1229
for ($i = 0; $i -lt 5; $i++) { Move-Item -LiteralPath ($H + 'x' + $sf[$i]) -Destination ($H + $tf[$i]) }
Write-Output 'files moved'

# Labels: own -> new, previous -> new-1, through placeholders.
$total = 0
$moves = @{}
foreach ($old in 1229..1233) { $moves[$old + 1] = $old }
$moves[1229] = 1234
foreach ($new in ($moves.Keys | Sort-Object)) {
  $old = $moves[$new]
  foreach ($f in (Files $new)) {
    $path = $H + $f
    $s = [IO.File]::ReadAllText($path)
    $s = [regex]::Replace($s, (LabPat $old), { param($m) '@@OWN' + $m.Groups[1].Value + '@@' })
    $s = [regex]::Replace($s, (LabPat ($old - 1)), { param($m) '@@PRV' + $m.Groups[1].Value + '@@' })
    $ln = LabelOf $new; $lp = LabelOf ($new - 1)
    $s = [regex]::Replace($s, '@@OWN(\\?\.)@@', { param($m) $ln.Substring(0,2) + $m.Groups[1].Value + $ln.Substring(3,2) })
    $s = [regex]::Replace($s, '@@PRV(\\?\.)@@', { param($m) $lp.Substring(0,2) + $m.Groups[1].Value + $lp.Substring(3,2) })
    if ($s -match '@@') { throw "a placeholder was left in $f" }
    [IO.File]::WriteAllText($path, $s, $enc); $total++
  }
}
Write-Output ("files relabelled: " + $total)

# Anchors: each f-file quotes the header of the build now before it, twice.
foreach ($new in 1230..1234) {
  $path = $H + "f$new.ps1"; $s = [IO.File]::ReadAllText($path); $lp = LabelOf ($new - 1)
  $pat = "(?m)^  \{v:'" + [regex]::Escape($lp) + "',what:'[^\r\n]*$"
  $m = [regex]::Matches($s, $pat)
  if ($m.Count -ne 2) { throw "f$new anchor with label $lp matched $($m.Count) times, wanted 2" }
  $line = $hdr[$new - 1]
  $s = [regex]::Replace($s, $pat, { param($mm) $line })
  [IO.File]::WriteAllText($path, $s, $enc)
}
Write-Output 'anchors re-pointed; now run verifychain.ps1 -First 1229 -Last 1234 -Ver 12.28 -Wn 12.28'
