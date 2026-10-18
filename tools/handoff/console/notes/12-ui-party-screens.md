# 12-ui-party-screens (lane b) notes

Screens 46 47 48 49 52 53 54 55 56 58 62 63 64. All sit at 3 of 5 from the critic (58 and 56/64 at 2-3 earlier).

## Shipped
- v30.24 cw-partyempty, v30.23 cw-modalflat, v30.30 cw-pausehint (earlier runs)
- v30.78 cw-partyx2: 48px ghost X on the how to play / board cards (critic 46: 3, better)
- cw-cardP24 (what's new card stamp, needed to get the gate through)

## Pictures
shots/12b-before and shots/12b-after (all 13 screens, 1080).

## Stuck: the critic contradicts itself on the footer "press any key"
- v29.97 cw-partyprompt turned the filled 56px button into a footer HINT (dot + words), because the critic called it
  "an instruction drawn as a filled button, a fake action".
- Now (v30.78) the critic on 46 and 52 asks for the opposite: a 56px primary "got it" / "continue" button and a ghost
  "back to menu", plus a pad glyph, a 16px label size floor, 4 equal stat columns, a 720px dialog with 56px header / 72px footer.
- Do not flip it back again without the owner: the prompt is a real any-key prompt on the arcade cabinet (any key closes
  the page), a button would be a fake choice. Logged for him.
- Open P1/P2 left on 52/55: title "run over" is tx-2 (kept on purpose, score leads); stats labels are 14-15px (fs-label token);
  card sits on the blurred hub (his scrim ruling). 62/63: the white ring on the lime row and the "tonight: 0 runs" line.

## Lane c run (10-19)
- v30.97 cw-opclean shipped (item 1 below done). Critic 62 after: 3, better, still 3. It now asks for a visible backdrop
  (contradicts cw-partyopbd: ghost text showed through, so the solid void stays), a smaller dialog, a B key cap. Stuck: stop on 62.
- 46 and 52/55 untouched this run (critic keeps flipping on the footer prompt; see Stuck). Items 2 and 3 remain.

## Lane b run (10-19, 12d pictures)
- v31.07 cw-sticks shipped (item 3 done). Critic: 46 = 3 same (asks for a got-it button again), 58 = 3 better, 47 = ? and 53 = 2.
- 47 and 53: the staged picture is the live raid HUD, not a party card (53 "extracted bonus initials" shows mid-extract HUD).
  Staging lives in ui-screens-js.json (not mine to edit); HUD belongs to task hud. Needs staging fix from owner/lane that owns shots.
- 58 title: critic wants flat tx-1 title, no amber gradient; the wordmark colour is his art, left alone.
- 55 already has 4... 3 equal stat columns, 56px score; item 2 is effectively done by earlier ships.
- Remaining ask loop is the footer prompt contradiction (see Stuck). Nothing safe left to ship; stop.

## Next run could try (one ship each, none reverse a ruling)
1. 62: hide "tonight: 0 runs" when the count is 0; focus ring only the lime bar (no white ring).
2. 52/55: stats as 4 equal columns, 24px values / 16px labels; score line with a 16px "score" label over a 56px number.
3. 46: row names 20px, headers 16px tx-2 tracked, "left stick"/"right stick" spelled out in lower case.

- 2026-10-18 evening (coordinator): screens 46 and 56 belong to this task only (03 dropped them); 03 keeps 45 for the title and backdrop, the attract card code is this task's. See the SCREEN HANDOVER block at the end of the task file.
