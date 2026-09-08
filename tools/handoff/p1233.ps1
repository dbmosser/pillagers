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

# HIS NOTE (2026-09-07 morning): "many-footprints glitch is still happening
# while running vertically". Traced by reading at v12.32. SPRINTING LAYS TWO
# TRAILS, not one. The boot prints he is meant to see are decals, stamped once
# every 56 units of ground actually covered, rotated to the direction of travel
# and capped at 70 (the v10.55 fix for his last footprint note). The second
# trail is G.prints, the scent list a pillager tracker smells: while sprinting
# it takes a mark every 34 units, capped at 40, and the draw loop paints each
# one as two axis-aligned rectangles that are never rotated. Unrotated, the
# pair reads as a left-right pair of boots walking UP the screen. So running
# horizontally they are perpendicular ticks nobody reads as feet, and running
# vertically they line up with his path and read as a second set of footprints
# at a different spacing, interleaved with the real ones. That is the glitch,
# and it is why it is a vertical one.
#
# The player's own scent marks are not drawn at all now. His real boot prints
# already draw the same path from the decal list, his own wake on water is
# already a decal too (v8.89), and a pillager's marks are untouched, which is
# his v8.85 feature. Draw side only: G.prints is still filled and still smelled,
# so no machine and no pillager behaves differently and no balance moves.
SubRx @'
    if(!_fp.mine&&!canSee(p.x,p.y,p.face,_fp.x,_fp.y,G.vseg)) continue;
'@ @'
    // v12.33, HIS NOTE: "many-footprints glitch is still happening while running
    // vertically". Sprinting laid two trails: his real boot prints, stamped every
    // 56 units and rotated to his path (v10.55), and these, taken every 34 and
    // painted as two rectangles that are never rotated, so they read as a second
    // set of feet only when his path happens to point the way they are drawn.
    // His own are not painted any more; the list is untouched, so the trackers
    // that smell it are untouched. The marks a pillager leaves still draw, which is v8.85.
    if(_fp.mine) continue;
    if(!canSee(p.x,p.y,p.face,_fp.x,_fp.y,G.vseg)) continue;
'@

# NEW IN.
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'SPRINTING LEAVES ONE TRAIL OF BOOT PRINTS, NOT TWO. A second set was being drawn from the trail a tracker smells, unrotated, so it lined up with your path and doubled your footprints when you ran up or down the screen.',
'@

# STAMPS.
SubRx @'
var VER='12.32';
'@ @'
var VER='12.33';
'@
SubRx @'
var WHATSNEW_VER='12.32';
'@ @'
var WHATSNEW_VER='12.33';
'@
$cnt=([regex]::Matches($s,"now:'v12\.32:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.32 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.32:[^']*'",{ param($m) "now:'v12.33: his note of 2026-09-07 (many footprints while running vertically): sprinting lays two trails. The boot prints he is meant to see are decals, one every 56 units of ground covered, rotated to his path and capped at 70. The other is G.prints, the scent list a tracker smells, one every 34 units while sprinting, painted as two rectangles that are never rotated, so they read as a pair of boots walking up the screen: perpendicular ticks when he runs across, a second set of footprints interleaved with the real ones when he runs up or down. His own scent marks are no longer painted; the marks a pillager leaves still are, which is his v8.85 feature, and the list itself is untouched so nothing that smells it changes. Check 12.33 sprints him north through the real keys and loop, counts the marks painted from each list by watching the canvas, and requires the second trail to be gone with the real prints still there and G.prints still filling; fails on v12.32.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
