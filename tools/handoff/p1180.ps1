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

# HIS NOTE, 2026-09-06: "strange humming sound in undercroft after completing a
# run". v10.85 cut the ambient bed in endRaid and was right; it missed the rest
# of the frame. The extraction hold calls endRaid from inside updatePlayer, and
# the frame is already inside the raid block (its guard was read before the
# end), so it runs on to this line with alive = !downed, which after an
# EXTRACTION is true: the bed was written back up to its floor of 0.16 in the
# same frame, after the cut, and with no later frame driving it that level
# held on the Undercroft floor for as long as the page was open. A death
# leaves him downed, alive reads false, and the same order writes 0, which is
# why only a completed run hummed. Over an ended raid the bed is now driven to
# silence, which is what endRaid asked for one call earlier.
SubRx @'
      tickAmbience(dt,th,!pp.downed,wdread);
'@ @'
      // v11.80, HIS NOTE: the extraction hold ends the raid inside updatePlayer
      // above, and this frame runs on to here after endRaid's cut. Not downed
      // after an extraction, so this wrote the bed back up to its floor in the
      // same frame, and the level held on the Undercroft floor for as long as
      // the page was open. Over an ended raid the bed is driven to silence.
      tickAmbience(dt,G.over?0:th,!pp.downed&&!G.over,G.over?0:wdread);
'@

# STAMPS.
SubRx @'
var VER='11.79';
'@ @'
var VER='11.80';
'@
SubRx @'
var WHATSNEW_VER='11.79';
'@ @'
var WHATSNEW_VER='11.80';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE HUM AFTER AN EXTRACTION IS GONE. The frame that ended the raid was writing the raid ambience back up after it had been cut, and the level held on the floor.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.79:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.79 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.79:[^']*'",{ param($m) "now:'v11.80: HIS NOTE of 2026-09-06, a strange hum on the Undercroft floor after completing a run. The extraction hold calls endRaid from inside updatePlayer; endRaid cuts the ambient bed (v10.85) but the frame is already inside the raid block and runs on to tickAmbience with alive = not downed, true after an extraction, so the bed was written back up to its 0.16 floor in the same frame and held there once the raid was dropped. A death leaves him downed, so only extractions hummed. Over an ended raid the bed is driven to silence. Check 11.80 wraps tickAmbience and ends the raid from inside a wrapped updatePlayer, exactly where the hold does, and requires every target written from that frame on to be 0, with the bed proven driven above 0 before it; fails on v11.79.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
