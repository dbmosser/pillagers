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

# THE WHAT IS NEW CARD HAD FALLEN TWENTY BUILDS BEHIND. It stood at v13.45 against v13.65,
# past the fifteen-build gate that checks 9.19 and 10.38 hold it to, and it said nothing about
# the controller, the contracts, hazard pay, the restore code, the cooked grenade or the belt
# on the floor. The news goes in newest first under the alpha line; nothing already on the card
# is reworded.
SubRx @'
var WHATSNEW_VER='13.45';
'@ @'
var WHATSNEW_VER='13.66';
'@
SubRx @'
  'FEWER ENEMIES BY DEFAULT. Few machines now means
'@ @'
  'A MEDKIT IS NEVER WASTED OR WRONGLY REFUSED. At full health it is refused even straight after a Bandage, and a Medkit on its own belt key works while Bandages are still healing you, as the Medical cell always did.',
  'NOTHING ON YOUR BELT IS USED WHILE YOU ARE DOWN. A Medkit used on the floor never healed you and was gone. The game now tells you it cannot be done.',
  'A GRENADE YOU ARE COOKING STAYS IN YOUR HAND. Switching to your gun used to fire the gun and stop the fuse, and the throw key threw a second grenade. Now the fuse keeps counting, the gun stays quiet, and you throw the one in your hand first.',
  'A RESTORE CODE REPLACES YOUR WHOLE SAVE. Your backpack, belt and intel from before no longer mix into the character you restored.',
  'BUYING THE LOT FROM WIRT NEVER LOCKS YOU OUT OF THE NEXT ONE, even when the lot changes while his card is open.',
  'CRAFTING TAKES FROM YOUR STASH FIRST, so it no longer breaks up what you packed for the next raid.',
  'ONE GUN CANNOT BE IN BOTH HANDS. Equipping a gun as your main gun takes it out of your second slot.',
  'CONTRACTS AND HAZARD PAY COUNT ONLY WHAT THE RUN FOUND. What you carried in no longer finishes an item contract or earns hazard pay, issued Bandages are not banked as finds, a contract finished before you died stays in your run report, and the XP on the card is the XP you get at every distance.',
  'A CONTROLLER WORKS ON THE UNDERCROFT FLOOR AND IN EVERY RAID. View opens your backpack and Menu pauses, you can search and call for extraction from inside an extraction point, you can trade with the peddler, and the prompts name your buttons.',
  'THE MENUS FIT A 1280 BY 720 WINDOW, the size itch opens the game at.',
  'FEWER ENEMIES BY DEFAULT. Few machines now means
'@
SubRx @'
var VER='13.65';
'@ @'
var VER='13.66';
'@

$pat = "(?m)^  now:'v13\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.66: THE WHAT IS NEW CARD IS CURRENT AGAIN. The full corpus on v13.61 failed checks 9.19 and 10.38: the card stood at v13.45, past the fifteen-build gate, and said nothing about the controller, contracts, hazard pay, the restore code, the cooked grenade or the belt on the floor. Ten lines go in newest first under the alpha line, nothing already on the card is reworded, and WHATSNEW_VER moves to 13.66. Check 13.66 requires the card within fifteen builds and naming the cooked grenade and the belt while down; it fails on v13.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
