# 00p-m2d-hall notes (lane b)

Keys cw-m2hall (v37.34, 3298e5c98) and cw-m2hallb (v37.36, fb415ca90), both ON HIS PC. Mk scripts S\mk-cw-m2hall.ps1, S\mk-cw-m2hallb.ps1.

## What it is
- pilEpithet(r), hallLiving, hallRows, hallBest, hallEndLines, renderHall at file scope before szNoteShow. Eleven epithet rules in the comment over pilEpithet; never stored.
- Pane #opane_hall in #opmodal; openOps T has ['hall','THE HALL']; Mainframe KeyR opens it (R was free since the rewards key went).
- HALLW (after hubWall): wall x 210 y 20 w 80 h 34 in the back wall's bay between left pier and lift housing; station id hall (250,66) r 36, wallSt:1, labelY:101, no post, nobody beside it, no errands.
- Board: cached canvas id hallcv, baked in hallWallBake when hallWallKey changes (hall count, newest at and name, pixel look, fonts loaded); hallPortrait swaps P.cos* from end.look and wc, draws drawOpBody. drawOpBody lets the pixel body draw on hallcv as on the Fashion turntable.
- P.pil can be null since m2c (between a death and the birth card): the tab then has no living row.

## Known limits
- Generation one, living, shows the old totals of the save at draw time (P.runs, P.ext, P.best, P.achN), written nowhere. Once it dies its hall record holds only what pilRaidEnd counted since v37.29, so the numbers drop on that one record. Changing that means writing old totals into P.pil (a save change in m2a territory), so it was left and reported.
- A record with no end.look wears today's look, and the board does not rebake when today's look changes until the hall changes.

## Pictures and critic
- Recipes: notes/shots/hall-recipes.json (written by S\mk-cw-hallshots.ps1), passed with -Recipes. The real list has no hall screens; asked in alarms.md.
- First round notes/shots/00p-m2d-after: critic 3. Second round notes/shots/00p-m2d-after2 (1080 and 4k, lint 0): critic 3, better_than_before "same". Finish line for these screens is 3.
- Fixed from the critic: sign under its ring, gen gutter 32px, empty line 20px left aligned, 4K clip of the record names.
- Skipped, with reasons: 72px tiles and moving the plaque down (the bay between pier and lift holds three at about 60px, and the wall must not run through a station); hiding the living row or rewording "the hall is empty" (the job file's words); "enter raid!" and the experimental caption (older, his v7.74 words, not this job).
