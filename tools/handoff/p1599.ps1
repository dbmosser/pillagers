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
# ONE WHOLE LINE FOUND BY ITS SHAPE. Build 1587 (sector audit: the hour on the sector map header at NIGHT) edits the same
# header line this build edits and the same CONDITIONS row, putting (isDay()?tod().name:'night') in the hour slot of each.
# p1587 was drafted in a parallel chain, so both old blocks below are read out of the file by shape and handed to SubRx whole,
# and this script applies whether 1587 has landed on both lines (the expected case), on one, or on neither. Each shape must
# still match exactly once, and SubRx still requires the whole line to match exactly once.
function LineBy([string]$pat) {
  $mm = [regex]::Matches($script:s, $pat)
  if ($mm.Count -ne 1) { throw "shape matched $($mm.Count) times: $pat" }
  return $mm[0]
}

# THE WORD. If 1587 has put a night word in the hour slot of the sector map header, the CONDITIONS row uses the same word, so
# the two surfaces agree; if 1587 is not in, the row says NIGHT, the sector page word (the NIGHT button, SURFACE: NIGHT).
$NIGHT = 'NIGHT'
$hdrWord = [regex]::Match($s, "(?m)^  ctx\.fillText\(\(isDay\(\)\?tod\(\)\.name:'([A-Za-z]+)'\)\+'  '\+")
if ($hdrWord.Success) { $NIGHT = $hdrWord.Groups[1].Value }

# EDIT 1: the CONDITIONS row in drawHUD. With p1587 in, this re-states the line 1587 wrote, word for word, and only adds the note;
# without it, this is the fix.
$condM = LineBy "(?m)^    rows\.push\(\{k:.*\+'   '\+MW\.name,v:\(wv\.length\?wv\.join\(', '\):''\),\r?$"
$condOld = $condM.Value
$condNote = @'
    // v15.99, weather audit finding: THE CONDITIONS ROW SAYS NIGHT AT NIGHT. G.tod is rolled by pickTod on every raid, night
    // included, so the seeded stream stays in step, and every visual reader of it (the cast, the dim, the lamps) is gated on
    // isDay(), so at NIGHT the hour is a dead roll. This row printed it anyway: a raid he sent up in the dark read noon, 8am or
    // 6pm beside the weather for the whole raid. v15.87 put the night word here first; this build keeps the row in the same
    // word as the sector map header, and stands on its own if 15.87 is parked. By day the row is unchanged. No number and no
    // seeded draw moved.
'@
$condCode = "    rows.push({k:(isDay()?MT.name:'" + $NIGHT + "')+'   '+MW.name,v:(wv.length?wv.join(', '):''),"
$condNew = $condNote + "`n" + $condCode
SubRx $condOld $condNew

# EDIT 2: the sector map header in drawMapOverlay. Only the weather on the left of the arrow changes; the hour part of the
# line, whatever 1587 left there, is carried over as it stands.
$hdrM = LineBy "(?m)^  ctx\.fillText\((.*)\+'  '\+wx\(\)\.name\+\r?$"
$hdrOld = $hdrM.Value
$hdrNote = @'
  // v15.99, weather audit finding: THE SECTOR MAP NAMES THE WEATHER IT IS LEAVING. wx() is the live blend while a turn runs,
  // and wxMix hands the blend the destination name once the turn is half way (t>=0.5), which is right for every reader that
  // wants the nearer state. This header wants the two ends of the turn, and from 7 seconds after The weather is turning is
  // heard it named the coming weather on both sides of the arrow (Storming, arrow, Storming 71%), while the CONDITIONS row,
  // which reads G.wx, still said Rainy. The left of the arrow is G.wx, the weather the turn is leaving, which buildRaid always
  // sets. The colour above and every other reader of wx() are unchanged. No number and no seeded draw moved.
'@
$hdrCode = "  ctx.fillText(" + $hdrM.Groups[1].Value + "+'  '+G.wx.name+"
$hdrNew = $hdrNote + "`n" + $hdrCode
SubRx $hdrOld $hdrNew

SubRx @'
var VER='15.98';
'@ @'
var VER='15.99';
'@

$pat = "(?m)^  now:'v15\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.99: THE SECTOR MAP NAMES THE WEATHER IT IS LEAVING, AND THE CONDITIONS ROW SAYS NIGHT AT NIGHT. From half way through a weather turn the sector map header named the coming weather on both sides of the arrow, Storming then Storming, while the CONDITIONS row still said Rainy; the left of the arrow is now the weather the turn is leaving. The CONDITIONS row keeps the night word 15.87 gave it, in the same word as the sector map header, and by day it names the rolled hour as before. Check 15.99 draws the header three quarters through a turn and the row at night; it fails on v15.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx ")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
