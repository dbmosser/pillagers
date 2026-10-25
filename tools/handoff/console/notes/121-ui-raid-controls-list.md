# 121 (lane a, 2026-10-25)
Before pictures: shots/121-before (79, 80 at 1080). At 1080 the old list (x 490-900) did not overlap the log (x 15-315); old rows ran about 14px, dim, 4 loose columns, caret plus footer.
Built mk-cw-ctrlchip.ps1: one solid panel (underlay plus shared hudPanel fill), rows 16px label size (divided by the list zoom so the screen size is real), key cap box plus word on every row, sections move/fight (left column) and gear/raid (right column), one footer line (f1 full list, none on a pad), rows at 80 percent (check 34.29), 'use item in hand' now 'use item' (shorter so it fits the 47 percent width; logged in changes.md). Folded chip: same hudPanel (.88, plain) and FS(TYPE.label) face and grey text as the standing tag, same bottom edge.
Preflight PASS as v34.72. Ship blocked: stale git index on tools/mkfixture.ps1 (alarms.md). Still to do after ship: pictures 79/80 at 1080 and 4k, a player 2 window picture, critic with rs-1 and rs-2 named, changes.md line.

## Run 2 (10-25): pictures and critic on v34.78
Pictures 79 and 80 at 1080 and 4k in shots/121-after (lint 0 everywhere). Critic on 80 (before then after): 3, better than before, was 2.
Left from the critic (P1 unless noted), not shipped (coordinator said no second ship of cw-ctrlchip):
- panel x 493 floats mid-screen; critic wants x 24. His rs-1 says mid-bottom LEFT, so the position stays (not a finding).
- section labels and action words read about 12-14px at 1080 in the picture; the check passed at the guide label size (16 px divided by zoom), so the critic's pixel guess may be low. A follow-up could raise the section labels to 16 real px.
- left log stack (x 15-315) sits in the same y band but does not overlap (gap 175px); critic wants it moved up and capped at 3 rows.
- run info card, bots list carets, world chips: other screens' findings (not this job).
- P2: footer divider line, 1px bright border on the panel.
Player 2 window picture: not taken. The camera has no player 2 raid screen (only 58, the title) and my rules forbid -Url, so I could not stage one. Both windows share the same draw code (cw-p1p2).
Stop rule: one try after the ship scored 3; the remaining points wait on the larger HUD layout. Coordinator can queue a follow-up (label size, footer divider, panel border) if wanted.
