$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FROM THE 2026-09-06 READ-ONLY REVIEW OF v11.78 (the corner readout twice
# the size): every station window stamps the same credits and XP into its
# own heading (.modcur, pushed to the heading's right edge), and at 44px the
# corner readout prints through the top of it. The v11.52 precedent for the
# stash screen's own credits figure was to hide it, since the corner shows
# the same two numbers at all times; the heading's balance goes the same way.
SubRx @'
  .modal h3{ display:flex; align-items:baseline; gap:12px; }
'@ @'
  .modal h3{ display:flex; align-items:baseline; gap:12px; }
  /* v12.11: the heading's own balance sat under the corner readout once that
     grew (v11.78); the corner shows the same two figures at all times, so the
     heading no longer repeats them (the v11.52 rule for the stash screen). */
  .modal h3 .modcur{ display:none; }
'@

# STAMPS.
SubRx @'
var VER='12.10';
'@ @'
var VER='12.11';
'@
SubRx @'
var WHATSNEW_VER='12.10';
'@ @'
var WHATSNEW_VER='12.11';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE STATION WINDOWS NO LONGER REPEAT YOUR BALANCE IN THEIR HEADING. The corner readout has it, at all times.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.10:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.10 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.10:[^']*'",{ param($m) "now:'v12.11: from the read-only review of the shipped v11.78, every station window stamped its own credits and XP into its heading and the enlarged corner readout printed through them. The heading balance is hidden; the corner shows the same two figures at all times (the v11.52 rule for the stash screen). The same build repairs check 11.52, which double-scaled the CONDITIONS box top and could not see an overlap. Check 12.11 opens the shop window and requires the heading balance not to be drawn where the readout is; fails on v12.10 where the two boxes intersect.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
