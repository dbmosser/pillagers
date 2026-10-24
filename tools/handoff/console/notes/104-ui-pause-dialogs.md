# 104-ui-pause-dialogs (lane a, 2026-10-24)
Shipped v34.31 (cw-pausedlg, CSS only): leave button (abandon / end run / return to character selection) is the danger ghost box, one lime focus ring on every pause button. Check 34.31 (box colour, ring, gap <= 24px) fails on the old build. Check 31.49 retargeted (it demanded no box).
Pictures: shots/104-before, shots/104-after.
Critic after: 25 = 3 (better_than_before yes), 42 = 3, 49 = 3 (yes). 78 shares 25's CSS and picture, not scored separately.
Points still docked, all reasons I did not act on:
- card size (480): style guide Window rule says a dialog (pause 480) is not a window; the guide beats the judge (his 54).
- merge report a problem + feedback, move what's new out: Q61 keeps the feedback line and button; his answer 37 put what's new here. Needs him.
- 24px extra gap before the leave button: the task says no dead gap.
- scrim .80 plus blur: check 29.56 wants 99 percent so the HUD does not ghost; not touched.
- pad focus not visible in stills: the camera has no pad focus; the ring is checked by 34.31.
- run info / identity line: task says add nothing new.

## Run 2 (2026-10-24, lane a)
Re-ran the critic on 25 (before vs after, the guide's dialog rule is inside its 8000-char guide slice): still 3, better_than_before yes.
Findings, all left alone, with reasons:
- merge report a problem + feedback, drop what's new: Q61 and his answer 37 keep them (needs him; already in questions.md).
- abandon needs more space or a divider: the task says no dead gap; the 16px gap is the guide's stack gap.
- no focus ring in the still: the camera has no pad focus; check 34.31 proves the ring on the focused button.
- card is 25 percent of the width: guide Window rule says pause 480 is a dialog (his 54: the guide beats the judge).
- run info line: task says add nothing new.
- scrim .80 and blur: check 29.56 needs the HUD readable at 99 percent; not touched.
Scores stay 25 = 3, 78 = 3 (same CSS), 42 = 3, 49 = 3. Two follow-up rounds gave no rise, so I stop here (his 2.83 b).
