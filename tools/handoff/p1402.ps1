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

# THE WHAT IS NEW CARD, KEPT CURRENT BEFORE IT GOES STALE. WHATSNEW_VER stood at 13.87 against a build at 14.01,
# one build short of the fifteen-build gate that checks 9.19 and 10.38 hold it to, and it said nothing about
# v13.88 to v14.01. Three of my own card lines are rewritten in the same three slots, newest first, so the
# stash entry stays inside the thirteen lines the card draws (check 13.34); the Medkit line and the
# controller line are kept; none of his edited lines is touched.
SubRx @'
var WHATSNEW_VER='13.87';
'@ @'
var WHATSNEW_VER='14.02';
'@
SubRx @'
  'NOTHING FROM NOTHING, AND A FAIRER FIGHT. A pile you drop earns no hot zone bonus and never restocks, a dropped gun comes back with the rounds it had, and a found gun in slot 2 puts the old one in your backpack. Nothing happens in the death fade, a burst stops when you swap guns, a roll no longer freezes a reload, and you cannot punch with a grenade cooking in your hand.',
  'YOUR HIRE AND THE PEDDLER. Your hire shoots the pillagers and not you, and your own charge does not kill him. SELL BACKPACK leaves your tactical belt and the issued Bandages alone, going down shuts the stall, and on a controller X walks away from it.',
  'GOING DOWN AND GETTING OUT. Nothing on your belt is used while you are down, and a drink keeps wearing off. A second copy of a gun you own is kept when you extract, the clock lets you finish holding E in a landed extraction, and backing out at once keeps a gun you put in your backpack.',
'@ @'
  'THE STALL, YOUR HIRE AND YOUR BELT KEYS. What you buy at the stall is not loot you found, your hire is never also a stranger on the map, and an enemy charge does not turn him on you. A belt key never points at something you left behind, key 1 picks up the gun bound to it, and the free pistol carries its own two magazines.',
  'NOTHING FROM NOTHING, AND A FAIRER FIGHT. A pile you drop earns no hot zone bonus and never restocks, a dropped gun comes back with the rounds it had, a revived pillager pays his gun once, and issued Bandages stay issued. Nothing happens in the death fade, a burst stops when you swap guns, a roll no longer freezes a reload, and you cannot punch with a grenade cooking in your hand.',
  'YOUR HIRE, THE PEDDLER AND GETTING OUT. Your hire shoots the pillagers and not you, SELL BACKPACK leaves your tactical belt alone, and going down shuts the stall. Nothing on your belt is used while you are down, a second copy of a gun you own is kept when you extract, and the clock lets you finish holding E in a landed extraction.',
'@
SubRx @'
var VER='14.01';
'@ @'
var VER='14.02';
'@

$pat = "(?m)^  now:'v14\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.02: THE WHAT IS NEW CARD IS CURRENT AGAIN, BEFORE IT GOES STALE. WHATSNEW_VER stood at 13.87 against 14.01, one build short of the fifteen-build gate held by checks 9.19 and 10.38, and the card said nothing about v13.88 to v14.01. Three of my own card lines are rewritten in the same three slots, newest first, keeping the stash entry inside the thirteen the card draws; his edited lines are untouched and WHATSNEW_VER moves to 14.02. Check 14.02 requires the card current and naming the stall and belt key news, with every card check still holding; it fails on v14.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
