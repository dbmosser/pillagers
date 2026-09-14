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

# v13.87, second part: THE WHAT IS NEW CARD, 21 BUILDS BEHIND. WHATSNEW_VER stood at 13.66 against
# a build at 13.87. Four of the five lines v13.66 wrote (mine, not his edited lines) are rewritten
# to cover v13.53 to v13.87 in the same four slots, so the stash entry stays inside the thirteen
# lines the card draws (check 13.34). The controller line is kept as it was.
SubRx @'
var WHATSNEW_VER='13.66';
'@ @'
var WHATSNEW_VER='13.87';
'@
SubRx @'
  'NOTHING ON YOUR BELT IS USED WHILE YOU ARE DOWN, where a Medkit never healed you and was lost. A Medkit is also refused at full health straight after a Bandage, and one on its own belt key works while Bandages are still healing you.',
  'A GRENADE YOU ARE COOKING STAYS IN YOUR HAND. Switching to your gun no longer fires the gun or stops the fuse, and the throw key no longer throws a second grenade.',
  'IN THE UNDERCROFT: a restore code replaces your whole save, crafting takes from your stash before what you packed, one gun cannot be in both hands, and buying the lot from Wirt never locks you out of the next one.',
  'CONTRACTS AND HAZARD PAY COUNT ONLY WHAT THE RUN FOUND. What you carried in no longer finishes an item contract or earns hazard pay, issued Bandages are not banked as finds, a contract finished before you died stays in your run report, and the XP on the card is the XP you get at every distance.',
'@ @'
  'NOTHING FROM NOTHING, AND A FAIRER FIGHT. A pile you drop earns no hot zone bonus and never restocks, a dropped gun comes back with the rounds it had, and a found gun in slot 2 puts the old one in your backpack. Nothing happens in the death fade, a burst stops when you swap guns, a roll no longer freezes a reload, and you cannot punch with a grenade cooking in your hand.',
  'YOUR HIRE AND THE PEDDLER. Your hire shoots the pillagers and not you, and your own charge does not kill him. SELL BACKPACK leaves your tactical belt and the issued Bandages alone, going down shuts the stall, and on a controller X walks away from it.',
  'GOING DOWN AND GETTING OUT. Nothing on your belt is used while you are down, and a drink keeps wearing off. A second copy of a gun you own is kept when you extract, the clock lets you finish holding E in a landed extraction, and backing out at once keeps a gun you put in your backpack.',
  'HEALING, GRENADES AND CONTRACTS. A Medkit is never wasted at full health or refused on its own key, a grenade you are cooking stays in your hand, and contracts and hazard pay count only what the run found. In the Undercroft a restore code replaces your whole save and crafting takes from your stash first.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
