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
# run". v10.85 cut the ambient bed in endRaid, and v10.86 ducked it on pause,
# and both were right; but the raid branch of the frame loop keeps running
# while the outcome card is up, and tickAmbience is in it. Its alive argument is
# !player.downed, which after an EXTRACTION is true, so from the frame after
# endRaid it wrote the bed's gain back up to its floor of 0.16, every frame,
# until LOG RUN AND RETURN dropped the raid; and with nothing left to drive it
# the bed held that level for as long as the page was open. That is the hum on
# the floor, and it only follows a run he walked out of: a death leaves him
# downed, alive reads false, and the bed goes to 0 as it should. Over the card
# the bed is now driven to silence, which is what endRaid asked for.
SubRx @'
      tickAmbience(dt,th,!pp.downed,wdread);
'@ @'
      // v11.80, HIS NOTE: this line still runs over the outcome card, and after
      // an extraction he is not downed, so it wrote the bed back up to its floor
      // every frame after endRaid had cut it; the last level then held on the
      // Undercroft floor for as long as the page was open. Over the card the
      // bed is driven to silence instead.
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
  'THE HUM AFTER AN EXTRACTION IS GONE. The raid ambience was written back up while the outcome card was open and then held that level on the floor.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.79:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.79 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.79:[^']*'",{ param($m) "now:'v11.80: HIS NOTE of 2026-09-06, a strange hum on the Undercroft floor after completing a run. endRaid cuts the ambient bed (v10.85) but the raid branch of the loop keeps calling tickAmbience over the outcome card with alive = not downed, which after an extraction is true, so the bed was written back up to its 0.16 floor every frame and then held there once the raid was dropped. A death leaves him downed, so only an extraction hummed. Over the card the bed is now driven to silence. Check 11.80 wraps tickAmbience, deploys, ends the raid by extraction, runs thirty frames and requires every target written after the end to be 0, with a control that the bed was driven above 0 before the end; fails on v11.79.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
