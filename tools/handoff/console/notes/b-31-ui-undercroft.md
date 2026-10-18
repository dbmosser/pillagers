# b-31-ui-undercroft: status (PARTIAL)
Shipped: v29.68 cw-vdetdark, v29.71 cw-undercroft2 (see notes/ui/undercroft.md and changes.md).
Critic after both (shots b-31-c1): 02 = 2, 04 = 2, 06 = 2, 08 = 2, 12 = 2. Not at 4.
Run 3 (this one): reshot all 25 screens to notes/shots/b-31-d1 (1080). Looked at 04, 08, 14, 65. Shop pane is dark now and fine;
racks (14) has 1316px buttons and empty right third (that is the ONE GRID rule, line 1289 of the game), codex (65) is a top-left grid with a
dead lower two thirds. No critic score anywhere in accept.json is above 3 for any screen (the critic grades the full-window slab down every time),
so I did not spend credits on 25 more critic runs or ship cosmetic edits that cannot move the score.

STUCK: the critic's remaining P0/P1 findings conflict with his rulings, so I did not ship them:
- "Full-screen slab, use a centred card with a close X top right": his ui5q1h #50 ruling is ONE GRID, ONE RIGHT EDGE (the counter
  runs the full window width), and the footer CLOSE at the foot of every window (v28 shared-style). Reversing either is not mine to do.
- "$ price": credits sign, needs his word (left alone, see undercroft.md).
- "Explaining sentences" (hint lines, msub): the words are his / frozen; restyle only, no text edits.
Left for a next run, only if he lifts those rulings: card shell <=960x680, header 56px, close X top right, type floor 16px on the stash.
Also then: cap racks buttons ~640px, codex grid 4 columns centred.
Run 4: re-read the shots (04, 08, 12, 16, 65), same conclusion; no new ship, nothing spent on the critic. Waiting on his word on the three rulings above.
Run 5: questions.md has no answer on the three rulings; nothing new to build on. No ship, no spend.
Not judged after the changes: 03, 05, 07, 09-11, 13-18, 39, 41-44, 65-67.
Run 7: the b-31 question was missing from questions.md, so I re-logged it there (one line). Re-read shots 02, 04, 14, 65: same state, no ship, no critic spend.
Run 8: questions.md line 10 still has no answer on the three rulings. No ship, no spend.
Run 6: questions.md still has no answer on the three rulings (centred card/close X, $ price, explaining hint lines). No new ship, no spend.
Run 9 (lane e): SHIPPED v30.00 cw-welcomecard, v30.07 cw-welcomefit, v30.11 cw-welcomeleft (+ card stamp v30.02 cw-cardp15). Welcome pack 02: critic 2 ('better: yes') x3, shots b-31-e1 (before) to b-31-e4. STUCK at 2 after two follow-ups: remaining P1s need his words deleted (intro paragraph, 'to your stash' sublines), rarity name colours, or a header close X (his footer CLOSE rule). Pattern that works for the other modals: copy the welcomemodal CSS block (frame ::before 960, msub/list/foot 880, CARDFIT entry, foot margin-top 14 !important). The opmodal screens (03-05, 08-17) are one shared full-window grid shell and still wait on his ONE GRID ruling. Not judged: 03-18, 39, 41-44, 65-67.
