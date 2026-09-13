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

# HIS RULING PUT THE PACK GUNS IN THE STASH, AND THE LAST SCREEN BEFORE THE LIFT SAID
# HE WAS GOING UP WITH A LOANER WITHOUT SAYING HE OWNED A GUN.
#
# Since v13.29 a new player's welcome pack guns sit in his stash as items, and nothing
# is equipped. The lift's E act opens the sector page, and its kit box reads "Going up
# with: a gun issued at the lift". That is true, and it is the last word before the
# loadout question, whose two answers both go straight up. buildRaid takes the gun in
# his hands only from the equipped slot, so he climbs with a loaner while two guns of
# his own wait in the stash, and nothing on the way says so.
#
# THE PATH THAT WORKS ALREADY EXISTS: the stash item menu has "Equip as your gun",
# which moves the gun into the armoury and equips it. The kit box now names it, only
# when nothing is equipped and a usable gun is in the stash, in its own line so it is
# never joined onto the sentence above it. It names the menu choice rather than
# right-click, because a controller opens the same menu another way.
#
# PARKED FIRST ATTEMPT: the same line was first added to the ascent check screen,
# which nothing in the game opens any more. See START-HERE.
SubRx @'
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'a gun issued at the lift');
'@ @'
  var line='<b>Going up with:</b> '+(w?escHtml(w.name):'a gun issued at the lift');
  // v13.31: since his ruling the pack guns wait in the stash with nothing equipped.
  // Say he owns one, and how to take it, on the last screen before the lift.
  if(!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; }))
    line+='<div style="margin-top:5px">You have a gun of your own in your stash. To take it up, close this and choose Equip as your gun on it at the stash.</div>';
'@

SubRx @'
var VER='13.30';
'@ @'
var VER='13.31';
'@

$pat = "(?m)^  now:'v13\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.31: HIS RULING PUT THE PACK GUNS IN THE STASH AND THE LAST SCREEN BEFORE THE LIFT DID NOT SAY SO. Since v13.29 a new player welcome pack guns sit in his stash as items with nothing equipped. The lift opens the sector page, whose kit box reads Going up with: a gun issued at the lift, and that is the last word before the loadout question, whose two answers both go straight up. buildRaid takes the gun in his hands only from the equipped slot, so he climbed with a loaner while two guns of his own waited in the stash. The stash item menu already has Equip as your gun. The kit box now names it, only when nothing is equipped and a usable gun is in the stash, in its own line, naming the menu choice rather than right-click so it holds on a controller. A first attempt put this line on the ascent check screen and was parked before commit: nothing in the game opens that screen any more, and its check passed only by drawing the screen itself. Check 13.31 draws the sector page through renderSector, the call the lift makes, for a player with nothing equipped, once with a gun in his stash and once without, requires the kit box to name Equip as your gun only in the first case, and fails on v13.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
