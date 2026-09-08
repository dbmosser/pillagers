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

# HIS ORDER, 2026-09-08: "Make the default setting for machines 'few' and the
# default setting for 'Heat when you call for extraction' to 'light'". These are
# dials, and his own standing rule is that dials do not move before alpha; he
# moved these two himself, so they move. Nothing else in the table is touched.
#
# The two rows he named carry these values, read straight off the Settings table
# rather than invented here: Machines / Few is nSentry 12, nCrawler 20 and
# crawlerPerHouse 1.5, and Heat / Light is siegeVol 0.6. Setting the same three
# numbers in the defaults is what makes a fresh profile open on Few, and the
# same one number is what makes it open on Light, so the row he sees ticked is
# the row he asked for.
SubRx @'
nSentry:20,nCrawler:34
'@ @'
nSentry:12,nCrawler:20
'@
SubRx @'
crewSpread:1,crawlerPerHouse:2.5
'@ @'
crewSpread:1,crawlerPerHouse:1.5
'@
SubRx @'
siegePull:0.5,siegeVol:1,siegeEcho:1
'@ @'
siegePull:0.5,siegeVol:0.6,siegeEcho:1
'@

# AND THE ROW HAS TO AGREE WITH ITSELF. Each Settings row carries the index of
# its own default, and the button is drawn in amber when the live dials sit
# anywhere else, which is how he can see at a glance that he has changed
# something. Moving the numbers without moving these two would have drawn Few
# and Light in the colour that means "not the default", every time, for ever.
SubRx @'
     {n:'Few',      cfg:{nSentry:12, nCrawler:20, crawlerPerHouse:1.5}}
   ], def:1},
'@ @'
     {n:'Few',      cfg:{nSentry:12, nCrawler:20, crawlerPerHouse:1.5}}
   ], def:2},
'@
SubRx @'
     {n:'Light',    cfg:{siegeVol:0.6}}
   ], def:1}
'@ @'
     {n:'Light',    cfg:{siegeVol:0.6}}
   ], def:2}
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A NEW PROFILE NOW STARTS ON FEWER MACHINES AND A LIGHTER EXTRACTION. Both are still in Settings and both still go all the way up; only where they start has moved.',
'@

# STAMPS.
SubRx @'
var VER='12.28';
'@ @'
var VER='12.34';
'@
SubRx @'
var WHATSNEW_VER='12.28';
'@ @'
var WHATSNEW_VER='12.34';
'@
$cnt=([regex]::Matches($s,"now:'v12\.28:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.28 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.28:[^']*'",{ param($m) "now:'v12.34: his order of 2026-09-08: the default for Machines is Few and the default for Heat when you call for extraction is Light. The values are read off the Settings rows themselves rather than invented, so the row he sees ticked on a fresh profile is the row he named: Few is 12 sentries, 20 crawlers and 1.5 crawlers a house, Light is a siege volume of 0.6. These are dials, and his own rule is that dials do not move before alpha; he moved these two himself and nothing else in the table is touched. The test harness now pins the crawlers-per-house figure explicitly, because it pinned the two counts and not that one, so the world every check measures is the same world it measured yesterday. Check 12.34 requires a fresh profile to carry the Few and Light numbers and the Settings rows to render those two as the current pick, and requires the pinned world to be unmoved; fails on v12.28.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
