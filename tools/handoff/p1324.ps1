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

# A LIVE FALSE INSTRUCTION, found by auditing every help line after today's
# control changes. Pick up a better gun with your second slot free and the game
# says the old gun "stays in hand, X swaps." X has not swapped weapons since the
# tactical belt took that job, and since v13.10 X searches what you stand on.
#
# IT IS SPOKEN, NOT DEAD CODE. autoEquipOn returns true for every human player,
# only the bot keeps the dial, and the pickup summary says _gunLine whenever it is
# set. So every player who finds a better gun with the second slot free is told to
# press a key that does something else, at the exact moment he wants the new gun.
#
# CHECK v12.14 NEVER COULD HAVE CAUGHT IT: it took "X swaps" off the controls card on these same grounds, and guards that text against
# "X swaps", and this is a different string, built in the pickup branch.
#
# THE FIX NAMES THE REAL SWAP. Selecting the stowed gun on the tactical belt calls
# swapGuns, which is how a keyboard player brings a second gun up now.
SubRx @'
          _gunLine=found.name+' to your empty slot. '+p.wep.name+' stays in hand, X swaps.';
'@ @'
          // v13.24: it said "X swaps", and X searches. Selecting the stowed gun on
          // the tactical belt is what swaps now, so that is what it says.
          _gunLine=found.name+' to your empty slot. '+p.wep.name+' stays in hand. Select '+found.name+' on your tactical belt to swap.';
'@

SubRx @'
var VER='13.23';
'@ @'
var VER='13.24';
'@

$pat = "(?m)^  now:'v13\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.24: A LIVE FALSE INSTRUCTION, found by auditing every help line after today control changes: pick up a better gun with your second slot free and the game said the old gun stays in hand, X swaps. X has not swapped weapons since the tactical belt took that job, and since v13.10 X searches what you stand on. It is spoken, not dead code: autoEquipOn returns true for every human player, only the bot keeps the dial, and the pickup summary says the kept gun line whenever it is set, so every player who finds a better gun with the second slot free was told to press a key that does something else, at the moment he wants the new gun. Check v12.14 took the same phrase off the controls card on these same grounds and guards that text, but this is a second copy built in the pickup branch, so it was never covered. The line now names the real swap, selecting the new gun on the tactical belt, which calls swapGuns. Check 13.24 searches a real container holding the best gun in the table with the second slot emptied, captures what the game says, and requires the line not to send him to X and to name the tactical belt; it fails on v13.23. The same audit found the plate text clean everywhere, and no other X-swap phrasing in the file',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
