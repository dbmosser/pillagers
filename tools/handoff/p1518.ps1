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

SubRx @'
  for(var k in RACK_COST) spendHeld(k,RACK_COST[k]);   // v13.59: unpacked copies first, packed ones unpacked properly
'@ @'
  // v15.18, mainframe audit finding 3: BUILD A RACK SAYS WHEN IT TAKES PACKED PARTS OUT OF THE BACKPACK. Packing leaves a part
  // in the stash, so packed copies count toward the rack cost and the button stays live with parts packed for the next ascent.
  // spendHeld unpacks the ones it still needs and returns how many, so the caller can say so, and this loop threw that number
  // away: the backpack came up short at the ascent check and nothing had said why. Which parts are spent does not change
  // (loose copies first, as v13.59 set it); the count is kept for the rack line, the way the crafting bench already says it.
  var _usedPacked=[];
  for(var k in RACK_COST){ var _fp=spendHeld(k,RACK_COST[k]); if(_fp>0) _usedPacked.push(_fp+' packed '+((ITEMS[k]&&ITEMS[k].name)||k)); }   // v13.59: unpacked copies first, packed ones unpacked properly
'@
SubRx @'
  say('Rack '+P.racks+' hums to life. '+'$'+mfPayPer().toLocaleString()+' every time you make it home.');
'@ @'
  // v15.18, mainframe audit finding 3: AND THE RACK LINE NAMES THEM. One sentence is added after the pay, in the same toast,
  // because a second toast would write over the first; the two sentences before it are unchanged.
  say('Rack '+P.racks+' hums to life. '+'$'+mfPayPer().toLocaleString()+' every time you make it home.'+
      (_usedPacked.length?' Used '+_usedPacked.join(', ')+' out of your backpack.':''));
'@
SubRx @'
var VER='15.17';
'@ @'
var VER='15.18';
'@

$pat = "(?m)^  now:'v15\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.18: BUILD A RACK SAYS WHEN IT TAKES PACKED PARTS OUT OF THE BACKPACK. Parts packed for the next ascent still count toward a rack, and building one unpacked the ones it needed without a word, so the backpack came up short at the ascent check. The rack line now says how many packed parts it used, the way the crafting bench does, and which parts are spent is unchanged. Check 15.18 builds a rack with nothing packed, then one with scrap, cells and boards packed, and reads the rack line; it fails on v15.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
