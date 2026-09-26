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

# THE BACKPACK PANEL PRINTS THE PRICE WITH THE THOUSANDS SEPARATOR. The selected-stack line of drawBag printed ival() bare, so
# a Meridian Reactor Core read $2600 each while the stash hover, the tag-junk hint and the Peddler panel print the same price
# with the comma. Display only: the line now goes through toLocaleString like every other price surface. drawHubBag draws the
# same panel on the floor with G swapped, so the Undercroft backpack is covered by the same line.
SubRx @'
    ctx.textAlign='right'; ctx.fillStyle='#ffc04a';
    ctx.fillText('$'+ival(sst.key)+' each',x+PW-11,hintY);
    ctx.textAlign='left';
'@ @'
    ctx.textAlign='right'; ctx.fillStyle='#ffc04a';
    // v15.95, credits audit finding: THE BACKPACK PANEL PRINTS THE PRICE WITH THE THOUSANDS SEPARATOR. This line printed ival()
    // bare, so a selected Meridian Reactor Core read $2600 each while the stash hover and the tag-junk hint print the very same
    // words as $2,600 each, and the Peddler panel one keypress away prints +$1,430 and Carried home: $2,600. Every other price
    // surface goes through toLocaleString (the v15.05 gamble button was the same class). drawHubBag draws this panel on the
    // floor with G swapped, so the Undercroft backpack reads the same. Display only: the price, the dials, the loot tables and
    // every seeded draw are unchanged.
    ctx.fillText('$'+ival(sst.key).toLocaleString()+' each',x+PW-11,hintY);
    ctx.textAlign='left';
'@
SubRx @'
var VER='15.94';
'@ @'
var VER='15.95';
'@

$pat = "(?m)^  now:'v15\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.95: THE BACKPACK PANEL PRINTS THE PRICE WITH THE THOUSANDS SEPARATOR. With an item worth 1,000 or more selected in the backpack, the price line under the grid printed 2600 each for a Meridian Reactor Core while the stash hover, the tag-junk hint and the Peddler panel print the same price as 2,600. The line now prints the price the way every other price surface does, and nothing under 1,000 changes. Check 15.95 draws the raid backpack with a Meridian Reactor Core selected and reads the price line; it fails on v15.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
