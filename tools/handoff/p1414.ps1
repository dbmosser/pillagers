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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 14.02 against a build at 14.13 and the card said nothing about the saves, the
# downed screen or the HUD fixes of v14.03 to v14.13. Three of my own card lines are rewritten in the same three slots, newest first, so
# the stash entry stays inside the thirteen lines the card draws (check 13.34); the Medkit and controller lines are kept; none of his
# edited lines is touched; the words checks 13.66 and 12.48 look for or forbid are kept in or left out.
SubRx @'
var WHATSNEW_VER='14.02';
'@ @'
var WHATSNEW_VER='14.14';
'@
SubRx @'
  'THE STALL, YOUR HIRE AND YOUR BELT KEYS. What you buy at the stall is not loot you found, your hire is never also a stranger on the map, and an enemy charge does not turn him on you. A belt key never points at something you left behind, key 1 picks up the gun bound to it, and the free pistol carries its own two magazines.',
  'NOTHING FROM NOTHING, AND A FAIRER FIGHT. A pile you drop earns no hot zone bonus and never restocks, a dropped gun comes back with the rounds it had, a revived pillager pays his gun once, and issued Bandages stay issued. Nothing happens in the death fade, a burst stops when you swap guns, a roll no longer freezes a reload, and you cannot punch with a grenade cooking in your hand.',
  'YOUR HIRE, THE PEDDLER AND GETTING OUT. Your hire shoots the pillagers and not you, SELL BACKPACK leaves your tactical belt alone, and going down shuts the stall. Nothing on your belt is used while you are down, a second copy of a gun you own is kept when you extract, and the clock lets you finish holding E in a landed extraction.',
'@ @'
  'SAVES, THE DOWNED SCREEN AND WHAT THE HUD TELLS YOU. A gun you put in your backpack comes back if the page closes mid-raid, a restore code replaces the whole old character and keeps the one it replaced for UNDO, and a repeating error no longer stutters the game. Going down closes the map, the backpack, a search and the door prompt, and in an uncalled ring the downed screen offers the call.',
  'THE STALL, YOUR HIRE AND YOUR BELT KEYS. What you buy at the stall is not loot you found, your hire is never also a stranger on the map, and an enemy charge does not turn him on you. A belt key never points at something you left behind, key 1 picks up the gun bound to it, and the free pistol carries its own two magazines.',
  'NOTHING FROM NOTHING, AND A FAIRER FIGHT. A pile you drop earns no hot zone bonus and never restocks, issued Bandages stay issued, your hire shoots the pillagers and not you, and going down shuts the stall. Nothing on your belt is used while you are down, a burst stops when you swap guns, and you cannot punch with a grenade cooking in your hand.',
'@
SubRx @'
var VER='14.13';
'@ @'
var VER='14.14';
'@

$pat = "(?m)^  now:'v14\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.14: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 14.02 against 14.13 and the card said nothing about the saves, downed screen and HUD fixes of v14.03 to v14.13. Three of my own card lines are rewritten in the same three slots, newest first, keeping the stash entry inside the thirteen the card draws and his edited lines untouched, and WHATSNEW_VER moves to 14.14. Check 14.14 requires the card current and naming the uncalled ring news, with every card check still holding; it fails on v14.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
