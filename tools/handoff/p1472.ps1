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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 14.60 against a build at 14.71, four builds from the fifteen the
# card checks allow, and the card said nothing about the wardrobe, belt key and backpack fixes of v14.61 to v14.71. Two of my
# own card lines are rewritten in place: the first slot takes the new news, and the second merges the two older lines,
# keeping the phrases checks 14.60, 14.40, 14.27, 14.14 and 14.02 read. Every other line is untouched.
SubRx @'
var WHATSNEW_VER='14.60';
'@ @'
var WHATSNEW_VER='14.72';
'@
SubRx @'
  'YOUR SAVES, YOUR BACKPACK AND YOUR CRASH REPORTS. Erasing a save erases its UNDO copy, and a save the game cannot read is listed as UNREADABLE instead of being replaced. The backpack no longer opens while you are down or keeps a drag after a raid ends, and up and down reach every stack in it. A crash repeating every frame is one entry in your run report, and Clear recorder clears old crashes too.',
  'STORMS, A CONTROLLER ON EVERY SCREEN AND YOUR BELT KEYS. Lightning no longer hits you through a wall or under a roof, and a noise near the Peddler no longer leaves the threat sound playing. A controller now works the title screen and the pause box, and in an uncalled ring the downed screen offers the call. A second hire does not eat the first fee, and key 1 picks up the gun bound to it.',
'@ @'
  'YOUR WARDROBE, YOUR BACKPACK AND THE WEATHER. A restore code now replaces your clothes and saved looks too, a saved look is worn whole, and SURPRISE ME takes a worn suit off. Pillagers no longer wear the Spartan Helmet or the Ghost Mask. A click that slips off a belt key no longer unbinds it, a second copy of the gun in your hands shows in your backpack, and the weather hint no longer promises a bonus Blackout Protocol cancels.',
  'SAVES, STORMS, A CONTROLLER ON EVERY SCREEN AND YOUR BELT KEYS. Erasing a save erases its UNDO copy, and lightning no longer hits you through a wall or under a roof. A controller now works the title screen and the pause box, and in an uncalled ring the downed screen offers the call. A second hire does not eat the first fee, and key 1 picks up the gun bound to it.',
'@
SubRx @'
var VER='14.71';
'@ @'
var VER='14.72';
'@

$pat = "(?m)^  now:'v14\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.72: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 14.60 against 14.71, and the card said nothing about the wardrobe, belt key and backpack fixes of v14.61 to v14.71. Two of my own card lines are rewritten in place: the first names the new news and the second merges the two older lines, keeping what checks 14.60, 14.40, 14.27, 14.14 and 14.02 read, and WHATSNEW_VER moves to 14.72. Check 14.72 requires the card current and naming the wardrobe news; it fails on v14.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
