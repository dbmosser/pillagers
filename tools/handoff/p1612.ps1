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

# THE WHAT IS NEW CARD FITS AGAIN (backcheck: check 13.34 failed since v16.07; two claims were wrong).

SubRx @'
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. In a party only the host takes the lift, and everyone goes up with them. One of you searches a box at a time and the loot goes to whoever searched it. Hold E beside a downed teammate to pull them up. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves, the run ends as abandoned for everyone. Pause no longer stops the world in co-op, and a lightning flash shows you to them from farther off.',
  'YOUR PARTY FIGHTS ONE SET OF PILLAGERS. The mode menu opens a second window for your other screen with its own controller and sound, the party ascends together and sees each other up top, and the pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, and only a Medkit takes you past 85.',
'@ @'
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. The mode menu opens a second window for your other screen with its own controller, and world sound plays from one of the two. In a party only the host takes the lift: the party ascends together and sees each other up top. The pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. One of you searches a box at a time and the loot goes to whoever searched it. Hold E beside a downed teammate to pull them up. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves, the run ends as abandoned for everyone. Pause no longer stops the world in co-op. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, a lightning flash shows you to the enemy from farther off, and only a Medkit takes you past 85.',
'@

SubRx @'
var WHATSNEW_VER='16.07';
'@ @'
var WHATSNEW_VER='16.12';
'@

SubRx @'
var VER='16.11';
'@ @'
var VER='16.12';
'@

$pat = "(?m)^  now:'v16\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.12: THE WHAT IS NEW CARD FITS AGAIN AND SAYS WHAT IS TRUE. The v16.07 line pushed the welcome pack entry off the thirteen the card draws, so check 13.34 failed. The co-op line and the party line are one entry now. It no longer says the second window has its own sound (world sound plays from one window) and says the lightning flash shows you to the enemy. No number moved. Check 16.12 fails on v16.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
