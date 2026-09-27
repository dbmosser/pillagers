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

# THE WHAT IS NEW CARD CATCHES UP ON CO-OP (card was at v16.12).

SubRx @'
  'YOUR PARTY GOES UP TOGETHER AND SHARES ONE SURFACE. The mode menu opens a second window for your other screen with its own controller, and world sound plays from one of the two. In a party only the host takes the lift: the party ascends together and sees each other up top. The pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. One of you searches a box at a time and the loot goes to whoever searched it. Hold E next to a downed teammate to revive them. The clock, the weather, the lightning and the extraction points are the same for everyone, and a beacon any of you calls comes for the party. If the host leaves the party, the run ends as abandoned for everyone; if the host extracts or dies, the rest of the party keeps playing. Pause no longer stops the world in co-op. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, a lightning flash shows you to the enemy from farther off, and only a Medkit takes you past 85.',
'@ @'
  'YOUR PARTY GOES UP TOGETHER AND PLAYS AS ONE. The mode menu opens a second window for your other screen with its own controller; player 1 sound plays on the left speaker and player 2 on the right. The party shares one surface: the same enemies, clock, weather, lightning and extraction points, and a beacon any of you calls comes for the party. Nobody in your party can hurt you. Your teammates show on the HUD with health and armour, you see their shots and damage numbers and hear their sounds, and you can use your own Bandages and plates on a teammate beside you. Hold E next to a downed teammate to revive them. One of you searches a box at a time and the loot goes to whoever searched it. The game pauses only when every player has paused. If the host extracts or dies, the host watches until the party is out; if the host leaves the party, the run ends as abandoned for everyone. The clock alarms are quieter, and a lightning flash shows you to the enemy from farther off.',
'@

SubRx @'
var WHATSNEW_VER='16.12';
'@ @'
var WHATSNEW_VER='16.33';
'@

SubRx @'
var VER='16.32';
'@ @'
var VER='16.33';
'@

$pat = "(?m)^  now:'v16\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.33: THE WHAT IS NEW CARD CATCHES UP ON CO-OP. The co-op entry now says what v16.13 to v16.33 gave the party: sound split left and right, teammate health and armour on the HUD, their shots, damage numbers and sounds, your Bandages and plates on a teammate, pause only when every player has paused, the host watching until the party is out, and quieter clock alarms. It no longer says world sound plays from one window. No number moved. Check 16.33 fails on v16.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
