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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 14.94 against a build at 15.11, past the fifteen builds the card checks
# allow, so every card check went red in the corpus on v15.11, and the card said nothing about the fixes of v14.95 to v15.11. Two of
# my own card lines are rewritten in place: the first slot takes the new news, and the second merges the two older lines, keeping
# the phrases checks 14.94, 14.83, 14.72, 14.60, 14.40, 14.27, 14.14 and 14.02 read. Every other line is untouched.
SubRx @'
var WHATSNEW_VER='14.94';
'@ @'
var WHATSNEW_VER='15.12';
'@
SubRx @'
  'YOUR BELT KEYS AND YOUR GUNS. A heal on a key no longer stops Medical using your other heals, a key on the gun in your hands survives an extraction, and a drag on the belt in a raid keeps your keys for things you left at home. The Undercroft belt counts the grenades you packed. After a raid neither gun slot names a gun you lost, and a contract gun fills an empty hand.',
  'STASH, SHOP, WARDROBE, SAVES, STORMS AND CONTROLLERS. A controller packs from the stash with A, and the shop no longer asks for money for a gun you own. SURPRISE ME takes a worn suit off, and erasing a save erases its UNDO copy. Lightning no longer hits you through a wall or under a roof. A controller works the title screen and the pause box, in an uncalled ring the downed screen offers the call, and key 1 picks up the gun bound to it.',
'@ @'
  'YOUR GRENADES, WIRT AND LEAVING A RAID. A cooked Frag Charge keeps burning through a roll, Q only picks grenades on your belt, and a grenade a pillager pays for a revive can be thrown. The gun hover shows the real rate of fire, and the offer at Wirt counts down while you watch. The card after an abandon shows the XP it cost, and a note typed in the pause box is kept when you quit at once.',
  'BELT KEYS, STASH, WARDROBE, SAVES, STORMS AND CONTROLLERS. A heal on a key no longer stops Medical using your other heals, and a controller packs from the stash with A. SURPRISE ME takes a worn suit off, and erasing a save erases its UNDO copy. Lightning no longer hits you through a wall or under a roof. A controller works the title screen and the pause box, in an uncalled ring the downed screen offers the call, and key 1 picks up the gun bound to it.',
'@
SubRx @'
var VER='15.11';
'@ @'
var VER='15.12';
'@

$pat = "(?m)^  now:'v15\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.12: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 14.94 against 15.11, past the fifteen builds the card checks allow, so every card check went red in the corpus, and the card said nothing about the fixes of v14.95 to v15.11. Two of my own card lines are rewritten in place: the first names the new news and the second merges the two older lines, keeping what checks 14.94, 14.83, 14.72, 14.60, 14.40, 14.27, 14.14 and 14.02 read, and WHATSNEW_VER moves to 15.12. Check 15.12 requires the card current and naming the grenade news; it fails on v15.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
