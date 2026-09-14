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

# HIS RULINGS OF 2026-09-13: too many bots on the lightest setting. Machines Few means
# what it says (the per-house floor no longer lifts crawlers past it), and a new
# pillager starts on Few pillagers with smaller waves. The corpus pins Standard in
# __pinDefaults, so no fingerprint moves.
SubRx @'
     {n:'Many',     cfg:{nRaider:15, raiderWaves:1}},
     {n:'Standard', cfg:{nRaider:10, raiderWaves:1}},
     {n:'Few',      cfg:{nRaider:5,  raiderWaves:1}},
'@ @'
     // v13.43, HIS RULING: Few is the default and brings smaller waves too.
     {n:'Many',     cfg:{nRaider:15, raiderWaves:1, raiderWaveCap:8, raiderFloorN:4}},
     {n:'Standard', cfg:{nRaider:10, raiderWaves:1, raiderWaveCap:8, raiderFloorN:4}},
     {n:'Few',      cfg:{nRaider:5,  raiderWaves:1, raiderWaveCap:4, raiderFloorN:2}},
'@
SubRx @'
     {n:'None',     cfg:{nRaider:0, raiderWaves:0}}
   ], def:1},
'@ @'
     {n:'None',     cfg:{nRaider:0, raiderWaves:0}}
   ], def:2},
'@
SubRx @'
     {n:'Few',      cfg:{nSentry:12, nCrawler:20, crawlerPerHouse:1.5}}
'@ @'
     {n:'Few',      cfg:{nSentry:12, nCrawler:20, crawlerPerHouse:0}}   // v13.43, HIS RULING: Few means the count it names; no house floor lifts it
'@
SubRx @'
nSentry:12,nCrawler:20,nRaider:10,nSnitch:5,
'@ @'
nSentry:12,nCrawler:20,nRaider:5,nSnitch:5,
'@
SubRx @'
raiderWaveCap:8,raiderWaveMin:12,raiderWaveGap:60,raiderFloorN:4,
'@ @'
raiderWaveCap:4,raiderWaveMin:12,raiderWaveGap:60,raiderFloorN:2,
'@
SubRx @'
crawlerPerHouse:1.5,houseFill:0.72,
'@ @'
crawlerPerHouse:0,houseFill:0.72,
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'FEWER ENEMIES BY DEFAULT. Few machines now means the number it says: houses no longer push crawlers past it. Few pillagers is the new default, with smaller reinforcement waves. A character that never changed these settings moves to Few too.',
'@
SubRx @'
var WHATSNEW_VER='13.42';
'@ @'
var WHATSNEW_VER='13.43';
'@
SubRx @'
var VER='13.42';
'@ @'
var VER='13.43';
'@

$pat = "(?m)^  now:'v13\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.43: FEWER ENEMIES BY DEFAULT. His rulings of 2026-09-13: too many bots on the lightest setting; Few machines means what it says, and a new pillager starts on Few pillagers. Machines Few and DEF carry crawlerPerHouse 0, so the house floor no longer lifts crawlers past the count (his last run: dial 20, built 29). Pillagers default to Few, which now also carries raiderWaveCap 4 and raiderFloorN 2; Standard and Many carry 8 and 4. A profile that never picked these rows moves with the defaults. The corpus pins Standard, so no fingerprint moves. Check 13.43 builds COLD STORAGE from a fresh profile by day and requires both rows on Few, at most 20 crawlers and 5 pillagers, and more crawlers when the old floor is put back; it fails on v13.42. Check 12.29 repaired',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
