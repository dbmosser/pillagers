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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 15.81 against a build at 15.91, near its refresh, and the card said
# nothing about the shared pillagers (v15.80) or the loot and host rules (v15.91). Only my first card line is rewritten in place: it
# keeps the phrases checks 15.27, 15.39, 15.51, 15.61, 15.72 and 15.81 read; every other line stays.
SubRx @'
var WHATSNEW_VER='15.81';
'@ @'
var WHATSNEW_VER='15.92';
'@
SubRx @'
  'TWO PLAYERS ON ONE PC, AND CROUCHING. The title opens on a mode menu: 2 PLAYER CO-OP (SAME MACHINE) opens a second window for your other screen, pairs it by itself, gives each window its own controller and plays sound from one, and the party ascends together and sees each other up top. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, and only a Medkit takes you past 85.',
'@ @'
  'YOUR PARTY FIGHTS ONE SET OF PILLAGERS. The mode menu opens a second window for your other screen with its own controller and sound, the party ascends together and sees each other up top, and the pillagers and machines are one set for everyone: they go for whoever is nearest, your hits and kills count in your own tally, and nobody in your party can hurt you. C crouches even with Shift held when you are out of breath, a controller leaves the end of raid card with B, holding ESC or P no longer flickers the pause box, a pillager grenade sounds where it lands, and only a Medkit takes you past 85.',
'@
SubRx @'
var VER='15.91';
'@ @'
var VER='15.92';
'@

$pat = "(?m)^  now:'v15\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.92: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.81 against 15.91, near its refresh, and the card said nothing about the shared pillagers. My first card line is rewritten in place, keeping what checks 15.27, 15.39, 15.51, 15.61, 15.72 and 15.81 read, and WHATSNEW_VER moves to 15.92. Check 15.92 requires the card current and naming the shared pillagers; it fails on v15.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
