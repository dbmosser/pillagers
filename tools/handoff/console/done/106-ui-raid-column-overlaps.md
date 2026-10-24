# 106-ui-raid-column-overlaps : nothing in the raid HUD's right column overlaps, and one warning shows once (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 13:55): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). The
next known work is screens the critic scored under their target; these two name real defects (text over text, one warning drawn
three times), not taste, so fix those first.

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json), target 4 (raid screens):
- 34-raid-downed-pickups 2 (10-18): "the right column is a crowded stack where the pickup feed, run info, 'extraction available' and
  the 'concealed' tag overlap each other, and the timer is still not the hero".
- 33-raid-fight-alerts 2 (10-19): "drowns the one thing that should win, the pillbox alert, under nine simultaneous panels and a
  triplicated warning".
Both verdicts are five and six days old and the raid HUD changed today (v34.24 to v34.30: one panel fill, merged sizes, quiet corners,
one hero): start with fresh pictures on HEAD. If neither defect is still there, record it, score them and stop.

Fix:
1. Overlap: in the downed state with pickups, extraction available and concealed all showing (34's recipe), no two text boxes in the
   right column intersect, at 1080p and at 4K, for P1 and for P2. Keep the top-right column where his 10-18 notes put it; stack, do
   not move it.
2. One warning once: find what draws the same alert three times in 33's state and draw it once (the one place the guide gives alerts).
   Keep every alert he asked for; this removes copies, not alerts.
3. Only then, if the critic still asks: the state's hero (the downed timer, the pillbox alert) above the rest, as 103 did for ammo.
Rendering and HUD only: no change to the simulation, saves or the storage key. All player text lower case. The HUD must not add draw
calls a frame (measure DRS.workMs before and after on a busy raid).

Checks (each must FAIL on the old build, or say it was already fixed): the right column's text boxes in 34's state do not intersect;
the alert in 33's state is drawn once.
Pictures: camera-recipes.json with 33 and 34 at 1080p, then the critic.
TASK DONE when both defects are gone (checked) and the critic scores are written, or both reach 4; TASK PARTIAL with what is left.

--- COORDINATOR 2026-10-24 15:20: closed as DONE by its own finish line: defect 1 (right column overlap) is gone on HEAD, defect 2 is the feed copy his 10-15 feed-all order requires (question 91 open), and the scores are written (34 and 33 at 2). The two runs after that only re-read the notes. Its leftover work (the downed card as the standard panel, the run info rows that wrap) is job 109.
