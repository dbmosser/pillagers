$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# 2026-09-06 16:45. His crawler note goes in as 1207 (files written by hand),
# and the remaining queue is reordered so the first-raid defects ship before
# the polish: 1208 dead trigger (was 1219), 1209 arrows walk with the bag
# open (was 1220), 1210 second down (was 1214), 1211 ESC closes the floor
# backpack (was 1216), 1212 death banks card XP (was 1218), 1213 lift freebie
# clears the plan (was 1215), 1214 controls card (was 1217), then the polish
# 1215 to 1221 (were 1207 to 1213). Every remaining draft bumps VER and
# WHATSNEW_VER, so each file needs only its own label and its previous label
# rewritten (via placeholders, so no collision) and its f-file anchors pointed
# at the header of the build now before it. Run verifychain.ps1 after.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$enc = New-Object Text.UTF8Encoding $false
$map = @{ 1219=1208; 1220=1209; 1214=1210; 1216=1211; 1218=1212; 1215=1213; 1217=1214; 1207=1215; 1208=1216; 1209=1217; 1210=1218; 1211=1219; 1212=1220; 1213=1221 }
function LabelOf([int]$k) { if ($k -ge 1200) { return '12.' + ($k - 1200).ToString('00') } else { return '11.' + ($k - 1100) } }
function LabPat([int]$k) { $l = LabelOf $k; return $l.Substring(0,2) + '(\\?\.)' + $l.Substring(3,2) + '(?![0-9])' }
function Files([int]$k) { return @("p$k.ps1", "f$k.ps1", "d$k.txt", "a$k.txt", "cm$k.txt") }
function HeaderOf([string]$path, [string]$label) {
  $s = [IO.File]::ReadAllText($path)
  $m = [regex]::Matches($s, "(?m)^  \{v:'" + [regex]::Escape($label) + "',what:'[^\r\n]*$")
  if ($m.Count -lt 1) { throw "no header with label $label in $path" }
  return $m[0].Value
}
function WithLabel([string]$line, [string]$label) { return [regex]::Replace($line, "^  \{v:'[0-9.]+'", "  {v:'" + $label + "'") }

# The crawler build was written as 1299 (its labels already read 12.07 over
# 12.06) because 1207 was occupied by the safe-pocket draft; it lands as 1207
# after that draft has moved to 1215.
if (-not (Test-Path ($H + 'p1299.ps1'))) { throw 'p1299 (the crawler build, staged) is missing' }
if (Test-Path ($H + 'p1221.ps1')) { throw 'p1221 exists: this renumber already ran' }
if ((Get-Content ($H + 'd1299.txt') -TotalCount 1) -notmatch 'CRAWLER') { throw 'd1299 is not the crawler draft' }
if ((Get-Content ($H + 'd1207.txt') -TotalCount 1) -notmatch 'SAFE POCKET') { throw 'd1207 is not the safe-pocket draft' }
if ((Get-Content ($H + 'd1219.txt') -TotalCount 1) -notmatch 'TRIGGER') { throw 'd1219 is not the dead-trigger draft' }
foreach ($old in $map.Keys) { foreach ($f in (Files $old)) { if (-not (Test-Path ($H + $f))) { throw "$f missing" } } }

# Headers by NEW number, read before anything moves. 1207 is the crawler build itself.
$hdr = @{}
$hdr[1207] = HeaderOf ($H + 'f1299.ps1') '12.07'
foreach ($old in $map.Keys) { $new = $map[$old]; $hdr[$new] = WithLabel (HeaderOf ($H + "f$old.ps1") (LabelOf $old)) (LabelOf $new) }

# Move every set through a temporary name so no target is ever occupied.
foreach ($old in $map.Keys) { foreach ($f in (Files $old)) { Move-Item -LiteralPath ($H + $f) -Destination ($H + 'x' + $f) } }
foreach ($old in $map.Keys) { $new = $map[$old]; $of = Files $old; $nf = Files $new
  for ($i = 0; $i -lt 5; $i++) { Move-Item -LiteralPath ($H + 'x' + $of[$i]) -Destination ($H + $nf[$i]) } }
# The staged crawler build takes the vacated 1207; its labels need no rewrite.
$sf = Files 1299; $tf = Files 1207
for ($i = 0; $i -lt 5; $i++) { Move-Item -LiteralPath ($H + $sf[$i]) -Destination ($H + $tf[$i]) }
Write-Output 'files moved'

# Labels: own -> new, previous -> new-1, through placeholders.
$total = 0
foreach ($old in $map.Keys) { $new = $map[$old]
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
  } }
Write-Output ("files relabelled: " + $total)

# Anchors: each moved f-file quotes the header of the build now before it, twice.
foreach ($old in $map.Keys) { $new = $map[$old]
  $path = $H + "f$new.ps1"; $s = [IO.File]::ReadAllText($path); $lp = LabelOf ($new - 1)
  $pat = "(?m)^  \{v:'" + [regex]::Escape($lp) + "',what:'[^\r\n]*$"
  $m = [regex]::Matches($s, $pat)
  if ($m.Count -ne 2) { throw "f$new anchor with label $lp matched $($m.Count) times, wanted 2" }
  $line = $hdr[$new - 1]
  $s = [regex]::Replace($s, $pat, { param($mm) $line })
  [IO.File]::WriteAllText($path, $s, $enc) }
Write-Output 'anchors re-pointed; now run verifychain.ps1 -First 1207 -Last 1221 -Ver 12.06 -Wn 12.06'
