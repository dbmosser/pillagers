# 105-ui-end-cards-dialogs (lane b, 2026-10-24)
Fresh pictures on HEAD (v34.31): shots/105-before (35, 38, 59, 60). Critic on each (single picture): 35 = 3, 60 = 3, 59 = 3, 38 = no score (it wanted an old/new pair).
Critic did not know the dialog rule (card 37 percent wide): per style-guide Window (his Q43) an end card (720) and a confirm are dialogs, so the size points are docked on purpose and not fixed.
Fixes in key cw-endcards2: xp line "+65 xp . 50% penalty" (sentence kept hidden), title 32px (guide), KIA hero bone with red label (one red: the title), tiles 80px under the hero, feedback line a bordered 40px ghost button with lime focus ring, raid feed hidden while the abandon question is open, x of the abandon card 16px lower on the title row.
Next: after the ship, shoot shots/105-after and run the critic with before then after.

## Result (after v34.32)
Critic on old/new: 35=3 better, 60=3 better, 38=3 same, 59=3 better. Left over: critic still reads the card as small (docked on purpose, style guide dialog rule, his Q43/54), docks stat labels at 16px (css is already 16px, misread), asks for a danger tab and a pad glyph on cards (not done, new elements). 4 not reached on any card. v34.33 hides the page toast over the abandon question (the toast was #hubtoast, not the feed).

## Run 2 (lane a, 2026-10-24)
Read the saved pictures and scores from the first run (35=3, 38=3, 59=3, 60=3, all on v34.32/33). No new ship: the open findings either contradict each other between cards (red hero vs no red, 24 vs 32px gaps, title color) or ask for new elements (danger tab, pad glyph, a fifth tile/stat cell), which this task forbids. Size is docked on purpose: style guide Window rule, end card 720 and confirm are dialogs (his Q43, 54).
Stuck, for a later pass: the critic wants one red place and 24/32px block gaps on 8px grid; stat values 20-24px tx-1. A single follow-up that sets stat values 24px and block gaps 32px on all four cards might lift one to 4; not tried (shared css, risk to other cards).

## Run 3 (lane a, 2026-10-24)
Nothing new shipped. Task already worked twice (4 not reached, remaining findings docked on purpose or need new elements). Leaving the 24px stat / 32px gap follow-up as an idea for a later pass.
