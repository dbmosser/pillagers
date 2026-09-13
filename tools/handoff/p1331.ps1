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

# HIS RULING PUT THE PACK GUNS IN THE STASH, AND THE ASCENT SCREEN DID NOT SAY HOW TO
# USE THEM.
#
# Since v13.29 a new player's welcome pack guns sit in his stash as items. The ascent
# screen warns "Going up with no gun of your own. That is allowed", and the obvious
# thing to do next is click the gun in the stash panel beside it. That click is
# "carry one": it packs the gun into the backpack as loot. buildRaid takes the gun in
# his hands ONLY from the equipped slot and issues a random starter when that is
# empty, so he climbs with his pack gun in the backpack and a loaner in his hands.
#
# THE PATH THAT WORKS ALREADY EXISTS. Every stash cell on that screen is built by
# invCell, which carries the item menu, and "Equip as your gun" on a stash gun moves
# it into the armoury and equips it. Nothing tells him it is there.
#
# THE WARNING NOW NAMES IT, AND ONLY WHEN IT APPLIES: no gun equipped and a usable gun
# in the stash. The wording names the menu choice, not right-click, because a
# controller opens the same menu another way.
#
# NOT DONE, AND HIS CALL: making a plain click on a gun equip it instead of packing it.
# That changes what a click does on every gun in the stash, including the spare he
# might want to carry up to sell, so it is a design decision rather than a fix.
SubRx @'
    W.innerHTML='<b>Going up with '+escHtml(warn.join(', '))+'.</b> That is allowed, and it is how short raids happen.'; }
'@ @'
    W.innerHTML='<b>Going up with '+escHtml(warn.join(', '))+'.</b> That is allowed, and it is how short raids happen.'+
      // v13.31: since his ruling the pack guns wait in the stash, and clicking one packs
      // it as loot. Name the choice that puts it in his hands, only when one is there.
      ((!w&&(P.stash||[]).some(function(k){ var it=ITEMS[k]; return it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]; }))
        ?' To take a gun of your own, choose Equip as your gun on one in your stash.':'');
  }
'@

SubRx @'
var VER='13.30';
'@ @'
var VER='13.31';
'@

$pat = "(?m)^  now:'v13\.30:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.31: HIS RULING PUT THE PACK GUNS IN THE STASH AND THE ASCENT SCREEN DID NOT SAY HOW TO USE THEM. Since v13.29 a new player welcome pack guns sit in his stash as items, the ascent screen warns that he is going up with no gun of his own and that this is allowed, and the obvious next move is to click the gun in the stash panel beside it. That click is carry one, which packs the gun into the backpack as loot, while buildRaid takes the gun in his hands only from the equipped slot and issues a random starter when that is empty, so he climbed with his pack gun as loot and a loaner in his hands. The path that works already exists: every stash cell on that screen is built by invCell and carries the item menu, and Equip as your gun on a stash gun moves it into the armoury and equips it, but nothing told him it was there. The warning now names that choice, and only when it applies, with no gun equipped and a usable gun in the stash; it names the menu choice rather than right-click, because a controller opens the same menu another way. Not done, and his call: making a plain click on a gun equip it instead of packing it, which would change what a click does on every stash gun including a spare he means to carry up and sell. Check 13.31 draws the ascent screen for a player with no gun equipped, once with a gun in his stash and once without, requires the warning to name Equip as your gun only in the first case, and fails on v13.30',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
