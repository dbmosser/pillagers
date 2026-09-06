param([int]$First = 1199, [int]$Last = 1220, [string]$Ver = '11.98', [string]$Wn = '11.98')
$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Walks the drafted chain p/f/d/a/cm First..Last from a tree at -Ver (and
# WHATSNEW_VER at -Wn) and throws on the first broken link: a VER or
# WHATSNEW_VER old value the tree will not have, a DEVNOW pattern naming the
# wrong previous build, an f-file anchor that does not quote the header the
# build before it inserts, or a d/a/cm label that is not the build's own.
# Run after every renumber: powershell -File tools/handoff/verifychain.ps1 -First 1199 -Last 1220 -Ver 11.98 -Wn 11.98
$H = 'C:\claudecode\dark raiders\tools\handoff\'
$MK = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
function LabelOf([int]$k) { if ($k -ge 1200) { return '12.' + ($k - 1200).ToString('00') } else { return '11.' + ($k - 1100) } }
function HeaderLine([string]$path, [string]$label) {
  $s = [IO.File]::ReadAllText($path)
  $m = [regex]::Matches($s, "(?m)^  \{v:'" + [regex]::Escape($label) + "',what:'[^\r\n]*$")
  if ($m.Count -lt 1) { throw "no header with label $label in $path" }
  return $m[0].Value
}
$ver = $Ver; $wn = $Wn; $prevWhat = HeaderLine $MK $Ver
$devPat = "now:'v(1[12])\\\.([0-9][0-9]):\["
foreach ($k in $First..$Last) {
  $lab = LabelOf $k
  foreach ($f in @("p$k.ps1", "f$k.ps1", "d$k.txt", "a$k.txt", "cm$k.txt")) { if (-not (Test-Path ($H + $f))) { throw "$f missing" } }
  $p = [IO.File]::ReadAllText($H + "p$k.ps1")
  if ($p -match '[^\x00-\x7F]') { throw "p$k has a non-ASCII character" }
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
  $md = [regex]::Matches($p, $devPat)
  if ($md.Count -ne 2) { throw "p$k has $($md.Count) DEVNOW patterns, wanted 2" }
  $dv = $md[0].Groups[1].Value + '.' + $md[0].Groups[2].Value
  if ($dv -ne $ver) { throw "p$k DEVNOW pattern names $dv, tree will be $ver" }
  $mr = [regex]::Matches($p, "now:'v([0-9.]+): ")
  if ($mr.Count -ne 1 -or $mr[0].Groups[1].Value -ne $lab) { throw "p$k DEVNOW replacement is not v$lab" }
  $rep = $mr[0].Value; $tail = $p.Substring($mr[0].Index)
  $endq = $tail.IndexOf("'", 6); $body = $tail.Substring(6, $endq - 6)
  if ($body.IndexOf("'") -ge 0) { throw "p$k DEVNOW text contains a quote" }
  $f = [IO.File]::ReadAllText($H + "f$k.ps1")
  if ($f -match '[^\x00-\x7F]') { throw "f$k has a non-ASCII character" }
  # An f-file may also repair older checks (their headers appear too), so the
  # anchor is the pair of lines carrying the PREVIOUS label and the insert is
  # the one line carrying the build's own label; every other label must be a
  # shipped build older than the tree.
  $mh = [regex]::Matches($f, "(?m)^  \{v:'([0-9.]+)',what:'([^\r\n]*)$")
  $anch = @(); $own = @(); $other = @()
  foreach ($x in $mh) { $l = $x.Groups[1].Value; if ($l -eq $ver) { $anch += $x.Value } elseif ($l -eq $lab) { $own += $x.Value } else { $other += $l } }
  if ($anch.Count -ne 2) { throw "f$k quotes the v$ver header $($anch.Count) times, wanted 2" }
  if ($anch[0] -ne $prevWhat -or $anch[1] -ne $prevWhat) { throw "f$k anchors do not match the v$ver header the build before it inserts; they quote: " + $anch[0].Substring(0, [Math]::Min(70, $anch[0].Length)) }
  if ($own.Count -ne 1) { throw "f$k inserts label $lab $($own.Count) times, wanted 1" }
  foreach ($l in $other) { if ([double]$l -ge [double]$Ver) { throw "f$k names label $l, which is not shipped and not its own or previous build" } }
  $prevWhat = $own[0]
  $d1 = Get-Content ($H + "d$k.txt") -TotalCount 1
  if ($d1 -notlike "## v$lab - *") { throw "d$k heading is '$d1'" }
  $d = [IO.File]::ReadAllText($H + "d$k.txt")
  if ($d -notmatch 'Not verified:') { throw "d$k has no Not verified line" }
  $a = [IO.File]::ReadAllText($H + "a$k.txt")
  if ($a -notmatch [regex]::Escape("| v$lab |")) { throw "a$k lacks | v$lab |" }
  $c1 = Get-Content ($H + "cm$k.txt") -TotalCount 1
  if ($c1 -notlike "v$lab`: *") { throw "cm$k first line is '$c1'" }
  $ver = $lab
}
Write-Output ("chain verified " + $First + ".." + $Last + ": VER ends " + $ver + ", WHATSNEW_VER ends " + $wn)
