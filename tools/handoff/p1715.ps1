$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# A PLAIN LEFT CLICK ON AN ARMOURY GUN NO LONGER MOVES IT OUT OF THE ARMOURY INTO THE STASH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  grabEnd();
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
'@ @'
  grabEnd();
  // v17.15, co-op hunt 2026-09-28: A PLAIN CLICK ON AN ARMOURY GUN MOVES NOTHING. Every press arms a drag and this release
  // drops on the zone under it, and the armoury row is drawn inside the stash grid, which is a drop zone, so a left click on
  // a spare gun ran the stash drop and moved it out of the armoury into the stash, out of reach of the gun menu, TOP GEAR and
  // the shop. A rack grab that never moved is a click, and right-click stays the armoury verb. A real drag is unchanged, and
  // every other drag source keeps what a click did before.
  if(!held.moved&&held.from==='rack') return;
  if(z&&typeof z.__grabDrop==='function') z.__grabDrop(held.key,held.from);
'@

SubRx @'
var VER='17.14';
'@ @'
var VER='17.15';
'@

$pat = "(?m)^  now:'v17\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.15: The document mouseup that ends every pointer drag dropped on the zone under the release point whether or not the pointer had moved, and the armoury cells live inside #stashgrid, the stash drop zone, so a press and release in place on a spare armoury gun ran the stash drop with from rack and rackToStash spliced it out of P.weapons into P.stash with the line that it is in the stash. The mouseup now returns before the drop when a rack grab never moved, so a click on an armoury gun is only a click; a drag that moved past the 6 pixel threshold drops as before, every other drag source is untouched, and the pad path already treated A in place as a click. No player text, no number and no seeded draw moved. Check 17.15 fails on v17.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
