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

# FROM THE 2026-09-08 FIRST-HOUR AUDIT, the half of that finding I confirmed by
# reading. The other half was wrong and is not built: the audit said the Settings
# words promise a report every second raid while the code drops one after the
# first, and they do not, and the first drop of a session is deliberate.
#
# THE PART THAT IS REAL. The game was renamed. Every screen says PILLAGERS: the
# tab, the Undercroft brand, the report header, and the importer, which refuses a
# file by telling him it is not a Pillagers run report. One string was missed,
# and it is the worst one to miss, because it is the only one that leaves the
# browser: the name of the file the game drops into his Downloads. A friend
# opening the alpha finishes a raid and finds a file on their disk named after a
# game they have never heard of, and that is the file they are asked to send back.
#
# The name is now built by a function rather than written at the point of use, so
# there is one place to be wrong and something a check can call. The importer
# reads a report's CONTENTS and not its name, so nothing already on disk stops
# working.
SubRx @'
function downloadExport(){
'@ @'
// v12.72, 2026-09-08 first-hour audit: THE FILE HE IS HANDED CARRIES THE NAME OF
// THE GAME HE JUST PLAYED. The rename reached every screen and missed the one
// string that leaves the browser, so the run report landed in his Downloads
// under the retired project name. It is also the file he is asked to send back,
// so the collector was receiving reports named for a game that no longer exists.
// The name lives in a function now: one place to be wrong, and something a check
// can call, since the fixture replaces downloadExport itself. Files already on
// disk are unaffected, because the importer identifies a report by its contents.
function reportFileName(){
  return 'pillagers_run'+(P.runs||0)+'.txt';
}
function downloadExport(){
'@

SubRx @'
    a.href=url; a.download='dark_raiders_run'+P.runs+'.txt';
'@ @'
    a.href=url; a.download=reportFileName();   // v12.72: named for the game he is playing
'@

# NEW IN.
SubRx @'
  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL. Shift held while you aimed, or while you waded, laid scent behind a man who was not sprinting, and everything on patrol within 170 units follows that scent. You were being hunted along a trail you never made.',
'@ @'
  'AIMING AND WADING NO LONGER LEAVE A SPRINT TRAIL. Shift held while you aimed, or while you waded, laid scent behind a man who was not sprinting, and everything on patrol within 170 units follows that scent. You were being hunted along a trail you never made.',
  'YOUR RUN REPORT IS NAMED AFTER THIS GAME. The file the game saves to your Downloads still carried the old project name, which is the one place the rename was missed and the only one that leaves the browser. Reports you already have still load: they are read by their contents, not their name.',
'@

# STAMPS.
SubRx @'
var VER='12.71';
'@ @'
var VER='12.72';
'@
SubRx @'
var WHATSNEW_VER='12.71';
'@ @'
var WHATSNEW_VER='12.72';
'@
$cnt=([regex]::Matches($s,"now:'v12\.71:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.71 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.71:[^']*'",{ param($m) "now:'v12.72: from the 2026-09-08 first-hour audit, and only half of what that finding claimed. The half I confirmed by reading: the game was renamed, every screen says PILLAGERS, the tab and the Undercroft brand and the report header and the importer that refuses a file by saying it is not a Pillagers run report, and one string was missed. It is the worst one to miss, because it is the only one that leaves the browser: the name of the file dropped into his Downloads. A friend opening the alpha finishes a raid and finds a file on their disk named after a game they have never heard of, and that is the same file they are asked to send back, so the collector has been receiving reports named for a project that no longer exists. It was the only occurrence of that name left in the whole file. The name is built by a function now rather than written at the point of use, so there is one place to be wrong and something a check can call, which matters because the fixture replaces the download itself and no check could otherwise see it. Nothing already on disk stops working, because the importer identifies a report by its contents. The half of the finding I did NOT build: it said the Settings words promise a report every second raid while the code drops one after the first. The Settings words say only that closing the question keeps the reports in his Downloads, and the first drop of a session is deliberate, with a comment beside it recording that when the drop was unreachable six raids produced one saved file and five silently lost. Check 12.72 asks the naming function for a name and requires it to carry the name of this game and not the retired one, which it can do without reading the page at all because the name now comes from a function, with a control that the number in the name still follows the run count so every report does not overwrite the last; fails on v12.71.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
