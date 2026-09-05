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

# THE BACKPACK ARROWS DIVIDED BY ZERO. The guard tests G.bag.length, the
# arithmetic uses bagStacks().length, and bagStacks hides every copy claimed
# by a tactical belt key; with the whole backpack on the belt the grid is
# empty, the modulo is by zero, and the selection becomes NaN until drawBag
# clamps it back. Silent today, because drawBag clamps; the guard now tests
# the number the arithmetic uses.
SubRx @'
  if(G&&!G.over&&G.bagOpen&&G.bag.length){
    // GRID NAVIGATION, v2.87: the selection is a STACK index now, and the four
    // arrows walk the tile grid. Left/right step one tile, up/down step a row
    // of G.bagCols, which drawBag keeps current.
    var _stN=bagStacks().length, _bc=G.bagCols||5;
'@ @'
  // v11.28: the guard tests the STACKS, which is what the arithmetic below
  // divides by. G.bag.length was the guard, and with every copy claimed by a
  // belt key the stack count is zero while the bag is not, so an arrow key
  // took the selection to NaN (x % 0). drawBag clamped it back each frame, so
  // nothing threw, but the selection was lost and Z dropped from index -1.
  if(G&&!G.over&&G.bagOpen&&G.bag.length&&bagStacks().length){
    // GRID NAVIGATION, v2.87: the selection is a STACK index now, and the four
    // arrows walk the tile grid. Left/right step one tile, up/down step a row
    // of G.bagCols, which drawBag keeps current.
    var _stN=bagStacks().length, _bc=G.bagCols||5;
'@

# STAMPS.
SubRx @'
var VER='11.27';
'@ @'
var VER='11.28';
'@
SubRx @'
var WHATSNEW_VER='11.27';
'@ @'
var WHATSNEW_VER='11.28';
'@
SubRx @'
  'F NO LONGER BURNS A BANDAGE WHEN YOU PUNCH. Since F became the melee strike, a press while hurt also used the smallest heal in your backpack, silently. Heals are used from the tactical belt, and F now only strikes (and still revives you when you are down).',
'@ @'
  'THE BACKPACK ARROWS BEHAVE WHEN EVERYTHING IS ON THE BELT. With every carried item claimed by a tactical belt key the backpack grid is empty, and an arrow key used to throw the selection away. It now does nothing until there is something to select.',
  'F NO LONGER BURNS A BANDAGE WHEN YOU PUNCH. Since F became the melee strike, a press while hurt also used the smallest heal in your backpack, silently. Heals are used from the tactical belt, and F now only strikes (and still revives you when you are down).',
'@
SubRx @'
  now:'v11.27: F did two things. v10.64 bound the melee strike to the F keydown and left the older held-F heal in the player update, so one press while hurt swung a punch and burned the smallest heal in the backpack, with "Applying Bandage..." on screen. Reproduced: melee 1, bandage gone, one press. The held-F heal is removed; heals are used from the tactical belt; the downed self-revive on F stays. Check: F strikes and the backpack keeps its bandage, the belt still spends it, down and F still revives.',
'@ @'
  now:'v11.28: the backpack arrow keys divided by zero. The guard tested the bag length and the arithmetic used the stack count, and bagStacks hides every copy a belt key claims, so with the whole backpack on the belt an arrow made the selection NaN. drawBag clamped it back each frame, so it never threw, which is why nobody saw it; the selection was lost and Z would have dropped from index -1. The guard now tests the stacks. Reproduced with one belted SMG, arrow left, selection NaN.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
