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

# HIS REPORT, 2026-09-08, live, with a screenshot: "the player gets stuck in the
# horizontal wall", and "weird graphic and player location glitches always happen
# right there in the long thin building".
#
# THE LONG THIN BUILDING IS NOT A BUILDING. It is a raised deck: DOCK CATWALK on
# COLD STORAGE, 900 by 110 with a lift of 26, sitting under the dock bays. The
# vertical stripes he can see on it are its plank lines, laid every 26 units by
# the ground bake.
#
# A deck is walkable floor plus a lift. Its EDGES are collision, built as four
# walls 14 units thick laid inside the deck's own footprint and tagged ledge. And
# then they are painted by the ordinary wall painter, which lifts every wall body
# 26 units above its collider so a building reads as having height.
#
# MEASURED ON THE LIVE FIXTURE, COLD STORAGE, seed 4242:
#   deck walkable band            y 634 to 716   (82 units)
#   south kerb collider           y 716 to 730
#   south kerb PAINTED            y 690 to 730
#   north kerb collider           y 620 to 634
#   north kerb PAINTED            y 594 to 634
#
# So twenty six of the eighty two units of deck he is allowed to stand on are
# painted over as solid wall, and twenty six units of ordinary ground north of
# the deck are painted as solid wall as well. Walking south onto the catwalk he
# walks twenty six units INTO what looks like a wall before anything stops him,
# which is being stuck in the horizontal wall. Standing on the south third of the
# deck, which is legal, he is behind the kerb: a wall sorts by the bottom of its
# collider, 730, and a man standing at 700 and lifted by the deck sorts at about
# 674, so the kerb is painted over the top of him. That is the position glitch.
# Both of his symptoms are this one thing.
#
# THE FIX. A kerb is not a building. A wall tagged ledge is painted on its
# collider and nowhere else, so what looks solid is solid, everywhere, on every
# deck on both sectors. The deck's height still reads: the ground bake already
# lays a contact shadow under every deck, a bright lip along its top edge and a
# dark near edge, and the kerb keeps its own warm top lip and ink creases.
#
# NOTHING MOVES BUT PAINT. No wall is added, removed or resized, no collider
# changes, no deck changes, and the wall painter has never touched the seeded
# stream, so the map fingerprint is untouched.
SubRx @'
      var LIFT=wl2.lift||((wl2.w<=60&&wl2.h<=60)?14:26);
'@ @'
      // v12.47, HIS REPORT: A DECK KERB IS PAINTED ON ITS COLLIDER AND NOWHERE
      // ELSE. Every wall body is lifted 26 units above its collider so buildings
      // read as having height. A deck edge is not a building: it is a 14 unit
      // kerb laid INSIDE the deck's own footprint, so lifting it painted 26
      // units of solid wall over the deck he is standing on, and 26 units of
      // solid wall over the ground on the other side. Measured on COLD STORAGE:
      // the deck is walkable from 634 to 716 and its south kerb was painted from
      // 690, so a third of the deck looked like wall. He walked into it and
      // stopped 26 units short of where it looked like he should, and standing
      // on the south of the deck he was painted over by the kerb, because a wall
      // sorts by the bottom of its collider and he sorts by his lifted feet.
      var LIFT=wl2.ledge?0:(wl2.lift||((wl2.w<=60&&wl2.h<=60)?14:26));
'@

# NEW IN.
SubRx @'
  'AUTO-JOG STOPS WHEN YOU GO DOWN. It used to survive the whole time you were on the floor, so the moment you got up again you walked off toward the cursor at 40 health with no key held, which was the character walking off by himself.',
'@ @'
  'AUTO-JOG STOPS WHEN YOU GO DOWN. It used to survive the whole time you were on the floor, so the moment you got up again you walked off toward the cursor at 40 health with no key held, which was the character walking off by himself.',
  'THE EDGE OF A RAISED DECK IS WHERE IT LOOKS. Catwalk and gantry edges were painted like building walls, 26 units taller than the thing you actually collide with, so a third of the deck you were standing on was covered by a wall you could walk through, you stopped short of the edge you could see, and standing at the near side hid you behind it.',
'@

# STAMPS.
SubRx @'
var VER='12.46';
'@ @'
var VER='12.47';
'@
SubRx @'
var WHATSNEW_VER='12.46';
'@ @'
var WHATSNEW_VER='12.47';
'@
$cnt=([regex]::Matches($s,"now:'v12\.46:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.46 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.46:[^']*'",{ param($m) "now:'v12.47: HIS REPORT of 2026-09-08, with a screenshot: he gets stuck in the horizontal wall, and weird graphic and player location glitches always happen right there in the long thin building. The long thin building is not a building. It is a raised deck, the DOCK CATWALK on COLD STORAGE, 900 by 110 with a lift of 26, sitting under the dock bays, and the vertical stripes he can see on it are its plank lines laid every 26 units by the ground bake. A deck is walkable floor plus a lift, and its edges are collision: four walls 14 units thick laid inside the deck footprint and tagged as ledges. They were then painted by the ordinary wall painter, which lifts every wall body 26 units above its collider so that a building reads as having height. Measured on the live fixture at seed 4242: the deck is walkable from 634 to 716, its south kerb collides from 716 to 730 but was PAINTED from 690, and its north kerb collides from 620 to 634 but was PAINTED from 594. So twenty six of the eighty two units of deck he is allowed to stand on were painted over as solid wall, and twenty six units of ordinary ground on the other side were painted as solid wall too. Walking onto the catwalk he walked twenty six units into what looked like a wall before anything stopped him, which is being stuck in the horizontal wall, and standing on the near third of the deck, which is legal, he was painted over by the kerb, because a wall sorts by the bottom of its collider at 730 while a man standing at 700 and lifted by the deck sorts at about 674. Both symptoms are that one thing. A kerb is not a building, so a wall tagged as a ledge is now painted on its collider and nowhere else, which makes what looks solid solid on every deck on both sectors; the height still reads, because the ground bake already lays a contact shadow under every deck, a bright lip along its top edge and a dark near edge, and the kerb keeps its warm top lip and ink creases. Nothing moves but paint: no wall is added, removed or resized, no collider changes, and the painter has never touched the seeded stream, so the map fingerprint is untouched. Check 12.47 walks both sectors, hooks the canvas and reads where every deck kerb is ACTUALLY painted rather than recomputing it, and requires no kerb to be painted above the edge he collides with, with a control that ordinary building walls still stand 26 units proud so the game has not been flattened; fails on v12.46.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
