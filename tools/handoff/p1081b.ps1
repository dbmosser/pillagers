$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0

# ==== "AFTER EVERY ROLL" WAS NOT WHERE I PUT IT, AND THE NUMBERS SAID SO.
# ==== The streak, window and lift passes all draw random numbers PER WALL, so
# ==== removing a run of shell before them changed how many draws they made and
# ==== the whole seeded stream moved behind it: COLD STORAGE 85 entities to 78
# ==== and 165 containers to 163, the mile 593 containers to 578, and the wall
# ==== count went UP on COLD STORAGE, 623 to 633, because the window carve
# ==== splits walls and was now carving a different set.
# ==== The pass moves to the last possible moment, after the lifts and before
# ==== the sight segments, where nothing downstream rolls anything.

$startPat = [regex]::Escape("  // ---- v10.81, HIS NOTE: DESTROYED BUILDINGS. See the long note in DESIGN.md.")
$endPat = "  for\(var k=0;k<walls\.length;k\+\+\)\{\r?\n    var wl=walls\[k\]; wl\.streaks=\[\];"
$mStart = [regex]::Match($s, $startPat)
if (-not $mStart.Success) { throw "ruin block start not found" }
$mEnd = [regex]::Match($s.Substring($mStart.Index), $endPat)
if (-not $mEnd.Success) { throw "streaks loop not found after the ruin block" }
$block = $s.Substring($mStart.Index, $mEnd.Index)
if (([regex]::Matches($block, [regex]::Escape("_ruinLog={picked:0"))).Count -ne 1) { throw "the block cut does not hold the pass" }
$s = $s.Remove($mStart.Index, $mEnd.Index)
$n++

$block = $block -replace [regex]::Escape("  // Runs here, after every roll and after the sealed-room repair, so it consumes`n  // no rr() and bldgRuin 0 reproduces the pre-v10.81 map exactly on any seed."), "  // THE LAST THING THE MAP BUILD DOES. The streak, window and lift passes above`n  // all roll per wall, so removing a run of shell before them moved the whole`n  // seeded stream; measured, that cost COLD STORAGE seven entities and two`n  // containers and pushed its wall count UP. Here nothing downstream rolls`n  // anything, so bldgRuin 0 reproduces the pre-v10.81 map exactly on any seed."
if ($block -notmatch "THE LAST THING THE MAP BUILD DOES") { throw "the moved block kept its old note about where it runs" }
$n++

$anchorPat = "  var segs=\[\];\r?\n  for\(var m2=0;m2<walls\.length;m2\+\+\)\{ var w2=walls\[m2\];"
$mA = [regex]::Matches($s, $anchorPat)
if ($mA.Count -ne 1) { throw "segs anchor matched $($mA.Count) times" }
$s = $s.Insert($mA[0].Index, $block)
$n++

if ($n -ne 3) { throw "expected 3 edits, made $n" }
if (([regex]::Matches($s, [regex]::Escape("_ruinLog={picked:0"))).Count -ne 1) { throw "ruin block duplicated" }
[IO.File]::WriteAllText($p, $s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
