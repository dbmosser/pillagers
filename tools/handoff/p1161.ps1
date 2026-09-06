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

# WITH OTHER PILLAGERS SET TO NONE, THE EXTRACTION-HEAT ROW READ CUSTOM. The
# None option turns the waves off (v8.42) and applyGameOpts gives the pillager
# row the last word on that (v8.74). But raiderWaves:1 still rode along on the
# heat row's Heavy and Standard, so with the waves off neither option matched
# the live dials and the row showed CUSTOM in amber with the tuning-console
# hint, for a setting he had never touched. The v8.74 comment already says the
# heat row describes the RING only. So: the waves belong to the pillager row,
# on every option, and the heat row carries siegeVol alone. Every combination
# of choices lands on the same dial values as before, with one exception that
# is a fix: leaving None for Standard with the heat on Light used to leave the
# waves off (nothing wrote them back); the pillager row writes them now.
SubRx @'
     {n:'Many',     cfg:{nRaider:15}},
     {n:'Standard', cfg:{nRaider:10}},
     {n:'Few',      cfg:{nRaider:5}},
'@ @'
     // v11.61: the waves live here, with the pillagers, on every option; the
     // heat row used to carry raiderWaves:1 and read CUSTOM whenever this was None.
     {n:'Many',     cfg:{nRaider:15, raiderWaves:1}},
     {n:'Standard', cfg:{nRaider:10, raiderWaves:1}},
     {n:'Few',      cfg:{nRaider:5,  raiderWaves:1}},
'@
SubRx @'
     {n:'Heavy',    cfg:{siegeVol:1.4, raiderWaves:1}},
     {n:'Standard', cfg:{siegeVol:1,   raiderWaves:1}},
'@ @'
     {n:'Heavy',    cfg:{siegeVol:1.4}},
     {n:'Standard', cfg:{siegeVol:1}},
'@

# STAMPS.
SubRx @'
var VER='11.60';
'@ @'
var VER='11.61';
'@
SubRx @'
var WHATSNEW_VER='11.60';
'@ @'
var WHATSNEW_VER='11.61';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'SETTINGS: THE EXTRACTION-HEAT ROW NO LONGER READS CUSTOM WHEN PILLAGERS ARE OFF. It showed CUSTOM in amber, with the tuning-console hint, for a row you had never touched. Nothing about the raid changes.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.60:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.60 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.60:[^']*'",{ param($m) "now:'v11.61: with Other pillagers set to None the extraction-heat row read CUSTOM in amber with the tuning-console hint. None turns the waves off and applyGameOpts gives the pillager row the last word, but raiderWaves:1 rode along on the heat row so no option matched. The waves are on the pillager row now on every option and the heat row carries siegeVol alone; every combination lands on the same dials as before, and leaving None for Standard with the heat on Light now brings the waves back, which nothing did before. From the v11.46 audit, P2.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
