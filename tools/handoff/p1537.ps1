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
    if(dist(p,CU)<46){ crateUnderfoot=true; break; }
'@ @'
    // v15.37, peddler audit finding 9: A CRATE ON THE FAR SIDE OF A WALL NEVER BLOCKS THE STALL. This test was distance and
    // nothing else, while the search below has also needed a clear line to the box since v4.06 (nothing is looted through a
    // wall). So a crate, cache or body within 46 units on the other side of a thin wall or a stall slab kept E from the stall,
    // the plate over the Peddler said search the crate first, and the search could not reach it: E did nothing, and the prompt
    // pointed at a box that cannot be opened from where he stands. The self-clearing rule above only holds while the two tests
    // agree, so this one now asks the search its own question, the same 46 units and the same sight test on G.vseg. A crate
    // he can search still wins the key. No seeded draw, no number moved.
    if(dist(p,CU)<46&&losClear(p.x,p.y,CU.x,CU.y,G.vseg)){ crateUnderfoot=true; break; }
'@
SubRx @'
var VER='15.36';
'@ @'
var VER='15.37';
'@

$pat = "(?m)^  now:'v15\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.37: A CRATE ON THE FAR SIDE OF A WALL NEVER BLOCKS THE STALL. An unopened crate, cache or body within reach but behind a thin wall kept the Peddler stall shut and the plate asked for the crate to be searched first, while the search needs a clear line and could not reach it, so E did nothing. Only a crate the search can reach from where he stands keeps E from the stall now. Check 15.37 puts a crate just past a thin wall beside the Peddler and presses E; it fails on v15.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
