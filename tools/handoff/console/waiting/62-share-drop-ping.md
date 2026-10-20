62-share-drop-ping : in a 2-player raid, a dropped item pings the teammate's map, minimap and world (planner draft 2026-10-20)
effort: high

Source: memory pillagers-100-picks-2026-10-14.md #48: "drop an item with an auto-ping so the teammate sees it"; q-round3/answers.md 3.48: "c: Both may go in before Monday".
Not done (planner, 10-20): bagDropSel (dark_raiders.html 23979) only says "dropped x" with the sub line "team can loot" in the dropper's
own window; grep -c "autoPing\|dropPing\|shareDrop\|pilePing" dark_raiders.html = 0 (case sensitive; a case-blind grep only matches
"dropping"). His 3.35 b: they never tried sharing by drop.

1. In a 2-player raid, an item dropped by either player (Z on keys, Y with the backpack open on a pad: bagDropSel) puts a ping on the
   TEAMMATE's map, minimap and in the world, reusing the v25.77 ping (N, d-pad up) and its look. No new marker style: the 10-15
   polish order says new features fit the system that already does the job.
2. The ping clears when the pile is taken (by either player) or after the normal ping lifetime, whichever comes first.
3. The host makes the pile (about line 24047); send the ping the way pings already travel between the windows.
4. Solo play is unchanged (no ping for yourself, the "dropped x" line stays).
Checks (control must FAIL on v32.90): on the linked path, a drop gives the teammate one pile ping; taking the pile clears it; a solo drop
makes no ping. Fixture gotcha: the fixture replaces say() and sfx(), so put the ping decision in its own function.
Pictures: a picture from EACH window (his 2.86 a). The camera cannot yet stage the player 2 side of a real linked pair; the coordinator is
fixing that (coord-08). If it is not fixed when you ship, end TASK PARTIAL: "two-window pictures wait on coord-08" (not TASK WAITING:
coord-08 is not a task file).
It is a FEATURE: ship by Mon 10/26, otherwise it waits until after 10/30. Party risk: medium (a new message between the two windows).

TASK DONE when shipped, the checks pass and both windows' pictures show the ping; TASK PARTIAL with what is left.

COORDINATOR 10-20 14:57: shipped as v32.97 (3172e3e5, check 32.97 green). Only the picture from each window (his 2.86 a) is left, and a
helper cannot take it until the camera stages player 2 of a real pair, so the job waits here, not in tasks/ (a rerun would only spend a
run saying the same). coord-08 step 3 takes the two pictures once the camera works, then this moves to done/.
