# 186e notes (helper session, lane g, Chrome 9357, uishots 9367)

Findings 10-27 night:
- cw-quiettext already moved the "concealed / in cover" chip off the bottom right into the status column (STATUSL 'hide', concealState). Build 1 takes it out of the column and draws small icons beside the stance chip (body zoom, y = by-_up-LH(18)).
- "location revealed" = G.marked>0 (the crier mark, 2.2 s); the crier line itself stays a danger alert.
- No low health or low ammo text lines exist. hp bar has drawLowHpRing (0.95 Hz). Ammo: ammoDraw (amber at 25%, red at 0).
- Top centre: clock, then the extract pill (_lbl+' '+metres+'m', HUDC.plate), then the cw-quiettext edge line (_zEdge: "extraction c available") which build 2 replaces with an edge arrow "c 152m".
- Weather: G.wx (WEATHER ids clear partly rain fog blackout storm), G.tod (TODS dawn morning noon golden dusk). The contracts panel already lists "dawn clear".
- P4 answers: msgReach 'e' -> feedSay at once. Build 3 moves them under the character.

Decisions (logged, no question needed):
- Icons show their word for about 2 s the first time they turn on, then icon only (so a new icon is never a mystery).
- Low ammo pulses red (alpha), empty is solid red plus the key cap; the card is not widened (34.89 keeps its padding even): the cap sits left of the 0, or over the 0 on a narrow card (the demo).

Shipped: v35.49 cw-hudstates (23:56), v35.50 cw-extpill (00:03), v35.52 cw-answerline (00:12), v35.53 cw-hudsize (00:23), all ON HIS PC.
Fixture retargets (fixq, hold on old and new): 35.30 THREE (icons), 35.30 FOUR (edge arrow), 35.44 (HEALTH FULL on the answer line).
Decisions: no soft "no" sound exists, so the answer line is silent; a line given o.reach outright (checks only) keeps the feed; the full F1 list (second press) stays at 13 px (needs a fit redesign, not done here); "locked" and "no ammo" are world and reticle words, not say() lines, so they are untouched.
Pictures: notes/shots/186e-1-after .. 186e-4-after (21, 33, 34, 50 at 1080). Critic not run (week 73%, line 55%).
