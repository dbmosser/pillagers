$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# 2026-09-06 14:45. His two direct notes of the afternoon, the 4K right-click
# menu (was 1219) and the Howler roof rule (was 1220), go in NEXT as v11.99
# and v12.00, then the first-session build (was 1200) as v12.01, then the
# pause-note build (was 1199) as v12.02, then the rest (were 1201 to 1218)
# as v12.03 to v12.20. Files are renamed, every version label inside them is
# rewritten, the check anchors that name the previous build are re-pointed,
# and the WHATSNEW_VER chain is repaired where a build does not bump it
# (1200 first session, 1202 heal verb and 1203 notes line never did).
# A verification pass at the end walks the whole chain from the tree at
# v11.98 and throws on the first broken link.
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$MK = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$enc = New-Object Text.UTF8Encoding $false
function Lab([int]$n) { if ($n -ge 100) { return '12(\\?\.)' + ($n - 100).ToString('00') } else { return '11(\\?\.)' + $n } }
function Rep([int]$n) { if ($n -ge 100) { return @('12', ($n - 100).ToString('00')) } else { return @('11', [string]$n) } }
function LabelOf([int]$k) { if ($k -ge 1200) { return '12.' + ($k - 1200).ToString('00') } else { return '11.' + ($k - 1100) } }
function Files([int]$k) { return @("p$k.ps1", "f$k.ps1", "d$k.txt", "a$k.txt", "cm$k.txt") }
function MoveSet([int]$from, [int]$to) {
  foreach ($t in @('p','f')) { Move-Item -LiteralPath ($H + $t + $from + '.ps1') -Destination ($H + $t + $to + '.ps1') }
  foreach ($t in @('d','a','cm')) { Move-Item -LiteralPath ($H + $t + $from + '.txt') -Destination ($H + $t + $to + '.txt') }
}
function Shift([int]$k, [int]$hi, [int]$lo, [int]$by) {
  # every label from 11.hi down to 11.lo (hundredths above 11.00) moves by $by hundredths, descending
  $total = 0
  foreach ($f in (Files $k)) {
    $path = $H + $f
    $s = [IO.File]::ReadAllText($path)
    $n = 0
    for ($v = $hi; $v -ge $lo; $v--) {
      $pat = (Lab $v) + '(?![0-9])'
      $r = Rep ($v + $by)
      $m = [regex]::Matches($s, $pat)
      if ($m.Count -gt 0) {
        $n += $m.Count
        $maj = $r[0]; $min = $r[1]
        $s = [regex]::Replace($s, $pat, { param($mm) $maj + $mm.Groups[1].Value + $min })
      }
    }
    if ($n -gt 0) { [IO.File]::WriteAllText($path, $s, $enc); $total += $n }
  }
  return $total
}
function HeaderLine([string]$path, [string]$label) {
  $s = [IO.File]::ReadAllText($path)
  $m = [regex]::Matches($s, "(?m)^  \{v:'" + [regex]::Escape($label) + "',what:'[^\r\n]*$")
  if ($m.Count -lt 1) { throw "no header with label $label in $path" }
  return $m[0].Value
}
function WithLabel([string]$line, [string]$label) {
  return [regex]::Replace($line, "^  \{v:'[0-9.]+'", "  {v:'" + $label + "'")
}
function SetAnchor([int]$k, [string]$label, [string]$line) {
  # the f-file quotes the previous build's header twice (old block, tail of the new block)
  $path = $H + "f$k.ps1"
  $s = [IO.File]::ReadAllText($path)
  $pat = "(?m)^  \{v:'" + [regex]::Escape($label) + "',what:'[^\r\n]*$"
  $m = [regex]::Matches($s, $pat)
  if ($m.Count -ne 2) { throw "f$k anchor with label $label matched $($m.Count) times, wanted 2" }
  $s = [regex]::Replace($s, $pat, { param($mm) $line })
  [IO.File]::WriteAllText($path, $s, $enc)
}
function FixOne([string]$file, [string]$old, [string]$new) {
  $path = $H + $file
  $s = [IO.File]::ReadAllText($path)
  $c = ([regex]::Matches($s, [regex]::Escape($old))).Count
  if ($c -ne 1) { throw "$file : '$old' matched $c times, wanted 1" }
  $s = $s.Replace($old, $new)
  [IO.File]::WriteAllText($path, $s, $enc)
}

if (Test-Path ($H + 'p1221.ps1')) { throw 'p1221 already exists: renumber already ran' }
if (-not (Test-Path ($H + 'p1220.ps1'))) { throw 'p1220 missing' }
if ((Get-Content ($H + 'd1219.txt') -TotalCount 1) -notmatch 'RIGHT-CLICK MENU') { throw 'd1219 is not the 4K menu draft' }
if ((Get-Content ($H + 'd1220.txt') -TotalCount 1) -notmatch 'HOWLER') { throw 'd1220 is not the Howler draft' }

# The header lines that will be needed as anchors, read BEFORE anything moves.
$whatHold   = HeaderLine ($H + 'f1199.ps1') '11.98'   # the shipped v11.98 check header, quoted by f1199
$whatPause  = HeaderLine ($H + 'f1199.ps1') '11.99'
$whatFirst  = HeaderLine ($H + 'f1200.ps1') '12.00'
$whatMenu   = HeaderLine ($H + 'f1219.ps1') '12.19'
$whatHowler = HeaderLine ($H + 'f1220.ps1') '12.20'
$mkHold = HeaderLine $MK '11.98'
if ($mkHold -ne $whatHold) { throw 'f1199 quotes a v11.98 header that differs from mkfixture' }

