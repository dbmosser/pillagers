# 106-ui-raid-column-overlaps (lane c, 2026-10-24)

Pictures on HEAD (v34.31): notes/shots/106-before/ (33 and 34 at 1080), notes/shots/106-4k/ (34 at 4k).

## 34 downed pickups: right column overlap
Gone. At 1080 the right column (career panel, run info, extraction available, pickup stack, concealed tag, ammo card) has
no two text boxes touching; the 4k shot scales the same way. Nothing to fix, no ship. (P2 window not shot: the same draw code, no per-seat layout.)

## 33 fight alerts: one warning once
Now twice, not three times. "the pillbox has seen you" is the red banner (alertSay) plus a row in the left feed (feedSay).
"location revealed" and "running slowly" are likewise a top-centre row plus a left feed row.
Cause is say() (line ~22966): every line said goes into the feed. That is his order of 2026-10-15 (cw-feedall, "All text shown to the
player on screen also goes into the player feed"). Removing the copies would reverse it, so I did not. Question logged.

## Critic (on the old pictures, nothing shipped)
- 34: 2. P0 downed card is a flat box, not the standard panel; wants a 3px danger top tab and one red bar. P1 contract rows wrap
  (run info), one long "contract done" sentence over the top, left toast stack of six rows, right chips staggered.
- 33: 2. P0 duplicate alerts (above), P0 controls cheat-sheet in the centre of the screen (shows on first raid only, F1 list).
  P1 red tint over the whole frame, right-hand panels.
Not done: restyle of the downed card and the run info wrap are the next real work if a later run takes them.

## Close (later run, same day)
Nothing shipped. Defect 1 (right column overlap) is gone on HEAD. Defect 2 is two copies by his 10-15 feed-all order; question 91 is open in questions.md.
Critic 2 and 2 on HEAD pictures (see above). Next real work: downed card as the standard panel, run info wrap (own task).

## Rerun (lane a, 2026-10-24)
Read the notes above, nothing changed on HEAD that reopens them. No ship. Defect 1 gone; defect 2 is the feed copy his 10-15 feed-all order requires (question open). Downed card restyle and run info wrap need their own task.

## Rerun 2 (lane a, 2026-10-24)
HEAD is v34.33; nothing since the last run touches the raid HUD right column or the alert feed. Defect 1 gone, defect 2 waits on question 91 (feed-all order). No ship.
