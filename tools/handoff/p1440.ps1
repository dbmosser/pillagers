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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 14.27 against a build at 14.39, and the card said nothing about the
# storm, sound, reward and save fixes of v14.28 to v14.39. Two of my own card lines are rewritten in place: the first slot takes
# the new news, and the second merges the two older lines, keeping the phrases checks 14.27, 14.14 and 14.02 read. The third
# line, the stash entry inside the thirteen the card draws (check 13.34), and every line of his are untouched.
SubRx @'
var WHATSNEW_VER='14.27';
'@ @'
var WHATSNEW_VER='14.40';
'@
SubRx @'
  'A CONTROLLER ON EVERY SCREEN, AND THE UNDERCROFT MENUS. A controller now works the title screen and the pause box, keeps its place when a panel redraws, and does not fire when you press ASCEND, open the map or browse your backpack. The stall no longer shuts itself or sells your backpack on a held button. In the Undercroft a second hire does not eat the first fee, a click on a filled belt key clears it, and a gun dropped from the armoury onto the stash goes into the stash.',
  'SAVES, THE DOWNED SCREEN AND YOUR BELT KEYS. A gun in your backpack comes back if the page closes mid-raid, a restore code keeps the character it replaced for UNDO, and going down closes the map, the backpack and a search; in an uncalled ring the downed screen offers the call. What you buy at the stall is not loot you found, key 1 picks up the gun bound to it, and the free pistol carries its own two magazines.',
'@ @'
  'STORMS, SOUND AND REWARDS. Lightning no longer hits you through a wall or under a roof, the flash no longer sticks after a storm passes, and a noise near the Peddler no longer leaves the threat sound playing at his stall. A reward gun claimed with nothing in hand becomes your gun, your level is right the moment a save loads, the game goes quiet in a hidden tab, and a look you wear or buy makes a sound.',
  'A CONTROLLER ON EVERY SCREEN, SAVES AND YOUR BELT KEYS. A controller now works the title screen and the pause box and does not fire when you press ASCEND. A gun in your backpack comes back if the page closes mid-raid, and in an uncalled ring the downed screen offers the call. A second hire does not eat the first fee, a click on a filled belt key clears it, and key 1 picks up the gun bound to it.',
'@
SubRx @'
var VER='14.39';
'@ @'
var VER='14.40';
'@

$pat = "(?m)^  now:'v14\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.40: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 14.27 against 14.39 and the card said nothing about the storm, sound, reward and save fixes of v14.28 to v14.39. Two of my own card lines are rewritten in place: the first names the new news and the second merges the two older lines, keeping what checks 14.27, 14.14 and 14.02 read, and WHATSNEW_VER moves to 14.40. Check 14.40 requires the card current and naming the lightning news, with every card check still holding; it fails on v14.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