# 1. the two promoted drafts step aside
MoveSet 1219 9919
MoveSet 1220 9920
# 2. 1218 down to 1201 move up two, descending
for ($k = 1218; $k -ge 1201; $k--) { MoveSet $k ($k + 2) }
# 3. first session 1200 -> 1201, pause note 1199 -> 1202
MoveSet 1200 1201
MoveSet 1199 1202
# 4. the promoted pair land
MoveSet 9919 1199
MoveSet 9920 1200
Write-Output 'files moved'

# Labels. Group A: new 1199 (was 1219): 12.19 -> 11.99, 12.18 -> 11.98
$t = 0
$t += Shift 1199 119 118 -20
# Group B: new 1200 (was 1220): 12.20 -> 12.00, 12.19 -> 11.99
$t += Shift 1200 120 119 -20
# Group C: new 1201 (was 1200): 12.00 -> 12.01, 11.99 -> 12.00 (descending, so the fresh 12.00 is not re-touched)
$t += Shift 1201 100 99 1
# Group D: new 1202 (was 1199): 11.99 -> 12.02, 11.98 -> 12.01
$t += Shift 1202 99 98 3
# Group U: new 1203..1220 (were 1201..1218): every label 12.18 down to 11.98 moves up two
foreach ($k in 1203..1220) { $t += Shift $k 118 98 2 }
Write-Output ("labels rewritten: " + $t)

# WHATSNEW_VER chain repairs. The first-session build (now 1201) never bumps
# WHATSNEW_VER, so the pause-note build (now 1202) inherits 12.00 from the
# Howler build, and the freebie-death build (now 1203) inherits 12.02 from it.
FixOne 'p1202.ps1' "var WHATSNEW_VER='12.01';" "var WHATSNEW_VER='12.00';"
FixOne 'p1203.ps1' "var WHATSNEW_VER='12.01';" "var WHATSNEW_VER='12.02';"

# Anchors: each moved f-file must quote the header of the build now before it.
SetAnchor 1199 '11.98' (WithLabel $whatHold '11.98')      # was the arrow-key header
SetAnchor 1201 '12.00' (WithLabel $whatHowler '12.00')    # was the pause-note header
SetAnchor 1202 '12.01' (WithLabel $whatFirst '12.01')     # was the boarding-hold header
SetAnchor 1203 '12.02' (WithLabel $whatPause '12.02')     # was the first-session header
Write-Output 'anchors re-pointed'

# VERIFY THE WHOLE CHAIN from the tree at v11.98.
$ver = '11.98'; $wn = '11.98'; $prevWhat = $mkHold
foreach ($k in 1199..1220) {
  $lab = LabelOf $k
  $p = [IO.File]::ReadAllText($H + "p$k.ps1")
  $mv = [regex]::Matches($p, "var VER='([0-9.]+)';")
  if ($mv.Count -ne 2) { throw "p$k has $($mv.Count) VER lines" }
  if ($mv[0].Groups[1].Value -ne $ver) { throw "p$k expects VER $($mv[0].Groups[1].Value), tree will be $ver" }
  if ($mv[1].Groups[1].Value -ne $lab) { throw "p$k sets VER $($mv[1].Groups[1].Value), wanted $lab" }
  $mw = [regex]::Matches($p, "var WHATSNEW_VER='([0-9.]+)';")
  if ($mw.Count -eq 2) {
    if ($mw[0].Groups[1].Value -ne $wn) { throw "p$k expects WHATSNEW_VER $($mw[0].Groups[1].Value), tree will be $wn" }
    if ($mw[1].Groups[1].Value -ne $lab) { throw "p$k sets WHATSNEW_VER $($mw[1].Groups[1].Value), wanted $lab" }
    $wn = $lab
  } elseif ($mw.Count -ne 0) { throw "p$k has $($mw.Count) WHATSNEW_VER lines" }
  $md = [regex]::Matches($p, "now:'v(1[12])\\\\\.([0-9][0-9]):\[")
  if ($md.Count -ne 2) { throw "p$k has $($md.Count) DEVNOW patterns" }
  $dv = $md[0].Groups[1].Value + '.' + $md[0].Groups[2].Value
  if ($dv -ne $ver) { throw "p$k DEVNOW pattern names $dv, tree will be $ver" }
  $mr = [regex]::Matches($p, "now:'v([0-9.]+): ")
  if ($mr.Count -ne 1 -or $mr[0].Groups[1].Value -ne $lab) { throw "p$k DEVNOW replacement is not $lab" }
  $f = [IO.File]::ReadAllText($H + "f$k.ps1")
  $mh = [regex]::Matches($f, "(?m)^  \{v:'([0-9.]+)',what:'([^\r\n]*)$")
  if ($mh.Count -ne 3) { throw "f$k has $($mh.Count) header lines, wanted 3" }
  if ($mh[0].Value -ne $prevWhat -or $mh[2].Value -ne $prevWhat) { throw "f$k anchors do not quote the v$ver header: " + $mh[0].Value.Substring(0, 60) }
  if ($mh[1].Groups[1].Value -ne $lab) { throw "f$k inserts label $($mh[1].Groups[1].Value), wanted $lab" }
  $prevWhat = $mh[1].Value
  $d1 = Get-Content ($H + "d$k.txt") -TotalCount 1
  if ($d1 -notlike "## v$lab - *") { throw "d$k heading is '$d1'" }
  $a = [IO.File]::ReadAllText($H + "a$k.txt")
  if ($a -notmatch [regex]::Escape("| v$lab |")) { throw "a$k lacks | v$lab |" }
  $c1 = Get-Content ($H + "cm$k.txt") -TotalCount 1
  if ($c1 -notlike "v$lab`: *") { throw "cm$k first line is '$c1'" }
  $ver = $lab
}
Write-Output ('chain verified 1199..1220: VER ends ' + $ver + ', WHATSNEW_VER ends ' + $wn)
