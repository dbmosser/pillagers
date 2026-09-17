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

# THE WHAT IS NEW CARD, KEPT CURRENT. WHATSNEW_VER stood at 15.12 against a build at 15.26, one build from the fifteen the card checks
# allow, and the card said nothing about his healing ruling, the raid clock siren, the belt gun slot or the hire fixes. Two of my own
# card lines are rewritten in place: the first slot takes the new news, and the second merges the two older lines, keeping the phrases
# checks 15.12, 14.94, 14.83, 14.72, 14.60, 14.40, 14.27, 14.14 and 14.02 read. Every other line is untouched.
SubRx @'
var WHATSNEW_VER='15.12';
'@ @'
var WHATSNEW_VER='15.27';
'@
SubRx @'
  'YOUR GRENADES, WIRT AND LEAVING A RAID. A cooked Frag Charge keeps burning through a roll, Q only picks grenades on your belt, and a grenade a pillager pays for a revive can be thrown. The gun hover shows the real rate of fire, and the offer at Wirt counts down while you watch. The card after an abandon shows the XP it cost, and a note typed in the pause box is kept when you quit at once.',
  'BELT KEYS, STASH, WARDROBE, SAVES, STORMS AND CONTROLLERS. A heal on a key no longer stops Medical using your other heals, and a controller packs from the stash with A. SURPRISE ME takes a worn suit off, and erasing a save erases its UNDO copy. Lightning no longer hits you through a wall or under a roof. A controller works the title screen and the pause box, in an uncalled ring the downed screen offers the call, and key 1 picks up the gun bound to it.',
'@ @'
  'HEALING, THE RAID CLOCK AND YOUR HIRE. Bandages and resting stop at 85, and only a Medkit takes you past 85. The raid clock has its own siren before it runs out, a raid keeps the clock it started with, and gun slot 1 no longer goes black. Your hire leaves the crate you are searching alone and never turns up as a stranger.',
  'GRENADES, BELT KEYS, STASH, WARDROBE, SAVES AND STORMS. A cooked Frag Charge keeps burning through a roll, a heal on a key no longer stops Medical using your other heals, and a controller packs from the stash with A. SURPRISE ME takes a worn suit off, erasing a save erases its UNDO copy, and lightning no longer hits you through a wall. A controller works the title screen and the pause box, in an uncalled ring the downed screen offers the call, and key 1 picks up the gun bound to it.',
'@
SubRx @'
var VER='15.26';
'@ @'
var VER='15.27';
'@

$pat = "(?m)^  now:'v15\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.27: THE WHAT IS NEW CARD IS CURRENT AGAIN. WHATSNEW_VER stood at 15.12 against 15.26, one build from the fifteen the card checks allow, and the card said nothing about the healing ruling, the raid clock siren, the belt gun slot or the hire fixes. Two of my own card lines are rewritten in place, keeping what checks 15.12, 14.94, 14.83, 14.72, 14.60, 14.40, 14.27, 14.14 and 14.02 read, and WHATSNEW_VER moves to 15.27. Check 15.27 requires the card current and naming the healing news; it fails on v15.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
