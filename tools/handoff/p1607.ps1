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

# THE WHAT IS NEW CARD IS CURRENT AGAIN (every ~10 builds; WHATSNEW_VER within 0.15 of VER).

SubRx @'
var WHATSNEW_VER='15.92';
'@ @'
var WHATSNEW_VER='16.07';
'@

SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. In a party only the host takes the lift, and everyone goes up with them. One of you searches a box at a time and the loot goes to whoever searched it. Hold E beside a downed teammate to pull them up. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves, the run ends as abandoned for everyone. Pause no longer stops the world in co-op, and a lightning flash shows you to them from farther off.',
'@

SubRx @'
var VER='16.06';
'@ @'
var VER='16.07';
'@

$pat = "(?m)^  now:'v16\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.07: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.92 against 16.06. A new card line after the alpha line says what co-op gained since: the party goes up together, loot per player, teammate revives, one clock, sky and set of extraction points, the host leaving ends the run, pause in co-op, and the lightning flash. Every older line is kept as it was. No number moved. Check 16.07 fails on v16.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
