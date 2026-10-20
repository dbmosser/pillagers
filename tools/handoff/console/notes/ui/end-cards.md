# End cards (task 13-ui-end-cards), run of 2026-10-18 evening
Shipped: v31.52 cw-endx (X on end cards, copy report off the cards, check 10.74 retargeted), v31.58 cw-endslots (haul reveal slots).
Critic after: 76 = 3 (was 2/3), 40 = 2. 35, 38, 59, 60, 77 not re-scored after the X.
## Run of 2026-10-19 (lane f)
Shipped v31.94 cw-endrow, v31.96 cw-endrow2, v31.97 cw-endrow3: haul strip one row (max 8 + count), what is new card X + lime tab + 3 notes. Critic: 40 = 3 (was 2), 77 = 3 (unchanged; wants one hero, panels, left align: layout redesign, not done), 76 mid-reveal = 2 on a frame where the checked objective sits beside a mid-count haul (staging artefact). 35, 38, 59, 60 not re-scored this run (38 = 3 earlier). Remaining critic notes on 40 (card 37 percent wide, three close paths, X contrast) are small or against Q43 dialogs-are-720px; 3 is the finish line for this card.
## Still open (critic findings, none reverse a ruling)
- 76/77: haul slots should be one row of 64px tiles, items reveal in place, "+n more" inside the row.
- 38/60/77: challenge pill -> flat line with tick; merge two "recovered to the armoury" lines into one 16px line; tags as one tx-2 line "a · b · c" with no boxes; xp line is under 16px.
- 38: X is 47px, inset 16px, border line-hi, 40px per guide (guide says 48: decide).
- 40 (what is new card): 5 paragraphs of 2 lines. Cut to 3 one-line bullets; version as hero; body f-body 400 20px; 3px lime tab; dim the background harder and hide toast/controls hint behind it.
- 59 (abandon confirm) not looked at again.

## Run of 2026-10-19 late (lane c, Claude Code)
No ship. The camera command was refused in this session (uishots.ps1 not reachable from the allowed command form), so no new pictures or critic scores. Last scores: 35=3, 38=3, 40=3, 59=3, 77=3, 60=2 (v31.80 cw-endx2 not re-shot), 76=2 (staging artefact). Ten or more tries so far: per the 6-try rule, stop. Best pictures: shots/13-p3 (60, 38, 77), shots/13-t1 (40). Open: card 40 at 90 percent width (against Q43, dialogs are 720px: skipped), drop the got it button on 40.

## Run of 2026-10-19 night (lane a, Claude Code)
Camera works again (shots/13-r5-before: 35 38 40 59 60 76 77, no lint issues on any). Critic on 35 = 3 (same). Its P1s: title and hero both red (one hero), the xp line "(50% penalty for failure to extract)" is an explaining sentence, X plus "log run and return" are two exits (X stays: Q43 wants it on a dialog). Stat labels are already 16px in css (.ocstat span); the critic misreads them.
No ship: past the 6-try limit (10+ tries on this task, his 2.83 b). The one safe edit left (xp line to "+65 xp, 50% penalty") changes game text near line 32918 and the check at mkfixture 85025, and will not lift 35 off 3 alone. Best versions stay shots/13-p3 (60, 38, 77) and shots/13-t1 (40); newest all-seven set is shots/13-r5-before.
Safe next ships if a run is spent on it: xp line shortened (dead and abandon), title tx-1 with a danger tab, survey link to a footer legend.
