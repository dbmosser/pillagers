56-stash-names-after : finish 53's last piece, the 28.20 check after v32.89 "stash setup names fit" (coordinator 2026-10-20)
effort: medium

Job 53 (notes/53-corpus-reds-b.md, lines about v28.20) found a REAL bug: at the default menu zoom 1.3 the gun key and item wheel names
on the stash were cut. Codex fixed the game in v32.89 (cw-cx-kitnamesfit, e2883163): each name now sits under its picture across the
whole tile, tiles 48 to 76 px. Two things are left:
1. Check 28.20 in tools/mkfixture.ps1 still tests picture overlap on x only, which a name under its picture always "fails". Retarget it
   to test real rectangle overlap (both axes) while keeping every other part: every name whole at zoom 1.3 (2560x1440 layout), no
   picture over its name. Run it on HEAD (runchk.sh); it must PASS now and would FAIL on v32.88 (names cut). Lock, edit, runchk,
   HELD=1 fixq.sh, unlock, short hold.
2. v32.89 changed what he sees on the stash setup: take the picture of screen 04 at 1080 and 4k with tools/uishots.ps1 (lane camera
   port), look at it, and run the critic on it (with a before picture if one exists in notes/shots/). Fix any P0 or P1 it names that is
   about the gun key or item wheel tiles; log the visible change in notes/ui/changes.md.
Write one line per item in tools/handoff/console/notes/56-stash-names-after.md.

TASK DONE when 28.20 passes on HEAD with the two-axis test and screen 04 has been looked at and judged; TASK PARTIAL with what is left.
