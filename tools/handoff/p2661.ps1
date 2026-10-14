$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE WHAT IS NEW CARD NAMES THE COMBAT FEEL BUILDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='26.45';
'@ @'
var WHATSNEW_VER='26.61';
'@

SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'COMBAT FEEL. Heavy rounds stop what they hit and the Lance kicks. R again in the bright part of the reload ring finishes it, +15% damage. The Support MG spins up.',
'@

SubRx @'
  'BELT KEYS. U and G pick and throw grenades, J and H pick and use heals, 5 to 9 use a slot at once. Crouch still to creep back health.',
  'NEW BELT. Four gun keys, two throwables, two medical and an armour key. A better gun swaps out your weakest. DEMO extraction and siege now match CAREER.',
  'HOLD KEYS. Hold H for a plate, hold Alt for the raid status, middle mouse pings. Crouching is the quiet walk, and no voice calls out anymore.',
'@ @'
  'HOLD KEYS. Hold H for a plate, hold Alt for the raid status, middle mouse pings. Crouching is the quiet walk, and no voice calls out anymore.',
'@

SubRx @'
var VER='26.60';
'@ @'
var VER='26.61';
'@

$pat = "(?m)^  now:'v26\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.61: The what is new card names the combat feel builds and drops the retired belt lines. Check 26.61 fails on v26.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
