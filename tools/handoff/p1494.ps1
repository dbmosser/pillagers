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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 14.83 against a build at 14.93, and the card said nothing about the
# belt key fixes of v14.84 to v14.87. The words editor fixes of v14.88 to v14.93 are his tool on his machine and stay off the
# card. Two of my own card lines are rewritten in place: the first slot takes the new news, and the second merges the two older
# lines, keeping the phrases checks 14.83, 14.72, 14.60, 14.40, 14.27, 14.14 and 14.02 read. Every other line is untouched.
SubRx @'
var WHATSNEW_VER='14.83';
'@ @'
var WHATSNEW_VER='14.94';
'@
SubRx @'
  'YOUR STASH, THE SHOP AND YOUR GUNS. A controller packs from the stash with A, the stash count includes your guns, and hovering any item offers every belt key. The shop no longer asks for money for a gun you own, and the ascent question says when items are packed from your stash for you. After a raid neither gun slot names a gun you lost, and a contract gun fills an empty hand.',
  'WARDROBE, SAVES, STORMS AND A CONTROLLER ON EVERY SCREEN. SURPRISE ME takes a worn suit off and a restore code replaces your clothes too. Erasing a save erases its UNDO copy, and lightning no longer hits you through a wall or under a roof. A controller works the title screen and the pause box, in an uncalled ring the downed screen offers the call, and key 1 picks up the gun bound to it.',
'@ @'
  'YOUR BELT KEYS AND YOUR GUNS. A heal on a key no longer stops Medical using your other heals, a key on the gun in your hands survives an extraction, and a drag on the belt in a raid keeps your keys for things you left at home. The Undercroft belt counts the grenades you packed. After a raid neither gun slot names a gun you lost, and a contract gun fills an empty hand.',
  'STASH, SHOP, WARDROBE, SAVES, STORMS AND CONTROLLERS. A controller packs from the stash with A, and the shop no longer asks for money for a gun you own. SURPRISE ME takes a worn suit off, and erasing a save erases its UNDO copy. Lightning no longer hits you through a wall or under a roof. A controller works the title screen and the pause box, in an uncalled ring the downed screen offers the call, and key 1 picks up the gun bound to it.',
'@
SubRx @'
var VER='14.93';
'@ @'
var VER='14.94';
'@

$pat = "(?m)^  now:'v14\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.94: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 14.83 against 14.93, and the card said nothing about the belt key fixes of v14.84 to v14.87; the words editor fixes are his tool and stay off the card. Two of my own card lines are rewritten in place: the first names the new news and the second merges the two older lines, keeping what checks 14.83, 14.72, 14.60, 14.40, 14.27, 14.14 and 14.02 read, and WHATSNEW_VER moves to 14.94. Check 14.94 requires the card current and naming the belt key news; it fails on v14.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
